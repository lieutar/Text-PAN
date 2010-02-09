package Text::PAN::Tokenizer::Filtered;
use Any::Moose;
use XML::LibXML;
use List::Util qw( max min );
use Text::PAN::CONSTANTS qw(NS);

has depth =>
  (
   is => 'ro',
   isa => 'Num',
   default => sub{1},
  );

has element_builder =>
  (
   is         => 'ro',
   isa        => 'Text::PAN::Element::Builder',
   lazy_build => 1,
  );

has base =>
  (
   is       => 'ro',
   does     => 'Text::PAN::Role::Tokenizer',
   required => 1,
   handles  => ['in'],
  );


has sect_depth  =>
  (
   is => 'rw',
   isa => 'Num',
   default => sub{0},
  );

has tag_type =>
  (
   is      => 'ro',
   isa     => 'ArrayRef',
   default => sub{[]},
  );


has buffer_class =>
  (
   is => 'ro',
   default => sub{
     require Text::PAN::Tokenizer::Buffered;
     'Text::PAN::Tokenizer::Buffered'
   },
  );

has context =>
  (
   is       => 'ro',
   isa      => 'Text::PAN::Parser::Context',
   required => 1,
  );


############################################################

sub _build_element_builder{
  my ($this) = @_;
  require Text::PAN::Element::Builder;
  Text::PAN::Element::Builder->new;
}


############################################################

sub push_tag{
  my ($this, $name, $type) = @_;
  push @{$this->tag_type}, [$name, $type];
}

sub pop_tag{
  my ($this) = @_;
  @{pop @{$this->tag_type} || []};
}

sub current_tag{
  my ($this) = @_;
  my $st = $this->tag_type;
  @{@$st ? $st->[-1] : []};
}


sub _next_token {
  my ($this) = @_;

  my $base = $this->base;
  my $tok = $base->next_token;
  return undef unless defined $tok;
#warn sprintf("%sSRC: %s %s", ("  " x $this->depth), $tok->[0], $tok->[1] || '*undef*');
  my ($type) = @$tok;
  my $R =
    (+{
       (map{($_ => sub{$this->illegal_token($tok)},)}qw( > = )),

       CLOSE_ELEM         => sub{$this->illegal_end_tag($tok)},
       ENDTAG_START	  => sub{$this->illegal_end_tag($tok)},

       TAG_START          => sub{
         $tok = $this->complete_open_tag($tok);
         if($tok->[0] eq 'OPEN_ELEM'){
           return $this->parse_element($tok);
         }
         else{
           return $tok;
         }
       },
       OPEN_ELEM          => sub{$this->parse_element($tok)},

       BEGIN_COMMENT_DECL => sub{$this->parse_comment_decl($tok)},
       SECTION_OUT        => sub{
         # consume section_out
         while(my $dep = $this->sect_depth){
           $this->sect_depth($dep - 1);
           $tok = $base->next_token;
         }
         $tok;
       },

      }->{$type} || sub{ $tok })->();
#warn sprintf("%sRESULT: %s %s", ("  " x $this->depth), $R->[0], UNIVERSAL::can($R->[1], 'toString') ? $R->[1]->toString : $R->[1] || '*undef*');
  $R;
}

############################################################


sub illegal_end_tag{
  my ($this, $tok) = @_;
  my $val = $tok->[1];
  [TEXT => "</$val" . $this->end_tag_rest ];
}

sub end_tag_rest{
  my $this = shift;
  my $buf = "";
  my $base = $this->base;
  my %last_info;
  for(;;){
    my $tok = $base->next_token;
    last unless defined $tok;
    my $tt  = $tok->[0];
    $tt eq '>' and do{
      $buf .= ">";
      (undef, undef, %last_info) = @$tok;
      last;
    };
    $tok = $this->illegal_token($tok);
    $buf .= $tok->[1];
  }
  return $buf unless wantarray;
  ($buf, %last_info);
}


sub illegal_token{
  my ($this, $tok) = @_;
  my %TV = (
            "SPACES" => " ",
	    'BR'     => "\n",
	    "BL"     => "\n",
	   );
  my ($tt, $val, %misc) = @$tok;
  ($tt =~ m{\A( BR
	     | >
	     | /
	  )\Z}x ) and  do{
	    $tt  = 'TEXT';
	    $val = $TV{$tt} || $val;
	  };
 RET:
  [$tt, $val, %misc];
}

############################################################

sub parse_element{
  my ($this, $tok) = @_;
  my $context  = $this->context;
  (undef, my $elem, my %info) = @$tok;
  ($info{tag_type} eq 'empty') and do{
    return [ELEM => $elem]
  };
  $this->push_tag($info{qname}, $info{tag_type});

  my $buf = $this->buffer_class->new(
                                     name            => $info{qname},
				     element_builder => $this->element_builder,
                                     in              => $this->in,
                                     depth           => $this->depth,
                                     context         => $context,
				    );

  my $base = $this->base;
  my $end_of_line = 0;

  for(;;){

    my $tok = $base->next_token;
    do{
      $end_of_line = 1;
      $info{error} = "reach to eof";
      goto RET
    } unless defined $tok;

    my($tt, $tv, %misc) = @$tok;

    ####
    ($tt eq 'TAG_START') and do{
      $tok = $this->complete_open_tag($tok, $buf);
      ($tt, $tv, %misc) = @$tok;
    };

    ($tt eq 'ENDTAG_START') and do{
      $tok = $this->complete_end_tag($tok, $buf);
      ($tt, $tv, %misc) = @$tok;
    };

    ($tt eq '>') and do{
      (undef, my $tag_type) = $this->current_tag;
      if($tag_type eq 'net'){
        $tt = 'CLOSE_ELEM';
      }
      else{
        $tt = 'TEXT';
        $tv = '/';
      }
      $tok = [$tt, $tv, %misc];
    };

    ####

    ($tt eq 'OPEN_ELEM') and do{
      $this->push_tag($misc{qname}, $misc{tag_type});
    };


    ($tt eq 'CLOSE_ELEM') and do{
      $this->pop_tag;
      $end_of_line = $misc{end_of_line};
      my @cur = $this->current_tag;
      goto RET unless(@cur);
    };

    ####

    ($tt eq 'SECTION_IN') and do{
        $base->unget_token($tok);
        $info{error} = "section in";
        @{$this->tag_type} = ();
        goto RET;
    };

    ($tt eq 'SECTION_OUT') and do{
      my $dep = $this->sect_depth - 1;
        $base->unget_token($tok);
        $info{error} = "section out";
        @{$this->tag_type} = ();
        goto RET;
    };

#    warn sprintf("%s BUF: %s %s", ("  "x $this->depth), $tt, $tv || '*undef*');
    $buf->add_token($tok);
  }

 RET:
  $context->push_element;
  my @all_tokens = @{$buf->buf};
  my $bv = $buf->value;
  $context->pop_element;
  my $children = __strip_para($bv);
  $elem->appendChild($children);
  my $toktype = (($info{begining_of_line} && ($end_of_line || $info{error})) ? 'BLOCK_ELEM' : 'ELEM');
  [
   $toktype => $elem,
   %info,
   consumed_token => \@all_tokens
  ];
}

sub __strip_para{
  my ($src) = @_;
  my $dst   = $src->ownerDocument->createDocumentFragment;
  my @buf    = ();
  my @sc     = $src->childNodes;
  my $ps    = 0;
  foreach my $n (@sc){
    if( $n->nodeType == XML_ELEMENT_NODE and
        $n->localName    eq 'p' and
        $n->namespaceURI eq NS ){
      $ps++;
      foreach my $n ($n->childNodes){
        push @buf , $n;
      }
    }
    else{
      push @buf , $n;
    }
  }
  return $src unless $ps == 1;
  foreach my $n (@buf){
    $dst->appendChild($n);
  }
  $dst;
}

############################################################

sub complete_end_tag{
  my ($this, $tok) = @_;
  my (undef, $name, %info ) = @$tok;
  my ($cname, $ctype) = $this->current_tag;
  return $this->illegal_end_tag($tok) if ( $name && $name ne $cname or
                                           $ctype eq 'net' );
  my ($rest_src, %close_info) = $this->end_tag_rest;
  [CLOSE_ELEM => $name,
   %info,
   %close_info,
   src => "</$name". $rest_src,];
}

sub complete_open_tag{

  my ($this, $tok) = @_;

  my $context  = $this->context;
  (undef, my $name, my %info) = @$tok;
  $name ||=  $context->previous_element_name || 'block';

  my $ebuilder = $this->element_builder;
  my $elem;
  unless(eval{
    $elem = $ebuilder->genelem( $name, [] , {} );
    1;
  }){
    return [TEXT => $info{src}, %info];
  }

  $context->previous_element_name($name);

  my $base     = $this->base;
  my $attrs    = {};
  my $state    = 'NORMAL';
  my $attr     = undef;
  my $type     = 'elem';
  my $t;

  for(;;){

    $t = $base->next_token;

    goto ERROR unless defined $t;

    my $tt  = $t->[0];

    ($tt eq 'SPACES') and do{
      next;
    };

    ($tt eq '=') and do{
      ($state eq '=') and do{
	$state = 'VALUE';
	next;
      };
      goto ERROR;
    };

    ($tt eq 'TEXT') and do{

      ($state eq 'NORMAL') and do{
	$state = '=';
	$attr  = $t->[1];
	next;
      };

      ($state eq 'VALUE') and do{
	$state = 'NORMAL';
        goto ERROR unless(eval{
          $elem->setAttribute($attr, $t->[1]);
          1;
        });
	undef $attr;
	next;
      };

      ($state eq 'COMMENT') and do{
	next;
      };

      goto ERROR;
    };

    ($tt eq 'BEGIN_COMMENT') and do{
      ($state eq 'NORMAL') and do{
	$state = 'COMMENT';
	next;
      };

      goto ERROR;
    };

    ($tt eq 'END_COMMENT') and do{
      ($state eq 'COMMENT') and do{
	$state = 'NORMAL';
	next;
      };
      goto ERROR;
    };

    ($tt eq '/') and do{
      ($state eq 'NORMAL') and do{
	$type = 'net';
	last;
      };
      goto ERROR;
    };

    ($tt eq '>') and do{
      ($state eq 'NORMAL') and do{
	last;
      };
      goto ERROR;
    };
  }

  return [
          OPEN_ELEM => $elem,
          tag_type  => $type,
          %info,
          qname     => $name,
         ];


 ERROR:
  $base->unget_token($t);
  [
   OPEN_ELEM => $elem,
   tag_type  => 'empty',
   error     => 1,
   %info,
   qname     => $name,
  ];
}

############################################################

sub parse_comment_decl{
  my ($this, $tok) = @_;
  my $state    = 'COMMENT';
  my $comm     = $this->element_builder->gencomm('');
  my $base = $this->base;
  my $buf  = '';

  for(;;){
    my $tok = $base->next_token;
    goto ERROR unless defined $tok;
    my $tt  = $tok->[0];

    $tt eq 'END_COMMENT' and do{
      $state eq 'COMMENT'and do{
	$state = 'NORMAL';
	$comm->appendData($buf);
	$buf = undef;
      };
    };

    $tt eq '>' and do{
      $state eq 'NORMAL' and do{
	$comm->appendData($buf) if defined $buf;
	last;
      }
    };

    $tt eq 'BR' and do{
      $state eq 'COMMENT' and do{
	$tt = 'TEXT';
	$tok = [$tt => "\n"];
      }
    };

    $tt eq 'BEGIN_COMMENT' and do{
      $state eq 'NORMAL' and do{
	$state = 'COMMENT';
	$buf = '';
      };
    };

    $tt eq 'TEXT' and do{
      $state eq 'COMMENT' and do{
	$buf .= $tok->[1];
      };
    };
  }

 ERROR:
  [COMMENT_DECL => $comm]
}



with qw( Text::PAN::Role::Tokenizer );

1;
__END__

package Text::PAN::Tokenizer::Base;

use Any::Moose;

use Text::PAN::Stream;
use HTML::Entities qw( decode_entities );

my $RE_QNAME = qr{[^\s<>!"'/]+};
my $RE_QUOT = qr{(?:'(?:[^']|\\')*'|"(?:[^"]|\\")*")}x;

has in => ( is => 'ro' );
has states => ( is      => 'rw',
                isa     => 'ArrayRef[Str]',
                default => sub{['HEADER']} );


has indent_stack => ( is      => 'ro',
                     isa     => 'ArrayRef',
                     default => sub{[0]} );

has net_depth => ( is => 'rw',
                   isa => 'Num',
                   default => sub{0});

has section_depth => ( is => 'ro',
                       isa => 'ArrayRef',
                       default => sub{[0]});

has context_stack => ( is => 'ro',
                       isa => 'ArrayRef',
                       default => sub{['NORMAL']});

has headeractions => (
                      is       => 'ro',
                      isa      => 'HashRef',
                      default  => sub{+{}},
                     );

has done => (
             is => 'rw',
             isa => 'Bool',
             default => sub{0},
            );



sub new {
  my $this = shift;
  my %opt  = @_ % 2 ? (src => @_) : @_;
  my $src = delete $opt{src};
  $this->SUPER::new(
                    in => Text::PAN::Stream::gen($src),
                    %opt
                   );
}

sub state {
  my $this = shift;
  return $this->states->[0] unless @_;
  $this->states->[0] = shift;
}

sub push_state {
  my $this = shift;
  my $state = shift;
  unshift @{$this->states}, $state;
}

sub pop_state{
  my $this = shift;
  shift @{$this->states};
}


###

sub current_section_depth {
  my $st = $_[0]->section_depth;
  ${$st}[$#$st];
}

sub prev_section_depth {
  my $st = $_[0]->section_depth;
  my $p  =  $#$st;
  ${$st}[$p ? $p - 1 : 0];
}

sub section_indent {
  my ($this, $depth) = @_;
  push @{$this->section_depth}, $depth;
  push @{$this->buf}, [
                       SECTION_IN => '',
                       line       => $this->in->line,
                       src        => '',
                      ];
}

sub section_dedent {
  my ($this, $depth) = @_;
  my $st = $this->section_depth;
  pop @{$this->section_depth};
  my $has_rest =  @{$this->section_depth};
  push @{$this->buf}, [
                       SECTION_OUT => '',
                       line        => $this->in->line,
                       src         => '',
                      ];
  $has_rest;
}

sub section_dedentp {
  my ($this, $depth) = @_;
  my $cur  = $this->current_section_depth;
  my $prev = $this->prev_section_depth;
  return 0 if $depth  > $cur;
  return 1 if $depth == $cur;
  $depth <= $prev;
}

sub section_indentp {
  my ($this, $depth) = @_;
  $this->current_section_depth < $depth;
}

sub check_section_dedent {
  my ($this, $depth) = @_;
  return 0 unless $this->section_dedentp( $depth );
  $this->section_dedent while $this->section_dedentp( $depth );
  return 1;
}


###

sub current_indent {
  my $st = $_[0]->indent_stack;
  ${$st}[$#$st];
}

sub prev_indent {
  my $st = $_[0]->indent_stack;
  my $p  =  $#$st;
  ${$st}[$p ? $p - 1 : 0];
}

sub indent {
  my ($this, $context, $indent) = @_;
  my $src = " " x $indent;
  push @{$this->buf}, [
                       INDENT => $src,
                       src    => $src,
                       line   => $this->in->line,
                      ];
  $this->push_context($context);
  push @{$this->indent_stack} , $indent;
}

sub dedent {
  my ($this) = @_;
  my $st  = $this->indent_stack;
  my $src = " " x $st->[-1];
  push  @{$this->buf}, [
                        DEDENT => $src,
                        src    => $src,
                        line   => $this->in->line,
                       ];
  return 0 if 1 == @$st;
  pop @{$st};
  $this->pop_context;
}

sub dedentp {
  my ($this, $indent) = @_;
  my $cur  = $this->current_indent;
  my $prev = $this->prev_indent;
  return 0 if $cur <= $indent;
  $indent <= $prev;
}

sub indentp {
  my ($this, $indent) = @_;
  my $cur = $this->current_indent;
  $cur < $indent;
}

sub check_dedent {
  my ($this, $width) = @_;
  return 0 unless $this->dedentp( $width );
  $this->dedent while $this->dedentp( $width );
  1;
}

sub current_context {
  my $ctx = $_[0]->context_stack;
  $ctx->[$#$ctx];
}

sub push_context {
  my $ctx = $_[0]->context_stack;
  push @$ctx, $_[1];
}

sub pop_context {
  my $ctx = $_[0]->context_stack;
  pop @$ctx;
}

sub __unescape{
  my $src = shift;
  decode_entities($src);
}

sub _text_token{
  my ($this, $val, %info) = @_;
  [
   TEXT => __unescape($val),
   %info
  ];
}


sub _next_token {

  my ($this) = @_;
  return undef if $this->done;


  my $buf  = $this->buf;
  my $in   = $this->in;
  my $line = $in->next_line;

  unless( defined $line ){
    $this->done(1);# return undef;
    $this->dedent while 1 < @{$this->indent_stack};
    $this->section_dedent(1) while 1 < @{$this->section_depth};
    return $this->next_token;
  }

  my $state = $this->state;
  $state eq 'HEADER' and do{
    $line =~ /\A\s*\Z/ and return $this->next_token;

    $line =~ /\A=\s*(.*)/ and do{
      my $title = $1;
      ($this->headeractions->{title}||sub{})->($title);
      return $this->next_token;
    };

    $line =~ /\A\s*\@xmlns:([^=\s]+)=(\S+)/ and do{
      my $prefix = $1;
      my $value  = $2;
      if($value =~ /\A'/ and $value =~ /'\Z/){
        $value =~ s/\A.|.\Z//g;
        $value =~ s/\\(.)/$1/g;
      }
      elsif($value =~ /\A"/ and $value =~ /"\Z/){
        $value =~ s/\A.|.\Z//g;
        $value =~ s/\\(.)/$1/g;
      }
      ($this->headeractions->{xmlns}||sub{})->($prefix, $value);
      return $this->next_token;
    };

    $state = $this->state('NEWLINE');

  };


  ####################
  $state eq 'IN_COMMENT' and do{

    $line =~ s/\A--// and do{
      $in->unget_line($line);
      $this->pop_state;
      return [
              END_COMMENT => '--',
              src         => '--',
              line        => $in->line
             ];
    };

    $line =~ s/\A((?:[^\-]|-(?!-))+)// and do{
      $in->unget_line($line) if length $line;
      return [
              TEXT => __unescape($1),
              src  => $1,
              line => $in->line
             ];
    };

    die "panic";
  };

  ####################
  $state eq 'IN_TAG' and do{

    $line =~ /\A\s*\Z/ and do{ return $this->next_token; };

    $line =~ s/\A(\s+)// and do{
      $in->unget_line($line);
      return [
              SPACES => $1,
              src    => $1,
              line   => $in->line
             ];
    };

    $line =~ s/\A>// and do{
      $in->unget_line($line);
      $this->pop_state;
#warn ">:".$in->line;
      return [
              '>'         => '>',
              src         => '>',
              line        => $in->line,
              end_of_line => $line =~ /\A\s*\Z/ ? 1 : 0,
             ];
    };

    $line =~ s/\A\/// and do{
      $in->unget_line($line);
      $this->pop_state;
      $this->net_depth($this->net_depth + 1);
      return [
              '/'  => '/',
              src  => '/',
              line => $in->line
             ];
    };

    $line =~ s/\A--// and do{
      $in->unget_line($line);
      $this->push_state('IN_COMMENT');
      return [
              BEGIN_COMMENT => '--',
              src           => '--',
              line          => $in->line,
             ];
    };

    $line =~ s/\A=// and do{
      $in->unget_line($line);
      return [
              '='  => '=',
              src  => '=',
              line => $in->line
             ];
    };

    $line =~ s/\A(["'])// and do{
      $in->unget_line($line);
      return $this->get_string($1);
    };

    $line =~ s#\A([^=\s>/]+)## and do{
      $in->unget_line($line);
      return [
              TEXT => __unescape($1),
              src  => $1,
              line => $in->line
             ];
    };

    die "panic!! '$line'";
  };


  ####################
  $state eq 'NEWLINE' and do{
    return [
            BL   => $line,
            src  => $line,
            line => $in->line,
           ] if $line =~ /\A\s*\Z/;

    $this->state('INLINE');



    ## SECTION_HEADER
    $line =~ s/\A(\*+)[ \t]*// and do{
      $this->state('SECTION_HEADER');
      $in->unget_line($line);
      my $width = length $1;
      $this->check_dedent(0);
      $this->check_section_dedent($width);
      $this->section_indent($width);
      push @$buf, [
                   'SECTION_HEADER' => $1,
                   src              => $1,
                   line             => $in->line
                  ];
      return $this->next_token;
    };

    ## TAG_START ( begining_of_line => 1 )
    $line =~ s/\A((?:<(?=<))+)// and do{
      $in->unget_line($line);
      push @$buf, [
                   TEXT => $1,
                   src  => $1,
                   line => $in->line
                  ];
      return $this->next_token;
    };
    $line =~ s{\A(\s*)<(?![!/])((?:$RE_QNAME)?)}{} and do{
      $in->unget_line($line);
      my $ind_width = length $1;
      my $qname     = $2;
      $this->check_dedent( $ind_width );
      push @$buf, [
                   TAG_START        => $qname,
                   src              => "<$qname",
                   line             => $in->line,
                   begining_of_line => 1,
                  ];
      $this->push_state('IN_TAG');
      return $this->next_token;
    };

    $line =~ s/\A(<!--)// and do{
      $this->in->unget_line($line);
      $this->push_state('IN_TAG');
      $this->push_state('IN_COMMENT');
      return [
              BEGIN_COMMENT_DECL => '<!--',
              src                => '<!--',
              line               => $in->line,
              begining_of_line   => 1,
             ];
    };





    ## HR
    $line =~ s/\A(\s*)(--+)(?:\x0d\x0a|[\x0d\x0a]|\Z)// and do{
      my $width = length $1;
      $this->check_dedent( $width );
      push @$buf, [
                   HR   => $2,
                   src  => $2,
                   line => $in->line,
                  ];
      $this->state('NEWLINE');
      return $this->next_token;
    };


    ## ULBULLET
    $line =~ s/\A(\s*-(?!-)[ \t]*)(?![\x0d\x0a])// and do{
      $in->unget_line( $line );
      my $width = length $1;
      $this->check_dedent( $width );

      if( $this->indentp($width) ){
        $this->indent( UL => $width );
      }
      elsif( $this->current_context ne 'UL' ){
        $this->dedent;
        $this->indent( UL => $width );
      }

      push @$buf,[
                  ULBULLET => $1,
                  src      => $1,
                  line     => $in->line,
                 ];
      return $this->next_token;
    };

    ## SPECIAL VERB
    $line =~ s/>\|((?:[^|]|$RE_QUOT)*)\|// and do{
      return $this->get_special_verb($1);
    };

    ## OLBULLET
    $line =~ s/\A(\s*\+[ \t]*)(?![\x0d\x0a])// and do{
      $in->unget_line($line);
      my $width = length $1;
      $this->check_dedent($width);
      if( $this->indentp($width) ){
        $this->indent( OL => $width);
      } elsif ( $this->current_context ne 'OL'){
        $this->dedent;
        $this->indent(OL => $width);
      }
      push @$buf, [
                   OLBULLET => $1,
                   src      => $1,
                   line     => $in->line,
                  ];
      return $this->next_token;
    };

    ## DTSTART
    $line =~ s/\A(\s*::\s*)// and do{
      $in->unget_line($line);
      my $width = length $1;
      $this->check_dedent( $width );
      if( $this->indentp($width) ){
        $this->indent(DL => $width);
      } elsif ( $this->current_context ne 'DL'){
        $this->dedent;
        $this->indent(DL => $width);
      }
      push @$buf, [
                   DTSTART => $1,
                   src     => $1,
                   line    => $in->line
                  ];
      $this->state('DT');
      return $this->next_token;
    };


    ##
    $line =~ s/\A(\s*)//;
    my $width = length $1;
    if( $this->check_dedent( $width ) ){
      $in->unget_line($line);
      return $this->next_token;
    }

    return $this->get_verb($width, $1 . $line)
      if $this->indentp($width);
  };

  ####################
  $this->net_depth and $line =~ s#\A>## and do{
      $in->unget_line($line);
      $this->net_depth($this->net_depth - 1);
      return [
              '>'         => '>',
              line        => $in->line,
              src         => '>',
              end_of_line => $line =~ /\A\s*\Z/ ? 1 : 0,
             ];
  };


  ####################
  #   $state eq 'REF_NL' and do{
  #     $line =~ s/\A\s+/ /;
  #     $this->pop_state;
  #     return $this->next_token;
  #   };

  ####################
  $this->read_line($line);
}

sub read_line{
  my ($this, $line) = @_;
  my $in    = $this->in;
  my $state = $this->state;

  $line =~ /\A(\s*)\Z/ and do{
    $state =~ m/\A(?:
                  REF
                )\Z/x and do{
      $this->push_state($state.'_NL');
      return $this->next_token;
    };
    $this->state('NEWLINE');
    return [
            BR   => $1,
            src  => $1,
            line => $in->line,
           ] if $state eq 'SECTION_HEADER';
    return $this->next_token;
  };


  $line =~ s/\A\\([:\\<>\/\-'"=\[\]])// and do{
    $this->in->unget_line($line);
    return [
            TEXT => __unescape($1),
            src  => $1,
            line => $in->line
           ];
  };

  $line =~ s/\A(\s*::\s*)// and do{
    $this->in->unget_line($line);
    if($this->state eq 'DT'){
      $this->state('INLINE');
      return [
              DTEND => $1,
              src   => $1,
              line  => $in->line,
             ];
    }
    else{
      return [
              TEXT => $1,
              src  => $1,
              line => $in->line,
             ];
    }
  };

  if($state ne 'REF'){
    $line =~ s/\A(\[\[)// and do{
      $this->in->unget_line($line);
      $this->push_state('REF');
      return [
              REFSTART => '[[',
              src      => '[[',
              line     => $in->line,
             ];
    };
  }else{
    $line =~ s/\A(\]\])// and do{
      $this->in->unget_line($line);
      $this->pop_state;
      return [
              REFEND => ']]',
              src    => ']]',
              line   => $in->line
             ];
    };
  }

  $line =~ s/\A(<!--)// and do{
    $this->in->unget_line($line);
    $this->push_state('IN_TAG');
    $this->push_state('IN_COMMENT');
    return [
            BEGIN_COMMENT_DECL => '<!--',
            src                => '<!--',
            line               => $in->line
           ];
  };

  $line =~ s/\A((?:<(?=<))+)// and do{
    $this->in->unget_line($line);
    return [
            TEXT => $1,
            src  => $1,
            line => $in->line,
           ];
  };

  $line =~ s/\A<\/((?:$RE_QNAME)?)// and do{
    $this->in->unget_line($line);
    $this->push_state('IN_TAG');
    return [
            ENDTAG_START => $1,
            src          => "</$1",
            line         => $in->line,
           ];
  };

  $line =~ s{\A<(?![/!])((?:$RE_QNAME)?)}{} and do{
    $this->in->unget_line($line);
    $this->push_state('IN_TAG');
    return [
            TAG_START => $1,
            src       => "<$1",
            line      => $in->line,
           ];
  };

  $line =~ s#\A((?:
                 [^:\\<>\[\]]|
                 -(?!-)|
                 :(?!:)|
                 \[(?!\[)|
                 \](?!\])|
                 \\(?![:\\<>\[\]]))+)
            ##x and do{

    $in->unget_line($line);
    return [
     TEXT => __unescape($1),
     src  => $1,
     line => $in->line
    ]
  };


  $line =~ s#\A(.)## and do{
    $in->unget_line($line);
    return [
     TEXT    => __unescape($1),
     src     => $1,
     line    => $in->line,
     strange => 1,
    ]
  };

  $this->state('NEWLINE');
  $this->next_token;

}


sub get_special_verb{
  my ($this, $attr_src) = @_;
  my $data = "\n";
  my $min  = 32766;
  my $line = '';
  for(;;){
    $line = $this->in->next_line;
    last unless $line;
    last if $line =~ /\A\s*\|\|<\s*\Z/;
    $line =~ m#\A(\s*)#;
    my $depth = length $1;
    $min   = $depth if $depth < $min;
    $data .= $line;
  }
  $data =~ s/\x0d\x0a|[\x0d\x0a]/\n/g;
  $data =~ s/(\A|\n) {$min}/$1/g;
  $data =~ s/\n[\n\s]*\Z/\n/;
  $this->state('NEWLINE');
  my $attrs = $attr_src ? {type => $attr_src} : {};
  $line = "" unless defined $line;
  [
   SPE_VERB => {data  => substr($data, 1),
                attrs => $attrs},
   src      => ">|$attr_src|$data$line",
   line     => $this->in->line
  ];
}

sub get_verb{
  my ($this, $width, $buf) = @_;
  $buf =~ /\A(\s+)/;
  my $min = length $1;
  my $in = $this->in;
  for(;;){
    my $line = $in->next_line;
    last unless defined $line;
    if($line =~ /\A\s*\Z/){
      $buf .= "\n";
      next;
    }
    $line =~ /\A(\s*)/;
    my $depth = length $1;
    unless($this->indentp( $depth )){
      $in->unget_line($line);
      last;
    }
    $min = $depth if $depth < $min;
    $buf .= $line;
  }
  $buf =~ s/\x0d\x0a|[\x0d\x0a]/\n/g;
  $buf =~ s/(\A|\n) {$min}/$1/g;
  $buf =~ s/\n[\n\s]*\Z/\n/;
  $this->state('NEWLINE');
  [
   VERB => $buf,
   src  => $buf, #FIXME:
   line => $in->line
  ];
}

sub get_string{
  my ($this, $quote) = @_;
  my $in   = $this->in;
  my $end  = qr{$quote};
  my $body = qr{(?:[^$quote]|\\[$quote])+};
  my $buf  = "";
  while( my $line = $in->next_line ){
    ($line =~ s/\A$end//) and do{
      $in->unget_line($line) if length $line;
      my $src = $buf;
      $buf =~ s/\\$quote/$quote/eg;
      return [
              TEXT => __unescape($buf),
              src  => $src,
              line => $in->line,
             ];
    };
    $line =~ s/\A($body)// and do{
      $buf .= $1;
      $in->unget_line($line) if length $line;
    };
  }
}

with qw(Text::PAN::Role::Tokenizer);


1
__END__

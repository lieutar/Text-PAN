package Text::PAN::Parser::Methods;

use strict;
use warnings;
use Text::PAN::CONSTANTS qw(:all);
use UNIVERSAL qw(isa);
use XML::LibXML;
use Carp;

sub import {
  my ($caller) = caller;
  return unless $caller eq 'Text::PAN::Parser';
  my $src = \%Text::PAN::Parser::Methods::;
  foreach my $sym (keys %$src){
    next if $sym =~ /\A(?:import|BEGIN|END|AUTOLOAD)\Z/;
    my $glob = $src->{$sym};
    next unless $glob && (isa($glob, 'GLOB') || isa(\$glob, 'GLOB'));
    my $code = *{$glob}{CODE};
    next unless $code;
    no strict 'refs'; 
    *{"Text::PAN::Parser::$sym"} = $code;
  }
}

############################################################


sub parse {
  my ($this, %opt) = @_;

  my $yydata   = $this->YYData;
  my $root     = $opt{root} ;
  my $context  = $opt{context};
  my $doc      = $root->ownerDocument;
  my $ebuilder = $opt{element_builder};
  my $tkn      = $opt{tokenizer};


  $yydata->{DOC}           = $doc;
  $yydata->{ROOT}          = $root;
  $yydata->{DATA}          = [$doc];
  $yydata->{CONTEXT}       = $context;
  $yydata->{PREELEMENT}    = undef;
  $yydata->{ELEMENT_STACK} = [];
  $yydata->{TOKENIZER}     = $tkn;
  $yydata->{EBUILDER}      = $ebuilder;

  my $first    = 1;
  my $dots     = '';
  my @last_token = ();
  $this->YYParse(

    yylex => sub{
      my $token;
      do{
        $token  = $tkn->next_token()
      } while $first and $token and $token->[0] eq 'BL';
      $first = 0;
      return ('',undef) unless defined $token;;
      push @last_token, $token->[0];
      if(@last_token > 10){
        $dots = '...';
        shift @last_token;
      }
      @$token
    },

    yyerror => sub{
      my $this = shift;
      my $in    = $tkn->in;
      my $stack = $this->{STACK};
      confess ( 'PARSER ERROR at ', $in->file.' line '.$in->line."\n".
            'last token:'. join(" ",$dots, @last_token) . "\n".
            "stack:".join(" ",map $_->[0], @$stack)."\n".
            "near: \n". do{
              my @ar =  $in->src_around();
              join "", map sprintf("%s%04d:%s",
                                   ($_->[0] == $in->line ? '>' : ' '),
                                   @$_), @ar;
            });
    });

  $root;
}


sub doc       { $_[0]->YYData->{DOC} }
sub root      { $_[0]->YYData->{ROOT}   }
sub context   { $_[0]->YYData->{CONTEXT}   }
sub tokenizer { $_[0]->YYData->{TOKENIZER} }
sub element_builder{ $_[0]->YYData->{EBUILDER} }

foreach my $meth (qw(close_elem genelem gencomm addchildren value_of)){
  no strict 'refs';
  *$meth = sub{ shift->element_builder->$meth(@_) };
}

1;
__END__

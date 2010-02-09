use strict;
use warnings;

package t::lib::Tokenizer::TestLib;

use base qw( Exporter );
use Test::More;
use Data::Dumper;


our $Builder = undef;
our @EXPORT_OK = qw(hr testt);
our %EXPORT_TAGS = (all => \@EXPORT_OK);

sub hr{ diag '-'x60; }

my @diag = ();

sub _msg{
  push @diag, [@_];
}

sub testt{
  @diag = ();
  my $src = pop @_;
  my $t = $Builder->( $src );
  my $tt;
  while(@_){

    my $tok = shift;
    $tt = $t->next_token || ['*undef*'];

    if(UNIVERSAL::isa($tok, 'ARRAY')){

      _msg '[',$tok->[0],',', $tok->[1],']',
        ' [',$tt->[0],', ', ($tt->[1]||''),']';
      goto FAIL if $tt->[0] ne $tok->[0];

      my $test = $tok->[1];
      if(UNIVERSAL::isa($test,'CODE')){

        goto FAIL unless $test->($tt->[1]);

      } elsif(defined $test) {

        next unless $test ne $tt->[1];
        _msg $test,  ' != ', $tt->[1];
        goto FAIL;

      } else {

        goto FAIL if defined $tt->[1];

      }
    } else {

      _msg $tok,"\t", $tt->[0];
      next unless $tt->[0] ne $tok;
      goto FAIL;

    }
  }
  pass;
  return;

 FAIL:
  my ($type, $val, %info) = @$tt;
  _msg "TOKEN: $type";
  if($type =~ /ELEM/){
    _msg "VALUE:". $val->toString;
  }
  elsif (ref($val)){
    _msg "VALUE:".Dumper($val);
  }
  else{
    _msg "VALUE:$val"
  }
  _msg Dumper \%info;

  hr;
  diag $src;
  hr;
  diag @$_ foreach @diag;
  fail
}


1;
__END__


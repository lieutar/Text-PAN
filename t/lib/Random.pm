use strict;
use warnings;
package t::lib::Random;

use base qw( Exporter );
our @EXPORT = qw( randomtext00 );

sub randomtext00{
  my $R = shift;
  my $width = shift || 4096;
  $$R = '';
  for(my $i=0;$i < $width;$i++){
    my $b    =
      (int rand 4) > 1 ? 1 : (int rand 3) > 1 ? 0 : (int rand 3) > 1 ? 3 : 2;
    my $n = int rand [0x20, 0x7f-0x20, 0x20, 0x7f-0x20]->[$b];
    $n += [0, 0x20, 0x80, 0xa0]->[$b];
    $$R .= chr $n;
  }
}


1;
__END__

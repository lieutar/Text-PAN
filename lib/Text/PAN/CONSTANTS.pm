package Text::PAN::CONSTANTS;

use strict;
use warnings;

our @EXPORT_OK;
our %EXPORT_TAGS = (all => \@EXPORT_OK);

BEGIN{
  require constant;
  foreach my $def
    ([
      NS         => 'tag:neoteny.sakura.ne.jp,2009:xmlns/pad',
     ],
     [
      NS_ILLEGAL => 'tag:neoteny.sakura.ne.jp,2009:xmlns/pad-illegal',
     ]){
    my ($key, $val) = @$def;
    constant->import($key, $val);
    push @EXPORT_OK, $key;
  };
}


use base qw(Exporter);



1;
__END__


=head1 NAME

Text::PAN::CONSTANTS - Exports constants for Text::PAN

=head1 DESCRIBES

=head1 CONSTANTS

=head2 NS

=head2 NS_ILLEGAL


=cut

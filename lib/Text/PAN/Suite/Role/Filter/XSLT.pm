package Text::PAN::Suite::Role::Filter::XSLT;
use Any::Moose '::Role';
use XML::LibXML;
use XML::LibXSLT;

requires qw(
             xslt
          );

sub functions{}
sub do_filter{
  my ($this, $src, %opt) = @_;
  my $style_doc   = $this->xslt;
  my $xslt_obj    = XML::LibXSLT->new;
  my $stylesheet  = $xslt_obj->parse_stylesheet($style_doc);
  foreach my $spec ($this->functions){
    my ($ns, $name, $impl) = @$spec;
    $xslt_obj->register_function($ns, $name, $impl);
  }
  my $rs  = $stylesheet->transform($src);
  return $stylesheet->output_as_chars($rs) if $opt{as_string};
  $rs;
}

with qw( Text::PAN::Suite::Role::Filter );


1;
__END__

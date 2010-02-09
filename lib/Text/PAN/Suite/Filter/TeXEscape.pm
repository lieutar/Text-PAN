package Text::PAN::Suite::Filter::TeXEscape;
use Any::Moose;
use XML::LibXML;
use Text::PAN::CONSTANTS 'NS';
use URI::Escape;

our $REGEX_GLOB = qr{#|\$|\%|\&|_|\{|\}|\\|<|>|\bLaTeX(?:e)?\b|\bTeX\b};
our $REGEX_VERB = qr{#|\$|\%|\&|_|\{|\}};
our $REGEX      = $REGEX_GLOB;

sub __each_nodes{
  my ($n, $cb) = @_;
  $cb->($n);
  $REGEX = ($n->nodeType     == XML_ELEMENT_NODE &&
            $n->namespaceURI eq NS &&
            $n->localName    eq "verb") ? $REGEX_VERB : $REGEX_GLOB;
  foreach my $c ($n->childNodes){
    __each_nodes($c, $cb);
  }
}

my %syms = (
            '#'     => '\#',
            '$'     => '\$',
            '%'     => '\%',
            '&'     => '\&',
            '_'     => '\_',
            '{'     => '\{',
            '}'     => '\}',
            '<'     => '{$<$}',
            '>'     => '{$>$}',
            '\\'    => '{\textbackslash}',
            TeX     => '{\TeX}',
             LaTeX  => '{\LaTeX}',
             LaTeXe => '{\LaTeXe}',
           );

sub do_filter{
  my ($this, $src, %opt) = @_;
  my $doc = $src->ownerDocument;
  __each_nodes
    ($src,
     sub{
       my ($node) = @_;
       return if($node->nodeType != XML_TEXT_NODE);
       my $parent = $node->parentNode;
       my $data = $node->nodeValue;
       $data =~ s/($REGEX)/$syms{$1};/ge;
       my $new  = $doc->createTextNode($data);
       $parent->replaceChild($new, $node);
       $parent->normalize;
     });
  return $src unless $opt{as_string};
  $src->toString;
}


with qw( Text::PAN::Suite::Role::Filter );

1;
__END__


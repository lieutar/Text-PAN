
use strict;
use warnings;

package t::lib::Parser::TestLib;
use Test::More;
use UNIVERSAL qw(isa);
use Data::Dumper;
use B qw(perlstring);
use base qw(Exporter);
our @EXPORT = qw( test );

my @msg = ();

sub _msg {
  push @msg, [@_];
}

sub commentp {
  my $struct = shift;
  return 0 unless isa($struct, 'ARRAY');
  $struct->[0] eq '#';
}

sub elemp {
  my $struct = shift;
  isa($struct, 'ARRAY') && $struct->[0] ne '#';
}

sub textp{
  my $struct = shift;
  isa($struct, 'Regexp') || !ref($struct);
}

sub checkTree {
  my ($node, $struct) = @_;

  _msg "."x60;
  _msg $node->toString;

  return 0 unless defined $struct;

  commentp($struct) and do{
    return 0 unless $node->nodeType == XML::LibXML::XML_COMMENT_NODE;
    my $value = pop @$struct;
    return 1 unless defined $value;
    return $value eq $node->nodeValue;
  };

  elemp($struct) and do{
    return 0 unless $node->nodeType == XML::LibXML::XML_ELEMENT_NODE;

    my $name     = shift @$struct;
    my $children = pop( @$struct );
    my %attrs     = @$struct;

    unless( $node->localName eq $name ){
      _msg $node->localName . " ne $name";
      return 0;
    }

    while( my($attr, $value) = each %attrs ){
      next if ($node->getAttribute($attr)||'') eq ($value || '');
      _msg "$attr: ".($node->getAttribute($attr)||'') ." ne ". ($value || '');
      return 0;
    }

    my @childNodes = $node->childNodes;

    unless( @childNodes == @$children ){
      _msg ((scalar @childNodes).' == '.(scalar @$children));
      _msg join "\n", map {$_->toString} @childNodes;
      _msg Dumper $children;
      return 0;
    }

    for(my $i=0; $i < @childNodes; $i++ ){
      return 0 unless checkTree($childNodes[$i], $children->[$i]);
    }

    return 1;

  };

  textp($struct) and do{
    if(isa($struct, 'Regexp')){
      return 0 unless $node->nodeValue =~ $struct;
    } else {
      _msg '---';
      _msg perlstring $node->nodeValue;
      _msg '---';
      _msg perlstring $struct;
      return 0 unless $node->nodeValue eq $struct;
    }
    return 1;
  };
}

sub test {
  my ($struct, $src, $t) = @_;
  @msg = ();
  my $doc = Text::PAN::parse $src;
  _msg $src;
  _msg "-"x60;
  _msg $doc->toString;
  _msg "-"x60;
  my $root = $doc->documentElement;
  my $result = checkTree($root, $struct);
  ok($result, $t);
  return if $result;
  diag @$_ foreach @msg;
}

1;
__END__

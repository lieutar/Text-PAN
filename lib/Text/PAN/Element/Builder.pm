package Text::PAN::Element::Builder;
use Any::Moose;
use XML::LibXML;
use Text::PAN::CONSTANTS qw(NS NS_ILLEGAL);
use UNIVERSAL qw(isa can);
use Scalar::Util qw(blessed);

has doc => (
	    is => 'ro',
	    lazy_build => 1,
	   );


has nsdic => (
              is      => 'ro',
              isa     => 'HashRef',
              default => sub{+{}},
             );


sub register_namespace_prefix{
  my ($this, $prefix, $uri) = @_;
  $this->nsdic->{$prefix} = $uri;
}


sub lookup_namespace_prefix{
  my ($this, $prefix) = @_;
  $this->nsdic->{$prefix} || NS_ILLEGAL;
}


sub value_of{
  my ($this, $children) = @_;
  my $R = "";
  foreach my $n (@$children){
    if(blessed $n){
      $R .= $n->textContent;
    }
    else{
      $R .= $n;
    }
  }
  $R;
}


sub _build_doc{
  my ($this) = @_;
  XML::LibXML::Document->createDocument(1, 'utf8');
}


sub close_elem {
  my ($this, $elem, $body, $closer ) = @_;

  my $ns = NS;
  if($closer =~ /:/){
    (my $prefix, $closer) = split(/:/, $closer, 2);
    $ns = $this->lookup_namespace_prefix($prefix);
  }

  my $ens       = $elem->namespaceURI;
  my $localname = $elem->localName;
  die "end tag mismatch: $localname != $closer" if( $closer and $closer ne $localname );
  die "end tag ns mismatch: $ens != $ns" if $ns ne $ens;
  $this->addchildren($elem, $body);
  $elem;
}


sub genelem {
  my ($this, $tag, $children, $attrs) = @_;

  my $ns   = NS;

  if($tag =~ /:/){
    (my $prefix, $tag) = split(/:/, $tag, 2);
    $ns = $this->lookup_namespace_prefix($prefix);
  }

  my $doc  = $this->doc;
  my $elem;
  unless(eval{$elem = $doc->createElementNS($ns, $tag); 1}){
    my $err  = $@;
    if($err =~ /\bbad name\b/){
      confess "bad name: $tag";
    }
    confess $err;
  }

  confess "4th argument must be a hash reference."
    if $attrs && (ref($attrs) || '') ne 'HASH';

  my %attrs = %{$attrs || {}};

  while(my($attr, $val) = each %attrs){
    $elem->setAttribute($attr, $val);
  }

  $this->addchildren($elem, $children);
  $elem;
}


sub gencomm {
  my ($this, $comments) = @_;
  my $doc = $this->doc;
  $doc->createComment($comments);
}


sub addchildren {
  my ( $this, $elem, $children ) = @_;
  confess "illegal element " unless ( UNIVERSAL::can($elem, 'nodeType') and
                                      UNIVERSAL::can($elem, 'localName') );
  my $doc = $this->doc;
  foreach my $child (@{$children || []}){
    if(isa( $child, 'XML::LibXML::Node' )){
      $elem->appendChild($child);
    } else {
      $elem->appendChild($doc->createTextNode(defined $child ? $child : ''));
    }
  }
  $elem->normalize;
  $elem;
}

1;
__END__

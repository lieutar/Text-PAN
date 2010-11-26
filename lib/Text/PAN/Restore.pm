package Text::PAN::Restore;
use Text::PAN::CONSTANTS qw(NS);
use XML::LibXML;
use Any::Moose;

sub restore{
  my ($this, $src) = @_;
  my $root = $src->documentElement;
  $this->_restore_elem($root);
}

sub _restore{
  my ($this, $node) = @_;
  my $nt = $node->nodeType;
  $this->can(
             +{
               XML_ELEMENT_NODE, '_restore_elem',
               XML_COMMENT_NODE, '_restore_comment',
              }->{$nt} ||
             '_restore_unknown'
            )->($this, $node);
}

############################################################
sub _restore_unknown{
}


############################################################

sub _restore_elem{
  my ($this, $elem) = @_;
  my $ns   = $elem->namespaceURI;
  ((($ns eq NS) and do{
    my $name = $elem->localName;
    $this->can("_restore_elem_$name");
  }) || $this->can('_restore_generic_elem'))->($this, $elem);
}

sub _restore_generic_elem{
  my ($this, $elem) = @_;
}

sub _restore_elem_article{
}

sub _restore_elem_section{
}

sub _restore_elem_p{
}

sub _restore_elem_hr{
}

sub _restore_elem_ul{
}

sub _restore_elem_ol{
}

sub _restore_elem_dl{
}

sub _restore_elem_ref{
}

sub _restore_elem_verb{
}

############################################################

sub _restore_comment{
}


1;
__END__

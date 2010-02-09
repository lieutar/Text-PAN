package Text::PAN;
use Any::Moose;

=head1 NAME

Text::PAN - Converts PAN(Pretty Article Notation) to XML Document.

=head1 VERSION

This document describes Text::PAN version 0.0.1

=cut

our $VERSION = q('0.0.3');



=head1 SYNOPSIS

    use Text::PAN;

=head1 DESCRIPTION


=head1 METHODS

=head2 parse

=cut

use Text::PAN::CONSTANTS qw( NS );
use Text::PAN::Parser;
use Text::PAN::Parser::Context;
use Path::Class;
use Text::OutputFilter;

our $DEBUG  =   my $debug = ($ENV{YYDEBUG} || 0) - 0;
our $OUTPUT = file(file(__FILE__)->parent, 'PAN', 'Parser.output');

has debug => (
              is      => 'ro',
              isa     => 'Num',
              default => sub{$DEBUG},
             );

has states => (
               is         => 'ro',
               isa        => 'ArrayRef',
               lazy_build => 1,
               auto_deref => 1,
              );

sub _build_states{
  my ($this) = @_;
  my @states = ();
  my $fh = $OUTPUT->openr;
  if($fh){
    my $buf = undef;
      my $state = undef;
    while(my $line = <$fh>){
      if( $line =~ /\AState (\d+):/ ){
        if(defined($state)){
          $states[$state] = $buf;
        }
        $state = $1;
        $buf   = $line;
      }
        elsif(defined $buf){
          $buf .= $line;
        }
    }
    $fh->close;
    $states[$state] = $buf if defined $state;
  }
  \@states;
}

sub _build_context{
  my ($this) = @_;
  Text::PAN::Parser::Context->new;
}

sub _build_tokenizer{
  my ($this, %spec) = @_;
  my $src      = $spec{src};
  my $ebuilder = $spec{element_builder};
  my $context  = $spec{context};
  require Text::PAN::Tokenizer::Filtered;
  require Text::PAN::Tokenizer::Base;
  my $base = Text::PAN::Tokenizer::Base->new
    (src => $src,
     headeractions   =>
     +{
       title => sub{
         $context->title(shift);
       },
       xmlns => sub{
         my ($ns, $uri) = @_;
         $ebuilder->register_namespace_prefix($ns, $uri);
       },
      });

  Text::PAN::Tokenizer::Filtered->new
      (
       base            => $base,
       context         => $context,
       element_builder => $ebuilder,
      );
};

sub _make_debug_hook{
  my $this = shift;
  my @states = $this->states;
  return unless(@states);
  tie *STDERR,'Text::OutputFilter', 0, undef, sub{
    my $str = join '',@_;
    $str =~ s{(\A|[\x0d\x0a])In state (\d+)}{
      my $head = $1;
      my $st   = $2;
      $states[$st];
    }e;
    $str;
  };
}

sub _dispose_debug_hook{
  untie *STDERR;
}


sub parse{
  my ($this, $src) = @_;
  $src ||= $this;
  unless(blessed $this){
    $this = __PACKAGE__ unless UNIVERSAL::isa($this, __PACKAGE__);
    $this = $this->new;
  }
  $this->_make_debug_hook if $this->debug & 0x40;
  my $doc     = XML::LibXML::Document->createDocument(1, 'utf8');
  my $root    = $doc->createElementNS(NS, 'article');
  my $ebuilder = do{
    require Text::PAN::Element::Builder;
    Text::PAN::Element::Builder->new(
                                     doc => $doc,
                                    );
  };

  my $context = $this->_build_context;

  Text::PAN::Parser->new(yydebug => $this->debug)->parse
      (
       tokenizer => $this->_build_tokenizer(src             => $src,
                                            element_builder => $ebuilder,
                                            context         => $context),
       context   => $context,
       root      => $root,
       element_builder => $ebuilder,
      );
  $this->_dispose_debug_hook if $this->debug & 0x40;
  $doc->setDocumentElement($root);
  if(my $title = $context->title){
    my $meta = $doc->createElementNS(NS, 'meta');
    my $te   = $doc->createElementNS(NS, 'title');
    my $tt   = $doc->createTextNode($title);
    $te->appendChild($tt);
    $meta->appendChild($te);
    if(my $fc = $root->firstChild){
      $root->insertBefore($meta, $fc);
    }
    else{
      $root->appendCHild($meta);
    }
  }
  $doc;
}



1; # Magic true value required at end of module
__END__


=head1 SEE ALSO

=over 4

=item C<Data::Dumper>

=back

=head1 AUTHOR

lieutar  C<< <lieutar@1dk.jp> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-text-dbpn@rt.cpan.org>,
or through the web interface at 
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-Rebuilder>.
I will be notified, and then you'll automatically be notified of
progress on your bug as I make changes.

and...

Even if I am writing strange English because I am not good at English, 
I'll not often notice the matter. (Unfortunately, these cases aren't
testable automatically.)

If you find strange things, please tell me the matter.

=head1 COPYRIGHT & LICENSE

Copyright (c) 2009, lieutar C<< <lieutar@1dk.jp> >>. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

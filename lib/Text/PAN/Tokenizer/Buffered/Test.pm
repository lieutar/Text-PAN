package Text::PAN::Tokenizer::Buffered::Test;
use Any::Moose;

has element_builder => (
                        is => 'ro',
                        required => 1,
                       );

sub value{
  shift->element_builder->doc->createDocumentFragment;
}

sub in{}

with qw( Text::PAN::Role::Tokenizer );



1;
__END__


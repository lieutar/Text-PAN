package Text::PAN::Parser::Context;
use Any::Moose;

has _pest =>
  (
   is => 'ro',
   default => sub{[undef]},
  );

has title =>
  (
   is => 'rw',
   isa => 'Maybe[Str]',
  );


sub push_element{ push @{$_[0]->_pest}, undef}
sub pop_element{ pop @{$_[0]->_pest} }
sub previous_element_name{
  my $this = shift;
  my $pest = $this->_pest;
  $pest->[$#$pest] = shift if @_;
  $pest->[$#$pest];
}



1;
__END__


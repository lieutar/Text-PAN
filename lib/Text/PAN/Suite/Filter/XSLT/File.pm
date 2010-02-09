package Text::PAN::Suite::Filter::XSLT::File;
use Any::Moose;
use Text::PAN::CONSTANTS qw( NS );

has _functions =>
  (
   is         => 'ro',
   isa        => 'ArrayRef',
   default    => sub{[]},
  );

sub new{
  my ($this, %arg) = @_;
  my $funcs = delete $arg{functions} || [];
  $this = $this->SUPER::new(%arg);
  $funcs = [map {[$_ => $funcs->{$_}]} keys %$funcs]
    if(UNIVERSAL::isa($funcs, 'HASH'));
  $this->functions(@$funcs);
  $this;
}


sub functions{
  my $this = shift;
  my $slot = $this->_functions;
  while(@_){
    my $spec = shift;
    confess "xxxxx..." unless (ref($spec) || '') eq 'ARRAY';
    my @spec = @{$spec};
    if(2 == @spec){
      unshift @spec, NS;
    }
    if(3 == @spec){
      push @$slot, \@spec;
      next;
    }
    confess "zzzz...";
  }
  @$slot;
}


with qw(Text::PAN::Suite::Role::Filter::XSLT::File);

1;
__END__


package Text::PAN::Suite;
use Any::Moose;
use Text::PAN;

=head1 NAME

Text::PAN::Suite - Provides

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 filters

=head1 METHODS

=head2 add_filter

=head2 run

=cut

has filters =>
  (
   is         => 'ro',
   does       => 'ArrayRef[Text::PAN::Suite::Role::Filter]',
   auto_deref => 1,
   default    => sub{[]},
  );



sub add_filter{
  my ($this, $f) = @_;
  push @{$this->filters} , $f;
}


sub run{
  my ($this, $src, %opt) = @_;
  my $pan  = Text::PAN->new;
  my $doc  = $pan->parse($src);
  my @filters = $this->filters;
  my $last = pop @filters;
  foreach my $filter (@filters){
    $doc = $filter->do_filter($doc);
  }
  if($last){
    return $last->do_filter($doc, as_string => 1, %opt);
  }
  elsif($opt{as_text}){
    return $doc->toString;
  }
  $doc;
}


1;
__END__


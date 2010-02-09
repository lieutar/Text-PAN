package Text::PAN::Role::Tokenizer;
use Any::Moose qw( ::Role );

requires qw(in);


has buf => (
            is => 'ro',
            isa => 'ArrayRef',
            default => sub{[]},
           );

sub next_token{
  my $this = shift;
  my $buf = $this->buf;
  return shift @$buf if @$buf;
  $this->_next_token;
}

sub _next_token{undef}

sub unget_token{
  my ($this, $tok) = @_;
  unshift @{$this->buf}, $tok;
}

sub add_token{
  my ($this, $tok) = @_;
  push @{$this->buf}, $tok;
}

1;
__END__

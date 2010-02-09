package Text::PAN::Stream;

use Any::Moose;
require Path::Class;
use UNIVERSAL qw(isa);
use List::Util qw(max min);

has buffer => (is      => 'ro',
               isa     => 'ArrayRef',
               default => sub{[]});

has last_line => (is      => 'rw',
                  isa     => 'Maybe[Str]',
                  default => sub{''});

has line => ( is      => 'rw',
              default => sub{1} );

has _read_src => (
                  is      => 'ro',
                  isa     => 'ArrayRef',
                  default => sub{[]},
                  auto_deref => 1,
                 );


sub unget_line {
  my ($self, $line) = @_;
  push @{$self->buffer}, $line;
}

sub next_line {
  my ($self) = @_;
  my $buf = $self->buffer;
  my $line = undef;

  if( @$buf ){
    $line = pop @$buf
  }
  else {
    my $ln = $self->line + 1;
    $self->line($ln);
    $line = $self->get_line;
    push @{$self->_read_src} , $line;
  };

  $self->last_line($line);
  $line;
}

sub src_around {
  my ($this, %opt) = @_;
  my @R;
  my @src = $this->_read_src;
  my $width = defined($opt{width}) ? $opt{width} : 2;
  my $pos   = $opt{pos} || $#src;
  my $min   = max(0, $pos - $width);
  my $max   = $pos + $width;
  if($max > $#src){
    my $buf = $this->buffer;
    my @current = @{$buf};
    @{$buf} = ();
    for(my $n = $#src; $n < $max ; $n++){
      my $line = $this->get_line;
      last unless defined $line;
      push @src, $line;
      unshift @$buf, $line;
    }
    push @$buf, @current;
  }

  for(my $n = $min; $n <= min($#src, $max); $n++){
    push @R, [$n, $src[$n]];
  }
  @R;
}


sub file {
  return 'UNKNOWN';
}


sub get_line { undef; }

{
  package Text::PAN::Stream::Memory;
  use Any::Moose;
  extends 'Text::PAN::Stream';

  has _ref => (is  => 'ro',
               isa => 'ScalarRef',
               required => 1);

  has src => (
              is  => 'ro',
              isa => 'Str',
              required => 1,
             );

  sub new {
    my ($self, $src) = @_;
    my $ref = do{my $a = $src; \$a};
    $self->SUPER::new(_ref => $ref,
                      src  => $src);
  }

  sub get_line {
    my $self = shift;
    my $ref  = $self->_ref;
    defined($$ref) ? do{
      $$ref =~ s/\A([^\x0d\x0a]*(?:\x0d\x0a|\x0d|\x0a|\Z))//;
      $1 || undef
    } : undef;
  }

}

{
  package Text::PAN::Stream::FileHandle;
  use Any::Moose;
  extends 'Text::PAN::Stream';

  has fh => (is => 'ro',
             isa => 'FileHandle' );

  has file => (is => 'ro',
               isa => 'Str');


  sub new {
    my ($self, $fh, $file) = @_;
    binmode $fh,  ':utf8';
    $self->SUPER::new(fh   => $fh,
                      file => ($file
                               ? "$file"
                               : ((ref $fh) ? "$$fh" : "$fh")));
  }

  sub get_line{
    my ( $self ) = @_;
    my $fh = $self->fh;
    my $R  = <$fh>;
    $R;
  }

}

sub gen{
  my $src = shift;

  return Text::PAN::Stream::FileHandle->new(\*STDIN)
    unless defined $src;

  $src = Path::Class::file($src) if $src !~ /[\x0d\x0a]/ && -f $src;
  return Text::PAN::Stream::FileHandle->new($src->openr, $src)
    if isa($src, 'Path::Class::File');

  return Text::PAN::Stream::FileHandle->new($src) if isa($src, 'GLOB');

  Text::PAN::Stream::Memory->new($src);
}


1;
__END__

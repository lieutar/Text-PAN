package Text::PAN::Suite::Role::Filter::XSLT::File;
use Any::Moose '::Role';
use Path::Class;
use Cwd;
use XML::LibXML;

has file => (
             is       => 'ro',
             required => 1
            );

has home => (
             is         => 'ro',
             lazy_build => 1
            );

sub _build_home{
  my ($this) = @_;
  file($this->file)->absolute->parent;
}

sub xslt{
  my ($this) = @_;
  my $R    = XML::LibXML->load_xml(
                                   location => $this->file,
                                  );
  my $cwd  = getcwd;
  my $path = file($this->file)->absolute;
  chdir $this->home;
  my $parser = XML::LibXML->new;
  $parser->process_xincludes($R);
  chdir $cwd;
  $R;
}


with qw(Text::PAN::Suite::Role::Filter::XSLT);

1;
__END__

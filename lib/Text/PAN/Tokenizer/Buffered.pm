package Text::PAN::Tokenizer::Buffered;
use Any::Moose;
use Text::PAN;

has depth =>
  (
   is      => 'ro',
   isa     => 'Num',
   default => sub{1},
  );

has name =>
  (
   is      => 'ro',
   isa     => 'Str',
   default => sub{'*anoymous*'},
  );

has value =>
  (
   is         => 'ro',
   lazy_build => 1,
  );


has element_builder =>
  (
   is       => 'ro',
   required => 1,
  );

has in =>
  (
   is => 'ro',
   required => 1,
  );


has context =>
  (
   is       => 'ro',
   isa      => 'Text::PAN::Parser::Context',
   required => 1,
  );


sub _build_value{

  my ($this)   = @_;
  my $parser   = Text::PAN::Parser->new(yydebug => $Text::PAN::DEBUG);
  my $filter   = Text::PAN::Tokenizer::Filtered->new(base => $this,
                                                     depth => $this->depth + 1,
                                                     context => $this->context);
  my $ebuilder = $this->element_builder;
  my $doc      = $ebuilder->doc;

  warn "<<" . $this->name .">>" if $Text::PAN::DEBUG;

  my $R = $parser->parse
    (
     tokenizer       => $filter,
     element_builder => $ebuilder,
     context         => $this->context,
     root            => $doc->createDocumentFragment,
    );

  warn "<</" . $this->name . ">>" if $Text::PAN::DEBUG;
  $R;
}



with qw( Text::PAN::Role::Tokenizer );
1;
__END__


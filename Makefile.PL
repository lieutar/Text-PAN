use inc::Module::Install;
use FileHandle;

name     'Text-PAN';
all_from 'lib/Text/PAN.pm';
author   'lieutar <lieutar@1dk.jp>';

requires qw( XML::LibXML );
requires qw( XML::LibXSLT );
requires qw( Path::Class );
requires qw( Any::Moose  0.10 );
requires qw( Parse::Yapp::Driver );
requires qw( HTML::Entities );
requires qw( Text::OutputFilter );
requires qw( URI::Escape );

build_requires 'Test::More';
build_requires 'ExtUtils::MakeMaker';

install_script 'pan';

auto_install;

WriteAll;

{
  my $fh = FileHandle->new;
  open $fh, '>>', 'Makefile' || die;
  print $fh <DATA>;
  close $fh;
}

__END__

PARSER=lib/Text/PAN/Parser.pm
parser: $(PARSER)

$(PARSER): $(PARSER:.pm=.yp)
	yapp -v -m Text::PAN::Parser -o $@ $<

clean-parser:
	rm -f $(PARSER)

update-parser: clean-parser parser

dummy:

html-doc: doc/index.pan dummy
	if ! test -d html ; then \
	  mkdir html; \
	fi;
	perl -Ilib script/pan $< -o html/index.html \
                -Fcss=css/doc.css \
                -MText::PAN::Suite::Filter::MacroExpand \
                -MText::PAN::Suite::Filter::URL2Ref \
                -s xslt/html4.xslt

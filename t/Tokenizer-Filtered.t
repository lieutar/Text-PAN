use strict;
use warnings;
use Test::More;
use File::Basename;
use lib dirname(__FILE__)."/..";
use t::lib::Tokenizer::TestLib qw(:all);
BEGIN{
  plan tests => 8;
  use_ok $_ foreach qw(
                        Text::PAN::Tokenizer::Base
                        Text::PAN::Tokenizer::Filtered
                        Text::PAN::Tokenizer::Buffered::Test
                        Text::PAN::Parser::Context
                     );
}

sub newt{
  Text::PAN::Tokenizer::Filtered->new
      (
       base         => Text::PAN::Tokenizer::Base->new(shift || ''),
       buffer_class => 'Text::PAN::Tokenizer::Buffered::Test',
       context      => Text::PAN::Parser::Context->new
      );
}

$t::lib::Tokenizer::TestLib::Builder = \&newt;

{
  my $t = newt;
  isa_ok($t , 'Text::PAN::Tokenizer::Filtered');
}

;
testt qw( BLOCK_ELEM ),<<'EOF';
<html>
<head/<title/hoge>
<script type="text/javascript">
<!--
alert(123);
alert(456);
-->
</script>
>
</html>
EOF

testt qw( SECTION_IN SECTION_HEADER TEXT BR
            TEXT
            SECTION_IN SECTION_HEADER TEXT BR
              BLOCK_ELEM
            SECTION_OUT
            SECTION_IN SECTION_HEADER TEXT BR
              BL
              BLOCK_ELEM
              SECTION_IN SECTION_HEADER TEXT BR
                TEXT
                BL
                ELEM TEXT
                BL
              SECTION_OUT
            SECTION_OUT
            SECTION_IN SECTION_HEADER TEXT BR
          BLOCK_ELEM
          TEXT
       ), <<'EOF';
* section 1
</hoge>
** section 2
<hoge>
** section 3

<fuga>
*** section 4
</fuga>

<hemo / aaa bbb>xxx

** section 5
<xxx>
</yyy>
</>
</xxx>
EOF


testt qw(BLOCK_COMMENT TEXT),<<'EOF';
<!--
aaaa
-->
aaa
EOF

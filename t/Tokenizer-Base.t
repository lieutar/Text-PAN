use strict;
use warnings;
use Test::More tests => 124;
use File::Basename;
use lib dirname(__FILE__)."/..";
use t::lib::Tokenizer::TestLib qw(:all);
use t::lib::Random;
use Time::HiRes qw(usleep);
use Path::Class;

use_ok qw( Text::PAN::Tokenizer::Base );

sub newt{ Text::PAN::Tokenizer::Base->new( shift || '') }
$t::lib::Tokenizer::TestLib::Builder = \&newt;

{
  my $t = newt;
  isa_ok($t , 'Text::PAN::Tokenizer::Base');
  is($t->current_indent, 0);
  is($t->current_context, 'NORMAL');
  is($t->prev_indent, 0);
  $t->indent(OL => 2);
  is($t->current_indent, 2);
  is($t->prev_indent, 0);
  is($t->current_context, 'OL');

  ok($t->dedentp(0));
  ok(!$t->dedentp(2));
  ok(!$t->dedentp(1),'0< (1) < 2 ');
  $t->dedent;
  is($t->current_context, 'NORMAL');
}

;
testt qw(TEXT TEXT TEXT),<<'EOF';
aaaa
bbbb
cccc
EOF




;
testt qw(TEXT VERB TEXT), <<'EOF' ;
aaaa
  bbb
    ccc
    dddd
      eeee
  ffff
gggg
EOF

;



testt qw(TEXT
         INDENT ULBULLET TEXT
                         VERB
                         TEXT
                INDENT ULBULLET TEXT
                       ULBULLET TEXT DEDENT
                ULBULLET TEXT DEDENT
         TEXT), <<'EOF';
aaaa
- aaa
    bbbb
  ccc
  - dddd
  - eeee
- ffff
gggg
EOF

testt qw(INDENT ULBULLET TEXT DEDENT) , <<'EOF';
- >
EOF


testt qw( REFSTART REFEND ),<<'EOF';
[[]]
EOF
testt qw( REFSTART TEXT REFEND ),<<'EOF';
[[abc]]
EOF


testt qw( INDENT ULBULLET TEXT DEDENT
                   INDENT OLBULLET TEXT DEDENT
                   INDENT ULBULLET TEXT DEDENT
                   INDENT OLBULLET TEXT
                                   TEXT
                                   INDENT OLBULLET TEXT
                                                   TEXT DEDENT DEDENT
                   TEXT
                ),<< 'EOF';
- aaaaa
+ ddddd
- fffff
+ ggggg
  g-g-g-
  + hhhhh
    h-h-h-
xxxx
EOF


;
testt qw(TEXT
                  INDENT DTSTART TEXT DTEND
                                            TEXT
                                            VERB
                         DTSTART TEXT DTEND TEXT
                                            VERB
                  DEDENT
                  TEXT
                ), << 'EOF';
aaaaa
::aaaaa::
  bbbbb
    xxxxx
::cccc:: dddd
    xxxx
yyy
EOF


;
testt ([TAG_START => 'hoge'],qw(SPACES TEXT = TEXT / TEXT >),
       [TAG_START => 'fuga'],qw(SPACES TEXT = TEXT SPACES
                                TEXT = TEXT > TEXT
                                TEXT
                                TEXT),
       [ENDTAG_START => 'fuga'], qw( > ),
       [TAG_START => 'xyz'], qw(SPACES TEXT = TEXT / >), << 'EOF');
<hoge fuga="aaa"/xyz>
<fuga hoge="hemo"
      hehe="fuga">xyz
abc
def
</fuga>
<xyz aaa=bbb/>
EOF



testt
  qw(SECTION_IN SECTION_HEADER TEXT BR
       TEXT
       TEXT
         SECTION_IN SECTION_HEADER TEXT BR
           TEXT
           TEXT
         SECTION_OUT
         SECTION_IN SECTION_HEADER TEXT BR
           TEXT
           TEXT
           SECTION_IN SECTION_HEADER TEXT BR
             TEXT
             TEXT
           SECTION_OUT
           SECTION_IN SECTION_HEADER TEXT BR
             TEXT
             TEXT
             SECTION_IN SECTION_HEADER TEXT BR
               TEXT
               TEXT
             SECTION_OUT
           SECTION_OUT
         SECTION_OUT
       SECTION_OUT
       SECTION_IN SECTION_HEADER TEXT BR
       TEXT
       TEXT
     ), << 'EOF';
* abc
aaa
aaa
** def
aaa
aaa
** ghi
aaa
aaa
*** xxx
aaa
aaa
*** yyy
aaa
aaa
**** zzz
aaa
aaa
* jkl
aaa
aaa
EOF



;
testt (
       qw(
           HR
           BL
        ),

       [SPE_VERB => sub{
          ($_[0]->{attrs}->{type} ||'') eq 'perl'
        }],

       qw(
           BL
           INDENT ULBULLET TEXT
        ),

       [SPE_VERB => sub{
          ($_[0]->{attrs}->{type} ||'') eq 'js'
        }],

       qw(
           BL
           DEDENT
        ),
       << 'EOF');

------------------------------------------------------------

>|perl|
use strict;
use warnings

=for comment

  aaaa
  bbbb
  cccc

=cut

||<

  - hoge
    >|js|
    aaaa

    bbb

    cccc
    ||<

||<
EOF




;
testt qw(
          TAG_START >
          TAG_START / TAG_START / TEXT >
          TAG_START SPACES TEXT = TEXT >
          BEGIN_COMMENT_DECL TEXT
          TEXT
          TEXT
          END_COMMENT >
          ENDTAG_START >
          >
          ENDTAG_START >

       ),<<'EOF';
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

SKIP:
{
  unless($ENV{HEAVYTEST}){
    skip("Heavy Heavy test ... cause \$ENV{HEAVYTEST} is false ...", 100);
  }

  my $jar = file(file(__FILE__)->parent->parent, basename(__FILE__).'.random.txt')->absolute;

  diag "Tests by random text";
  my $random = ' ' x 32768;
  my $fail = sub{
    fail();
    my $fh = $jar->openw || die "could not open: $jar";
    $fh->print($random);
    $fh->close;
    diag "saved radom-text as $jar";
    exit 1;
  };

  foreach my $c (1 .. 100){
    my $tok = newt( -f $jar ?  join( "", $jar->slurp) : do{ randomtext00(\$random, 32768); $random});
    my $cc = $c;
    local $SIG{ALRM}     = sub{ goto $fail if $cc == $c };
    local $SIG{__WARN__} = sub{ diag shift; goto $fail };
    local $SIG{__DIE__}  = sub{ diag shift; goto $fail };
    alarm 10;
    usleep 50 while $tok->next_token;
    unlink $jar if -f $jar;
    pass( "random: $c" );
  }

}

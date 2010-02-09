use strict;
use warnings;
package TestMain;
use Test::More;

BEGIN{
  plan tests => 9;
  use_ok 'Text::PAN::Stream';
}

{
  my $s = Text::PAN::Stream::gen(<<'EOF');
aaa
bbb
ccc
ddd
eee
fff
ggg
hhh
iii
jjj
kkk
lll
EOF
  isa_ok($s, 'Text::PAN::Stream');
  is($s->next_line, "aaa\n");
  $s->next_line;
  $s->next_line;
  $s->next_line;
  $s->next_line;
  $s->next_line;
  $s->unget_line("uvw");
  $s->unget_line("xyz");
  is_deeply([$s->src_around(width => 4)],
            [
             [1, "bbb\n"],
             [2, "ccc\n"],
             [3, "ddd\n"],
             [4, "eee\n"],

             [5, "fff\n"],

             [6, "ggg\n"],
             [7, "hhh\n"],
             [8, "iii\n"],
             [9, "jjj\n"],
            ]);
  is($s->next_line, "xyz");
  is($s->next_line, "uvw");
  is($s->next_line, "ggg\n");
  is($s->next_line, "hhh\n");
  is($s->next_line, "iii\n");
}



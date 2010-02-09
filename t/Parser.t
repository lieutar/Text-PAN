use strict;
use warnings;
package TestMain;
use Test::More;
use Text::PAN;
use File::Basename;
use lib dirname(__FILE__)."/..";
use t::lib::Parser::TestLib;

plan tests => 100 + 28;

test
  [article => [] ],
  <<'EOF', 'empty';
EOF

test
  [article =>
   [
    [p => ["abc\n"
          ]],
   ]],
  <<'EOF', 'simplest';
abc
EOF

test
  [article=>
   [
    [p =>
     [
      "aaa",
      [a => (href => 'xxx'),
       [
        "yyy"
       ]],
      "bbb\n"
     ]],
   ]],
  <<'EOF' , 'with elem(normal)';
aaa<a href="xxx">yyy</a>bbb
EOF

test
  [article=>
   [
    [p =>
     [
      "aaa",
      [a => (href => 'xxx'),
       [
        "yyy"
       ]],
      "bbb\n"
     ]],
   ]],
  <<'EOF' , 'with elem(empty closing)';
aaa<a href="xxx">yyy</>bbb
EOF

test
  [article=>
   [
    [p =>
     [
      "aaa",
      [a => (href => 'xxx'),
       [
        "yyy",
       ]],
      [a =>
       [
        "zzz",
       ]],
      "bbb\n"
     ]],
   ]],
  <<'EOF' , 'with elem(empty closing and empty begining)';
aaa<a href="xxx">yyy</><>zzz</>bbb
EOF

test
  [article=>
   [
    [p =>
     [
      "aaa",
      [a => (href => 'xxx'),
       [
        "yyy"
       ]],
      "bbb\n"
     ]],
   ]],
  <<'EOF' , 'with elem(net)';
aaa<a href="xxx" /yyy>bbb
EOF


test
  [article=>
   [
    [p =>
     [
      "aaa",
      [a => (href => 'xxx'),
       [
        [item =>
         ["yyy"
         ]],
       ]],
      "bbb\n"
     ]],
   ]],
  <<'EOF', 'nested elem(normal)';
aaa<a href="xxx"><item>yyy</item></a>bbb
EOF



test
  [article=>
   [
    [p =>
     [
      "aaa",
      [a => (href => 'xxx'),
       [
        [item =>
         ["yyy"
         ]],
       ]],
      "bbb\n"
     ]],
   ]],
  <<'EOF', 'nested elem(net and empty closing)';
aaa<a href="xxx" /<item>yyy</>>bbb
EOF

test
  [article =>
   [
    [quote => [
              ]]
   ]], <<'EOF', 'empty element only';
<quote/>
EOF



test
  [article =>
   [
    [p =>
     [
      "aaaa\n".
      "bbbb\n"
     ]],
    [p =>
     [
      "cccc\n".
      "dddd\n"
     ]],
   ]], << 'EOF' , 'two paragraph';

aaaa
bbbb

cccc
dddd

EOF

test
  [article =>
   [
    [quote =>
     [
      [p =>
       [
        "aaaa\n".
        "bbbb\n"
       ]],
      [p =>
       [
        "cccc\n".
        "dddd\n"
       ]],
     ]]
   ]], << 'EOF' , 'element around some paragraphs(1)';
<quote>

aaaa
bbbb

cccc
dddd

</quote>
EOF


test
  [article =>
   [
    [quote =>
     [
      [p =>
       [
        "aaaa\n".
        "bbbb\n"
       ]],
      [p =>
       [
        "cccc\n".
        "dddd\n"
       ]],
     ]]
   ]], << 'EOF' , 'element around some paragraphs(2)';
<quote>

aaaa
bbbb

cccc
dddd
</quote>
EOF

test
  [article =>
   [
    [quote =>
     [
      [p =>
       [
        "aaaa\n".
        "bbbb\n"
       ]],
      [p =>
       [
        "cccc\n".
        "dddd\n"
       ]],
     ]]
   ]], << 'EOF' , 'element around some paragraphs(3)';
<quote>
aaaa
bbbb

cccc
dddd

</quote>
EOF


test
  [article =>
   [
    [quote =>
     [
      [p =>
       [
        "aaaa\n".
        "bbbb\n"
       ]],
      [p =>
       [
        "cccc\n".
        "dddd\n"
       ]],
     ]]
   ]], << 'EOF' , 'element around some paragraphs(4)';
<quote>
aaaa
bbbb

cccc
dddd
</quote>
EOF




test
  [article =>
   [
    [p =>
     [
      "aaa\n",
     ]],
    [note =>
     [
      [p =>
       [
        "aaaa\n".
        "bbbb\n"
       ]],
      [verb => (type => "xml"),
       [
        "<abc><def /></abc>\n",
       ]],
      [p =>
       [
        "cccc\n".
        "dddd\n"
       ]],
     ]],
    [p =>
     [
      "bbb\n",
     ]],
   ]], << 'EOF' , 'element around complex elements.';
aaa

<note>

aaaa
bbbb

>|xml|
  <abc><def /></abc>
||<

cccc
dddd

</note>

bbb
EOF



test
  [article =>
   [
    [p =>
     [
      "aaa",
      [ref => (name => "xyz", ["xyz"])],
      "bbb\n"
     ]]
   ]], <<'EOF' , 'ref (simple)';
aaa[[xyz]]bbb
EOF

test
  [article =>
   [
    [p =>
     [
      "aaa",
      [ref => (name => "xyz", ["x",
                               [em =>
                                [
                                 [code => ["y"]],
                                ]],
                               "z"])],
      "bbb\n"
     ]]
   ]], <<'EOF' , 'ref (complex)';
aaa[[x<em/<code/y>>z]]bbb
EOF


## special notations
test
  [article =>
   [
    [verb => (type => 'perl'),
     [
      ""
     ]]
   ]], <<'EOF', 'empty special verb';
>|perl|
||<
EOF



test
  [article =>
   [
    [dl =>
     [
      [item =>
       [
        [about =>
         [
          "aaa "
         ]],
        [p     =>
         [
          "aaaaa\n"
         ]],
       ]],
     ]],
   ]], <<'EOF', 'dl simple';
:: aaa :: aaaaa
EOF


test
  [article =>
   [
    [dl =>
     [
      [item =>
       [
        [about =>
         [
          "aaa "
         ]],
        [p     =>
         [
          "aaaaa\n"
         ]],
       ]],
      [item =>
       [
        [about =>
         [
          "aaa "
         ]],
        [p     =>
         [
          "aaaaa\n"
         ]],
       ]],
      [item =>
       [
        [about =>
         [
          "aaa "
         ]],
        [p     =>
         [
          "aaaaa\n"
         ]],
       ]],
     ]],
   ]], <<'EOF', 'dl (3 items)';
:: aaa :: aaaaa
:: aaa :: aaaaa
:: aaa :: aaaaa
EOF


test
  [article =>
   [
    [dl =>
     [
      [item =>
       [
        [about =>
         [
          "a "
         ]],
        [p     =>
         [
          "d\n"
         ]],
        [dl =>
         [
          [item =>
           [
            [about =>
             [
              "a "
             ]],
            [p     =>
             [
              "d\n"
             ]],
            [dl =>
             [
              [item =>
               [
                [about =>
                 [
                  "a "
                 ]],
                [p     =>
                 [
                  "d\n"
                 ]],
               ]],
             ]],
           ]],
          [item =>
           [
            [about =>
             [
              "a "
             ]],
            [p     =>
             [
              "d\n"
             ]],
            [dl =>
             [
              [item =>
               [
                [about =>
                 [
                  "a "
                 ]],
                [p     =>
                 [
                  "d\n"
                 ]],
               ]],
              [item =>
               [
                [about =>
                 [
                  "a "
                 ]],
                [p     =>
                 [
                  "d\n"
                 ]],
               ]],
             ]],
           ]],
         ]],
       ]],
     ]],
   ]], <<'EOF', 'dl (nested)';
:: a :: d
   :: a :: d
      :: a :: d
   :: a :: d
      :: a :: d
      :: a :: d
EOF


test
  [article =>
   [
    [section =>
     [
      [head => ["xxx\n"]],
     ]],
   ]], <<'EOF', 'an empty section';
* xxx
EOF

test
  [article =>
   [
    [section =>
     [
      [head => ["xxx\n"]],
     ]],
    [section =>
     [
      [head => ["xxx\n"]],
     ]],
    [section =>
     [
      [head => ["xxx\n"]],
     ]],
   ]], <<'EOF', 'multi empty sections';
* xxx
* xxx
* xxx
EOF

test
  [article =>
   [
    [section =>
     [
      [head => ["xxx\n"]],
      [section =>
       [
        [head => ["xxx\n"]],
        [section =>
         [
          [head => ["xxx\n"]],
          [section =>
           [
            [head => ["xxx\n"]],
           ]],
         ]],
       ]],
     ]],
    [section =>
     [
      [head => ["xxx\n"]],
     ]],
   ]], <<'EOF', 'nested empty sections';
* xxx
** xxx
*** xxx
**** xxx
* xxx
EOF



test
  [article =>
   [
    [section =>
     [
      [head => ["xxx\n"]],
      [p => ["p1p1\n"]],
      [p => ["p2p2\n"]],
     ]],
   ]], <<'EOF', 'a section with contents';
* xxx

p1p1

p2p2


EOF


test
  [article =>
   [
    [section =>
     [
      [head => ["xxx\n"]],
      [p    => ["p1p1\n"]],
      [verb => ["verb\n"]],
      [p    => ["p2p2\n"]],
      [ul   =>
       [
        [item => [[p => ["aaa\n"]]]],
        [item => [[p => ["bbb\n"]],
                  [ul =>
                   [
                    [item => [[p => ["ccc\n"]]]],
                   ]]]],
       ]],
     ]],
   ]], <<'EOF', 'a section with complex contents';
* xxx

p1p1

 verb

p2p2

 - aaa
 - bbb
   - ccc


EOF

test
  [article =>
   [
    [section =>
     [
      [head =>
       [
        "sect1\n"
       ]],
      [section =>
       [
        [head =>
         [
          "sect1.1\n"
         ]],
        [ul =>
         [
          [item =>
           [
            [p => ["xxx\n"]]
           ]],
          [item =>
           [
            [p => ["xxx\n"]]
           ]],
         ]]
       ]]
     ]],
    [section =>
     [
      [head =>
       [
        "sect2\n",
       ]]
     ]]
   ]], << 'EOF', 'ul and section out' ;
* sect1
** sect1.1

 - xxx
 - xxx

* sect2
EOF




test
  [article =>
   [[section =>
     [[head => ["sect 1.\n"]],
      [section => [[head => ["sect 1.1.\n"
                            ]]
                  ]],
      [section => [[head => ["sect 1.2.\n"
                            ]]
                  ]],
      [section =>
       [[head => ["sect 1.3.\n"
                 ]],
        [p => ["para1",
               [ref => (name => "xyz",
                        ["link1"])],
               "para1",
               [ref => (name => "abc",
                        ["link2"])]
              ]],
        [figure => (type => 'quote',
                    foo  => 'bar',
                    [[quote =>
                      [
                       [p => [
                              [cite => (url => "http://example.org/docs/foo",
                                        ["about foo"])],
                             ]],
                       [p => ["para2\n".
                              "para2\n"
                             ]],
                      ]], # end quote
                   ])], # end figure
        [ul => [
                [item => [[p => ["ul\n"
                              ]],
                         ]],
                [item => [[p => ["ul\n"
                                ]],
                          [ul => [[item => [[p => ["ul\n".
                                                   "xxxx\n".
                                                   "yyyy\n"
                                                  ]],
                                            [verb => ["verb\n".
                                                      "\n".
                                                      "verb\n"
                                                     ]],
                                            [p => ["zzzz\n"
                                                  ]]
                                           ]],
                                 ]],
                          [ol => [[item => [[p => ["ol\n"]]]],
                                  [item => [[p => ["ol\n"]]]],
                                  [item => [[p => ["ol\n"]],
                                            [p => ["xxxx\n".
                                                   "xxxx\n".
                                                   "xxxx\n"
                                                  ]]]],
                                 ]],
                         ]],
               ]],
        [p => ["para3\n".
               "para3\n"]],
       ]]
     ]],

    [section =>
     [[head => ["sect 2.\n"
               ]],
      [p => ["para3\n".
             "para3\n"
            ]],
      [verb => ["verb1\n".
                "verb2\n".
                "\n".
                "verb3\n".
                "verb4\n"
               ]],
      [hr => []],
      [verb => ( type => 'perl',
                ["use strict;\n".
                 "use warnings;\n"])]
     ]]
   ]],

  << 'EOF', "complex";
* sect 1.

** sect 1.1.
** sect 1.2.

** sect 1.3.

para1<ref name="xyz">link1</ref>
para1<ref name="abc"/link2>

<figure type="quote"
         foo="bar">

<quote><cite url="http://example.org/docs/foo" /about foo>

para2
para2

</>
</figure>

 - ul
 - ul
   - ul
     xxxx
     yyyy

       verb

       verb

     zzzz
   + ol
   + ol
   + ol

     xxxx
     xxxx
     xxxx

para3
para3

* sect 2.
para3
para3
  verb1
  verb2

  verb3
  verb4

--------------------

>|perl|
use strict;
use warnings;
||<
EOF




SKIP:
{
  unless($ENV{HEAVYTEST}){
    skip("Heavy Heavy test ... cause \$ENV{HEAVYTEST} is false ...", 100);
  }

  use t::lib::Random;
  use Path::Class;

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
    if( -f $jar ){
      $random = join( "", $jar->slurp);
    }
    else{
      randomtext00(\$random, 32768)
    }
    my $cc = $c;
    local $SIG{ALRM}     = sub{ goto $fail if $cc == $c };
    local $SIG{__WARN__} = sub{ diag shift; goto $fail };
    #local $SIG{__DIE__}  = sub{ diag shift; goto $fail };
    alarm 10;
    Text::PAN->parse($random);
    unlink $jar if -f $jar;
    pass( "random: $c" );
  }

}



1;
__END__


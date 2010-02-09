####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package Text::PAN::Parser;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver );
use Parse::Yapp::Driver;

#line 1 "lib/Text/PAN/Parser.yp"


use strict;
use warnings;
use Text::PAN::Parser::Methods;
use Data::Dumper;

{
  my $id = 0;
  sub __id{
    "sect-".($id++);
  }
}




sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.05',
                                  yystates =>
[
	{#State 0
		ACTIONS => {
			'COMMENT_DECL' => -48,
			'BL' => 4
		},
		DEFAULT => -4,
		GOTOS => {
			'blockelements' => 1,
			'document' => 3,
			'blank' => 2,
			'doc' => 5,
			'bl' => 6
		}
	},
	{#State 1
		ACTIONS => {
			'SECTION_IN' => 7,
			'VERB' => 9,
			'REFSTART' => 10,
			'HR' => 26,
			'TEXT' => 13,
			'ELEM' => 14,
			'BLOCK_ELEM' => 15,
			'SPE_VERB' => 29,
			'INDENT' => 32
		},
		DEFAULT => -3,
		GOTOS => {
			'ul' => 21,
			'blockelement' => 8,
			'olbody' => 23,
			'ref' => 22,
			'para' => 12,
			'section' => 11,
			'dlbody' => 24,
			'block_elem' => 25,
			'spe_verb' => 16,
			'ol' => 17,
			'hr' => 27,
			'inlinenodes' => 28,
			'text' => 18,
			'verb' => 19,
			'ulbody' => 30,
			'inlinenode' => 20,
			'dl' => 31
		}
	},
	{#State 2
		ACTIONS => {
			'COMMENT_DECL' => 34
		},
		DEFAULT => -4,
		GOTOS => {
			'blockelements' => 1,
			'doc' => 33
		}
	},
	{#State 3
		ACTIONS => {
			'' => 35
		}
	},
	{#State 4
		ACTIONS => {
			'BL' => 4
		},
		DEFAULT => -51,
		GOTOS => {
			'bl' => 36
		}
	},
	{#State 5
		DEFAULT => -1
	},
	{#State 6
		DEFAULT => -49
	},
	{#State 7
		ACTIONS => {
			'SECTION_HEADER' => 38
		},
		GOTOS => {
			'sectionheader' => 37
		}
	},
	{#State 8
		DEFAULT => -5
	},
	{#State 9
		DEFAULT => -37
	},
	{#State 10
		ACTIONS => {
			'ELEM' => 14,
			'TEXT' => 13,
			'REFSTART' => 10
		},
		GOTOS => {
			'inlinenodes' => 39,
			'ref' => 22,
			'text' => 18,
			'inlinenode' => 20
		}
	},
	{#State 11
		DEFAULT => -12
	},
	{#State 12
		DEFAULT => -6
	},
	{#State 13
		DEFAULT => -46
	},
	{#State 14
		DEFAULT => -44
	},
	{#State 15
		DEFAULT => -15
	},
	{#State 16
		ACTIONS => {
			'COMMENT_DECL' => -17,
			'BL' => -17
		},
		DEFAULT => -8
	},
	{#State 17
		DEFAULT => -9
	},
	{#State 18
		ACTIONS => {
			'TEXT' => 40
		},
		DEFAULT => -43
	},
	{#State 19
		ACTIONS => {
			'COMMENT_DECL' => -16,
			'BL' => -16
		},
		DEFAULT => -7
	},
	{#State 20
		DEFAULT => -40
	},
	{#State 21
		DEFAULT => -10
	},
	{#State 22
		DEFAULT => -45
	},
	{#State 23
		ACTIONS => {
			'DEDENT' => 42,
			'OLBULLET' => 43
		},
		GOTOS => {
			'olitem' => 41
		}
	},
	{#State 24
		ACTIONS => {
			'DEDENT' => 45,
			'DTSTART' => 44
		},
		GOTOS => {
			'dlitem' => 46
		}
	},
	{#State 25
		ACTIONS => {
			'COMMENT_DECL' => -48,
			'BL' => 4
		},
		DEFAULT => -14,
		GOTOS => {
			'blank' => 47,
			'bl' => 6
		}
	},
	{#State 26
		DEFAULT => -19
	},
	{#State 27
		ACTIONS => {
			'BL' => 4
		},
		DEFAULT => -13,
		GOTOS => {
			'bl' => 48
		}
	},
	{#State 28
		ACTIONS => {
			'REFSTART' => 10,
			'TEXT' => 13,
			'ELEM' => 14,
			'COMMENT_DECL' => 50,
			'BL' => 4
		},
		DEFAULT => -38,
		GOTOS => {
			'ref' => 22,
			'text' => 18,
			'inlinenode' => 49,
			'bl' => 51
		}
	},
	{#State 29
		DEFAULT => -36
	},
	{#State 30
		ACTIONS => {
			'DEDENT' => 53,
			'ULBULLET' => 52
		},
		GOTOS => {
			'ulitem' => 54
		}
	},
	{#State 31
		DEFAULT => -11
	},
	{#State 32
		ACTIONS => {
			'OLBULLET' => 43,
			'DTSTART' => 44,
			'ULBULLET' => 52
		},
		GOTOS => {
			'olitem' => 55,
			'dlitem' => 56,
			'ulitem' => 57
		}
	},
	{#State 33
		DEFAULT => -2
	},
	{#State 34
		DEFAULT => -50
	},
	{#State 35
		DEFAULT => 0
	},
	{#State 36
		DEFAULT => -52
	},
	{#State 37
		ACTIONS => {
			'BL' => 4
		},
		DEFAULT => -48,
		GOTOS => {
			'blank' => 58,
			'bl' => 6
		}
	},
	{#State 38
		ACTIONS => {
			'ELEM' => 14,
			'TEXT' => 13,
			'REFSTART' => 10
		},
		GOTOS => {
			'inlinenodes' => 59,
			'ref' => 22,
			'text' => 18,
			'inlinenode' => 20
		}
	},
	{#State 39
		ACTIONS => {
			'ELEM' => 14,
			'TEXT' => 13,
			'REFEND' => 60,
			'COMMENT_DECL' => 50,
			'REFSTART' => 10
		},
		GOTOS => {
			'ref' => 22,
			'text' => 18,
			'inlinenode' => 49
		}
	},
	{#State 40
		DEFAULT => -47
	},
	{#State 41
		DEFAULT => -30
	},
	{#State 42
		DEFAULT => -28
	},
	{#State 43
		DEFAULT => -4,
		GOTOS => {
			'blockelements' => 61
		}
	},
	{#State 44
		ACTIONS => {
			'ELEM' => 14,
			'TEXT' => 13,
			'REFSTART' => 10
		},
		GOTOS => {
			'inlinenodes' => 62,
			'ref' => 22,
			'text' => 18,
			'inlinenode' => 20
		}
	},
	{#State 45
		DEFAULT => -32
	},
	{#State 46
		DEFAULT => -34
	},
	{#State 47
		ACTIONS => {
			'COMMENT_DECL' => 34
		},
		DEFAULT => -18
	},
	{#State 48
		DEFAULT => -20
	},
	{#State 49
		DEFAULT => -41
	},
	{#State 50
		DEFAULT => -42
	},
	{#State 51
		DEFAULT => -39
	},
	{#State 52
		DEFAULT => -4,
		GOTOS => {
			'blockelements' => 63
		}
	},
	{#State 53
		DEFAULT => -24
	},
	{#State 54
		DEFAULT => -26
	},
	{#State 55
		DEFAULT => -29
	},
	{#State 56
		DEFAULT => -33
	},
	{#State 57
		DEFAULT => -25
	},
	{#State 58
		ACTIONS => {
			'COMMENT_DECL' => 34
		},
		DEFAULT => -4,
		GOTOS => {
			'blockelements' => 64
		}
	},
	{#State 59
		ACTIONS => {
			'ELEM' => 14,
			'TEXT' => 13,
			'BR' => 65,
			'COMMENT_DECL' => 50,
			'REFSTART' => 10
		},
		GOTOS => {
			'ref' => 22,
			'text' => 18,
			'inlinenode' => 49
		}
	},
	{#State 60
		DEFAULT => -53
	},
	{#State 61
		ACTIONS => {
			'SECTION_IN' => 7,
			'VERB' => 9,
			'REFSTART' => 10,
			'HR' => 26,
			'TEXT' => 13,
			'ELEM' => 14,
			'BLOCK_ELEM' => 15,
			'SPE_VERB' => 29,
			'INDENT' => 32
		},
		DEFAULT => -31,
		GOTOS => {
			'ul' => 21,
			'blockelement' => 8,
			'olbody' => 23,
			'ref' => 22,
			'para' => 12,
			'section' => 11,
			'dlbody' => 24,
			'block_elem' => 25,
			'ol' => 17,
			'spe_verb' => 16,
			'hr' => 27,
			'inlinenodes' => 28,
			'text' => 18,
			'verb' => 19,
			'ulbody' => 30,
			'inlinenode' => 20,
			'dl' => 31
		}
	},
	{#State 62
		ACTIONS => {
			'ELEM' => 14,
			'TEXT' => 13,
			'COMMENT_DECL' => 50,
			'REFSTART' => 10,
			'DTEND' => 66
		},
		GOTOS => {
			'ref' => 22,
			'text' => 18,
			'inlinenode' => 49
		}
	},
	{#State 63
		ACTIONS => {
			'SECTION_IN' => 7,
			'VERB' => 9,
			'REFSTART' => 10,
			'HR' => 26,
			'TEXT' => 13,
			'ELEM' => 14,
			'BLOCK_ELEM' => 15,
			'SPE_VERB' => 29,
			'INDENT' => 32
		},
		DEFAULT => -27,
		GOTOS => {
			'ul' => 21,
			'blockelement' => 8,
			'olbody' => 23,
			'ref' => 22,
			'para' => 12,
			'section' => 11,
			'dlbody' => 24,
			'block_elem' => 25,
			'ol' => 17,
			'spe_verb' => 16,
			'hr' => 27,
			'inlinenodes' => 28,
			'text' => 18,
			'verb' => 19,
			'ulbody' => 30,
			'inlinenode' => 20,
			'dl' => 31
		}
	},
	{#State 64
		ACTIONS => {
			'SECTION_IN' => 7,
			'VERB' => 9,
			'REFSTART' => 10,
			'HR' => 26,
			'SECTION_OUT' => 67,
			'TEXT' => 13,
			'ELEM' => 14,
			'BLOCK_ELEM' => 15,
			'SPE_VERB' => 29,
			'INDENT' => 32
		},
		DEFAULT => -22,
		GOTOS => {
			'ul' => 21,
			'blockelement' => 8,
			'olbody' => 23,
			'ref' => 22,
			'para' => 12,
			'section' => 11,
			'dlbody' => 24,
			'block_elem' => 25,
			'ol' => 17,
			'spe_verb' => 16,
			'hr' => 27,
			'inlinenodes' => 28,
			'text' => 18,
			'verb' => 19,
			'ulbody' => 30,
			'inlinenode' => 20,
			'dl' => 31
		}
	},
	{#State 65
		DEFAULT => -23
	},
	{#State 66
		DEFAULT => -4,
		GOTOS => {
			'blockelements' => 68
		}
	},
	{#State 67
		DEFAULT => -21
	},
	{#State 68
		ACTIONS => {
			'SECTION_IN' => 7,
			'VERB' => 9,
			'REFSTART' => 10,
			'HR' => 26,
			'TEXT' => 13,
			'ELEM' => 14,
			'BLOCK_ELEM' => 15,
			'SPE_VERB' => 29,
			'INDENT' => 32
		},
		DEFAULT => -35,
		GOTOS => {
			'ul' => 21,
			'blockelement' => 8,
			'olbody' => 23,
			'ref' => 22,
			'para' => 12,
			'section' => 11,
			'dlbody' => 24,
			'block_elem' => 25,
			'ol' => 17,
			'spe_verb' => 16,
			'hr' => 27,
			'inlinenodes' => 28,
			'text' => 18,
			'verb' => 19,
			'ulbody' => 30,
			'inlinenode' => 20,
			'dl' => 31
		}
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'document', 1, undef
	],
	[#Rule 2
		 'document', 2,
sub
#line 20 "lib/Text/PAN/Parser.yp"
{ $_[2] }
	],
	[#Rule 3
		 'doc', 1,
sub
#line 25 "lib/Text/PAN/Parser.yp"
{ $_[0]->addchildren($_[0]->root, $_[1]) }
	],
	[#Rule 4
		 'blockelements', 0,
sub
#line 34 "lib/Text/PAN/Parser.yp"
{ [] }
	],
	[#Rule 5
		 'blockelements', 2,
sub
#line 35 "lib/Text/PAN/Parser.yp"
{ push @{$_[1]}, $_[2]; $_[1] }
	],
	[#Rule 6
		 'blockelement', 1, undef
	],
	[#Rule 7
		 'blockelement', 1, undef
	],
	[#Rule 8
		 'blockelement', 1, undef
	],
	[#Rule 9
		 'blockelement', 1, undef
	],
	[#Rule 10
		 'blockelement', 1, undef
	],
	[#Rule 11
		 'blockelement', 1, undef
	],
	[#Rule 12
		 'blockelement', 1, undef
	],
	[#Rule 13
		 'blockelement', 1, undef
	],
	[#Rule 14
		 'blockelement', 1, undef
	],
	[#Rule 15
		 'block_elem', 1, undef
	],
	[#Rule 16
		 'block_elem', 1, undef
	],
	[#Rule 17
		 'block_elem', 1, undef
	],
	[#Rule 18
		 'block_elem', 2,
sub
#line 58 "lib/Text/PAN/Parser.yp"
{$_[1]}
	],
	[#Rule 19
		 'hr', 1,
sub
#line 67 "lib/Text/PAN/Parser.yp"
{$_[0]->genelem('hr')}
	],
	[#Rule 20
		 'hr', 2,
sub
#line 68 "lib/Text/PAN/Parser.yp"
{$_[1]}
	],
	[#Rule 21
		 'section', 5,
sub
#line 74 "lib/Text/PAN/Parser.yp"
{
            $_[0]->genelem(section => [$_[2], @{$_[4]}], { id => __id() })
            }
	],
	[#Rule 22
		 'section', 4,
sub
#line 77 "lib/Text/PAN/Parser.yp"
{
            $_[0]->genelem(section => [$_[2], @{$_[4]}], { id => __id() })
        }
	],
	[#Rule 23
		 'sectionheader', 3,
sub
#line 83 "lib/Text/PAN/Parser.yp"
{
              $_[0]->genelem(head => $_[2]);
          }
	],
	[#Rule 24
		 'ul', 2,
sub
#line 93 "lib/Text/PAN/Parser.yp"
{ $_[0]->genelem( ul => $_[1] )}
	],
	[#Rule 25
		 'ulbody', 2,
sub
#line 96 "lib/Text/PAN/Parser.yp"
{ [$_[2]] }
	],
	[#Rule 26
		 'ulbody', 2,
sub
#line 97 "lib/Text/PAN/Parser.yp"
{ push @{$_[1]}, $_[2]; $_[1]; }
	],
	[#Rule 27
		 'ulitem', 2,
sub
#line 101 "lib/Text/PAN/Parser.yp"
{  $_[0]->genelem(item => $_[2] ) }
	],
	[#Rule 28
		 'ol', 2,
sub
#line 106 "lib/Text/PAN/Parser.yp"
{ $_[0]->genelem( ol => $_[1] )}
	],
	[#Rule 29
		 'olbody', 2,
sub
#line 108 "lib/Text/PAN/Parser.yp"
{ [$_[2]] }
	],
	[#Rule 30
		 'olbody', 2,
sub
#line 109 "lib/Text/PAN/Parser.yp"
{ push @{$_[1]}, $_[2]; $_[1]; }
	],
	[#Rule 31
		 'olitem', 2,
sub
#line 111 "lib/Text/PAN/Parser.yp"
{  $_[0]->genelem(item => $_[2] ) }
	],
	[#Rule 32
		 'dl', 2,
sub
#line 116 "lib/Text/PAN/Parser.yp"
{ $_[0]->genelem( dl => $_[1] ) }
	],
	[#Rule 33
		 'dlbody', 2,
sub
#line 119 "lib/Text/PAN/Parser.yp"
{ [$_[2]] }
	],
	[#Rule 34
		 'dlbody', 2,
sub
#line 120 "lib/Text/PAN/Parser.yp"
{ push @{$_[1]}, $_[2]; $_[1]; }
	],
	[#Rule 35
		 'dlitem', 4,
sub
#line 124 "lib/Text/PAN/Parser.yp"
{ $_[0]->genelem(item => [$_[0]->genelem(about => $_[2]),
                                          @{$_[4]}]) }
	],
	[#Rule 36
		 'spe_verb', 1,
sub
#line 132 "lib/Text/PAN/Parser.yp"
{$_[0]->genelem(verb => [$_[1]->{data}], $_[1]->{attrs})}
	],
	[#Rule 37
		 'verb', 1,
sub
#line 138 "lib/Text/PAN/Parser.yp"
{$_[0]->genelem(verb => [$_[1]])}
	],
	[#Rule 38
		 'para', 1,
sub
#line 146 "lib/Text/PAN/Parser.yp"
{ $_[0]->genelem(p => $_[1]) }
	],
	[#Rule 39
		 'para', 2,
sub
#line 147 "lib/Text/PAN/Parser.yp"
{ $_[0]->genelem(p => $_[1]) }
	],
	[#Rule 40
		 'inlinenodes', 1,
sub
#line 153 "lib/Text/PAN/Parser.yp"
{ [$_[1]] }
	],
	[#Rule 41
		 'inlinenodes', 2,
sub
#line 154 "lib/Text/PAN/Parser.yp"
{ push @{$_[1]}, $_[2]; $_[1] }
	],
	[#Rule 42
		 'inlinenodes', 2,
sub
#line 155 "lib/Text/PAN/Parser.yp"
{ $_[1] }
	],
	[#Rule 43
		 'inlinenode', 1, undef
	],
	[#Rule 44
		 'inlinenode', 1, undef
	],
	[#Rule 45
		 'inlinenode', 1, undef
	],
	[#Rule 46
		 'text', 1, undef
	],
	[#Rule 47
		 'text', 2,
sub
#line 169 "lib/Text/PAN/Parser.yp"
{ $_[1] . $_[2] }
	],
	[#Rule 48
		 'blank', 0, undef
	],
	[#Rule 49
		 'blank', 1, undef
	],
	[#Rule 50
		 'blank', 2, undef
	],
	[#Rule 51
		 'bl', 1, undef
	],
	[#Rule 52
		 'bl', 2, undef
	],
	[#Rule 53
		 'ref', 3,
sub
#line 187 "lib/Text/PAN/Parser.yp"
{$_[0]->genelem(ref => $_[2] , {name => $_[0]->value_of($_[2])})}
	]
],
                                  @_);
    bless($self,$class);
}

#line 194 "lib/Text/PAN/Parser.yp"



1;

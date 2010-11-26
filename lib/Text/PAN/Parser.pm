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

#-*-cperl-*-

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
			'blank_elems' => 4
		},
		DEFAULT => -4,
		GOTOS => {
			'blockelements' => 1,
			'document' => 2,
			'doc' => 3
		}
	},
	{#State 1
		ACTIONS => {
			'SECTION_IN' => 5,
			'VERB' => 7,
			'REFSTART' => 8,
			'HR' => 26,
			'BLOCK_COMMENT' => 15,
			'TEXT' => 11,
			'INLINE_COMMENT' => 12,
			'ELEM' => 13,
			'BLOCK_ELEM' => 14,
			'SPE_VERB' => 29,
			'INDENT' => 32
		},
		DEFAULT => -3,
		GOTOS => {
			'ul' => 21,
			'blockelement' => 6,
			'olbody' => 23,
			'ref' => 22,
			'para' => 10,
			'section' => 9,
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
			'' => 33
		}
	},
	{#State 3
		DEFAULT => -46,
		GOTOS => {
			'blank' => 34
		}
	},
	{#State 4
		DEFAULT => -4,
		GOTOS => {
			'blockelements' => 1,
			'doc' => 35
		}
	},
	{#State 5
		ACTIONS => {
			'SECTION_HEADER' => 37
		},
		GOTOS => {
			'sectionheader' => 36
		}
	},
	{#State 6
		DEFAULT => -5
	},
	{#State 7
		DEFAULT => -35
	},
	{#State 8
		ACTIONS => {
			'ELEM' => 13,
			'INLINE_COMMENT' => 12,
			'TEXT' => 11,
			'REFSTART' => 8
		},
		GOTOS => {
			'inlinenodes' => 38,
			'ref' => 22,
			'text' => 18,
			'inlinenode' => 20
		}
	},
	{#State 9
		DEFAULT => -15
	},
	{#State 10
		DEFAULT => -6
	},
	{#State 11
		DEFAULT => -44
	},
	{#State 12
		DEFAULT => -42
	},
	{#State 13
		DEFAULT => -41
	},
	{#State 14
		DEFAULT => -8
	},
	{#State 15
		DEFAULT => -9
	},
	{#State 16
		DEFAULT => -11
	},
	{#State 17
		DEFAULT => -12
	},
	{#State 18
		ACTIONS => {
			'TEXT' => 39
		},
		DEFAULT => -40
	},
	{#State 19
		DEFAULT => -10
	},
	{#State 20
		DEFAULT => -38
	},
	{#State 21
		DEFAULT => -13
	},
	{#State 22
		DEFAULT => -43
	},
	{#State 23
		ACTIONS => {
			'DEDENT' => 41,
			'OLBULLET' => 42
		},
		GOTOS => {
			'olitem' => 40
		}
	},
	{#State 24
		ACTIONS => {
			'DTSTART' => 44
		},
		DEFAULT => -46,
		GOTOS => {
			'blank' => 43,
			'dlitem' => 45
		}
	},
	{#State 25
		DEFAULT => -46,
		GOTOS => {
			'blank' => 46
		}
	},
	{#State 26
		DEFAULT => -17
	},
	{#State 27
		ACTIONS => {
			'BL' => 47
		},
		DEFAULT => -16,
		GOTOS => {
			'bl' => 48
		}
	},
	{#State 28
		ACTIONS => {
			'REFSTART' => 8,
			'TEXT' => 11,
			'INLINE_COMMENT' => 12,
			'ELEM' => 13,
			'BL' => 47
		},
		DEFAULT => -36,
		GOTOS => {
			'ref' => 22,
			'text' => 18,
			'inlinenode' => 49,
			'bl' => 50
		}
	},
	{#State 29
		DEFAULT => -34
	},
	{#State 30
		ACTIONS => {
			'DEDENT' => 52,
			'ULBULLET' => 51
		},
		GOTOS => {
			'ulitem' => 53
		}
	},
	{#State 31
		DEFAULT => -14
	},
	{#State 32
		ACTIONS => {
			'OLBULLET' => 42,
			'DTSTART' => 44,
			'ULBULLET' => 51
		},
		GOTOS => {
			'olitem' => 54,
			'dlitem' => 55,
			'ulitem' => 56
		}
	},
	{#State 33
		DEFAULT => 0
	},
	{#State 34
		ACTIONS => {
			'BL' => 47
		},
		DEFAULT => -1,
		GOTOS => {
			'bl' => 57
		}
	},
	{#State 35
		DEFAULT => -46,
		GOTOS => {
			'blank' => 58
		}
	},
	{#State 36
		DEFAULT => -46,
		GOTOS => {
			'blank' => 59
		}
	},
	{#State 37
		ACTIONS => {
			'ELEM' => 13,
			'INLINE_COMMENT' => 12,
			'TEXT' => 11,
			'REFSTART' => 8
		},
		GOTOS => {
			'inlinenodes' => 60,
			'ref' => 22,
			'text' => 18,
			'inlinenode' => 20
		}
	},
	{#State 38
		ACTIONS => {
			'ELEM' => 13,
			'INLINE_COMMENT' => 12,
			'TEXT' => 11,
			'REFEND' => 61,
			'REFSTART' => 8
		},
		GOTOS => {
			'ref' => 22,
			'text' => 18,
			'inlinenode' => 49
		}
	},
	{#State 39
		DEFAULT => -45
	},
	{#State 40
		DEFAULT => -28
	},
	{#State 41
		DEFAULT => -26
	},
	{#State 42
		DEFAULT => -4,
		GOTOS => {
			'blockelements' => 62
		}
	},
	{#State 43
		ACTIONS => {
			'DEDENT' => 63,
			'BL' => 47
		},
		GOTOS => {
			'bl' => 57
		}
	},
	{#State 44
		ACTIONS => {
			'ELEM' => 13,
			'INLINE_COMMENT' => 12,
			'TEXT' => 11,
			'REFSTART' => 8
		},
		GOTOS => {
			'inlinenodes' => 64,
			'ref' => 22,
			'text' => 18,
			'inlinenode' => 20
		}
	},
	{#State 45
		DEFAULT => -32
	},
	{#State 46
		ACTIONS => {
			'BL' => 47
		},
		DEFAULT => -7,
		GOTOS => {
			'bl' => 57
		}
	},
	{#State 47
		DEFAULT => -48
	},
	{#State 48
		ACTIONS => {
			'BL' => 65
		},
		DEFAULT => -18
	},
	{#State 49
		DEFAULT => -39
	},
	{#State 50
		ACTIONS => {
			'BL' => 65
		},
		DEFAULT => -37
	},
	{#State 51
		DEFAULT => -4,
		GOTOS => {
			'blockelements' => 66
		}
	},
	{#State 52
		DEFAULT => -22
	},
	{#State 53
		DEFAULT => -24
	},
	{#State 54
		DEFAULT => -27
	},
	{#State 55
		DEFAULT => -31
	},
	{#State 56
		DEFAULT => -23
	},
	{#State 57
		ACTIONS => {
			'BL' => 65
		},
		DEFAULT => -47
	},
	{#State 58
		ACTIONS => {
			'BL' => 47
		},
		DEFAULT => -2,
		GOTOS => {
			'bl' => 57
		}
	},
	{#State 59
		ACTIONS => {
			'BL' => 47
		},
		DEFAULT => -4,
		GOTOS => {
			'blockelements' => 67,
			'bl' => 57
		}
	},
	{#State 60
		ACTIONS => {
			'ELEM' => 13,
			'INLINE_COMMENT' => 12,
			'TEXT' => 11,
			'BR' => 68,
			'REFSTART' => 8
		},
		GOTOS => {
			'ref' => 22,
			'text' => 18,
			'inlinenode' => 49
		}
	},
	{#State 61
		DEFAULT => -50
	},
	{#State 62
		ACTIONS => {
			'SECTION_IN' => 5,
			'VERB' => 7,
			'REFSTART' => 8,
			'HR' => 26,
			'BLOCK_ELEM' => 14,
			'TEXT' => 11,
			'INLINE_COMMENT' => 12,
			'ELEM' => 13,
			'BLOCK_COMMENT' => 15,
			'SPE_VERB' => 29,
			'INDENT' => 32
		},
		DEFAULT => -29,
		GOTOS => {
			'ul' => 21,
			'blockelement' => 6,
			'olbody' => 23,
			'ref' => 22,
			'para' => 10,
			'section' => 9,
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
	{#State 63
		DEFAULT => -30
	},
	{#State 64
		ACTIONS => {
			'ELEM' => 13,
			'INLINE_COMMENT' => 12,
			'TEXT' => 11,
			'REFSTART' => 8,
			'DTEND' => 69
		},
		GOTOS => {
			'ref' => 22,
			'text' => 18,
			'inlinenode' => 49
		}
	},
	{#State 65
		DEFAULT => -49
	},
	{#State 66
		ACTIONS => {
			'SECTION_IN' => 5,
			'VERB' => 7,
			'REFSTART' => 8,
			'HR' => 26,
			'BLOCK_ELEM' => 14,
			'TEXT' => 11,
			'INLINE_COMMENT' => 12,
			'ELEM' => 13,
			'BLOCK_COMMENT' => 15,
			'SPE_VERB' => 29,
			'INDENT' => 32
		},
		DEFAULT => -25,
		GOTOS => {
			'ul' => 21,
			'blockelement' => 6,
			'olbody' => 23,
			'ref' => 22,
			'para' => 10,
			'section' => 9,
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
	{#State 67
		ACTIONS => {
			'SECTION_IN' => 5,
			'VERB' => 7,
			'REFSTART' => 8,
			'SECTION_OUT' => 70,
			'BLOCK_ELEM' => 14,
			'BLOCK_COMMENT' => 15,
			'TEXT' => 11,
			'INLINE_COMMENT' => 12,
			'ELEM' => 13,
			'HR' => 26,
			'SPE_VERB' => 29,
			'INDENT' => 32
		},
		DEFAULT => -20,
		GOTOS => {
			'ul' => 21,
			'blockelement' => 6,
			'olbody' => 23,
			'ref' => 22,
			'para' => 10,
			'section' => 9,
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
	{#State 68
		DEFAULT => -21
	},
	{#State 69
		DEFAULT => -4,
		GOTOS => {
			'blockelements' => 71
		}
	},
	{#State 70
		DEFAULT => -19
	},
	{#State 71
		ACTIONS => {
			'SECTION_IN' => 5,
			'VERB' => 7,
			'REFSTART' => 8,
			'HR' => 26,
			'BLOCK_ELEM' => 14,
			'TEXT' => 11,
			'INLINE_COMMENT' => 12,
			'ELEM' => 13,
			'BLOCK_COMMENT' => 15,
			'SPE_VERB' => 29,
			'INDENT' => 32
		},
		DEFAULT => -33,
		GOTOS => {
			'ul' => 21,
			'blockelement' => 6,
			'olbody' => 23,
			'ref' => 22,
			'para' => 10,
			'section' => 9,
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
		 'document', 2,
sub
#line 20 "lib/Text/PAN/Parser.yp"
{ $_[1] }
	],
	[#Rule 2
		 'document', 3,
sub
#line 21 "lib/Text/PAN/Parser.yp"
{ $_[2] }
	],
	[#Rule 3
		 'doc', 1,
sub
#line 26 "lib/Text/PAN/Parser.yp"
{ $_[0]->addchildren($_[0]->root, $_[1]) }
	],
	[#Rule 4
		 'blockelements', 0,
sub
#line 35 "lib/Text/PAN/Parser.yp"
{ [] }
	],
	[#Rule 5
		 'blockelements', 2,
sub
#line 36 "lib/Text/PAN/Parser.yp"
{ push @{$_[1]}, $_[2]; $_[1] }
	],
	[#Rule 6
		 'blockelement', 1, undef
	],
	[#Rule 7
		 'blockelement', 2,
sub
#line 45 "lib/Text/PAN/Parser.yp"
{$_[1]}
	],
	[#Rule 8
		 'block_elem', 1, undef
	],
	[#Rule 9
		 'block_elem', 1, undef
	],
	[#Rule 10
		 'block_elem', 1, undef
	],
	[#Rule 11
		 'block_elem', 1, undef
	],
	[#Rule 12
		 'block_elem', 1, undef
	],
	[#Rule 13
		 'block_elem', 1, undef
	],
	[#Rule 14
		 'block_elem', 1, undef
	],
	[#Rule 15
		 'block_elem', 1, undef
	],
	[#Rule 16
		 'block_elem', 1, undef
	],
	[#Rule 17
		 'hr', 1,
sub
#line 65 "lib/Text/PAN/Parser.yp"
{$_[0]->genelem('hr')}
	],
	[#Rule 18
		 'hr', 2,
sub
#line 66 "lib/Text/PAN/Parser.yp"
{$_[1]}
	],
	[#Rule 19
		 'section', 5,
sub
#line 72 "lib/Text/PAN/Parser.yp"
{
            $_[0]->genelem(section => [$_[2], @{$_[4]}], { id => __id() })
            }
	],
	[#Rule 20
		 'section', 4,
sub
#line 75 "lib/Text/PAN/Parser.yp"
{
            $_[0]->genelem(section => [$_[2], @{$_[4]}], { id => __id() })
        }
	],
	[#Rule 21
		 'sectionheader', 3,
sub
#line 81 "lib/Text/PAN/Parser.yp"
{
              $_[0]->genelem(head => $_[2]);
          }
	],
	[#Rule 22
		 'ul', 2,
sub
#line 91 "lib/Text/PAN/Parser.yp"
{ $_[0]->genelem( ul => $_[1] )}
	],
	[#Rule 23
		 'ulbody', 2,
sub
#line 94 "lib/Text/PAN/Parser.yp"
{ [$_[2]] }
	],
	[#Rule 24
		 'ulbody', 2,
sub
#line 95 "lib/Text/PAN/Parser.yp"
{ push @{$_[1]}, $_[2]; $_[1]; }
	],
	[#Rule 25
		 'ulitem', 2,
sub
#line 99 "lib/Text/PAN/Parser.yp"
{  $_[0]->genelem(item => $_[2] ) }
	],
	[#Rule 26
		 'ol', 2,
sub
#line 104 "lib/Text/PAN/Parser.yp"
{ $_[0]->genelem( ol => $_[1] )}
	],
	[#Rule 27
		 'olbody', 2,
sub
#line 106 "lib/Text/PAN/Parser.yp"
{ [$_[2]] }
	],
	[#Rule 28
		 'olbody', 2,
sub
#line 107 "lib/Text/PAN/Parser.yp"
{ push @{$_[1]}, $_[2]; $_[1]; }
	],
	[#Rule 29
		 'olitem', 2,
sub
#line 109 "lib/Text/PAN/Parser.yp"
{  $_[0]->genelem(item => $_[2] ) }
	],
	[#Rule 30
		 'dl', 3,
sub
#line 114 "lib/Text/PAN/Parser.yp"
{ $_[0]->genelem( dl => $_[1] ) }
	],
	[#Rule 31
		 'dlbody', 2,
sub
#line 117 "lib/Text/PAN/Parser.yp"
{ [$_[2]] }
	],
	[#Rule 32
		 'dlbody', 2,
sub
#line 118 "lib/Text/PAN/Parser.yp"
{ push @{$_[1]}, $_[2]; $_[1]; }
	],
	[#Rule 33
		 'dlitem', 4,
sub
#line 122 "lib/Text/PAN/Parser.yp"
{ $_[0]->genelem(item => [$_[0]->genelem(about => $_[2]),
                                          @{$_[4]}]) }
	],
	[#Rule 34
		 'spe_verb', 1,
sub
#line 130 "lib/Text/PAN/Parser.yp"
{$_[0]->genelem(verb => [$_[1]->{data}], $_[1]->{attrs})}
	],
	[#Rule 35
		 'verb', 1,
sub
#line 136 "lib/Text/PAN/Parser.yp"
{$_[0]->genelem(verb => [$_[1]])}
	],
	[#Rule 36
		 'para', 1,
sub
#line 143 "lib/Text/PAN/Parser.yp"
{ $_[0]->genelem(p => $_[1]) }
	],
	[#Rule 37
		 'para', 2,
sub
#line 144 "lib/Text/PAN/Parser.yp"
{ $_[0]->genelem(p => $_[1]) }
	],
	[#Rule 38
		 'inlinenodes', 1,
sub
#line 149 "lib/Text/PAN/Parser.yp"
{ [$_[1]] }
	],
	[#Rule 39
		 'inlinenodes', 2,
sub
#line 150 "lib/Text/PAN/Parser.yp"
{ push @{$_[1]}, $_[2]; $_[1] }
	],
	[#Rule 40
		 'inlinenode', 1, undef
	],
	[#Rule 41
		 'inlinenode', 1, undef
	],
	[#Rule 42
		 'inlinenode', 1, undef
	],
	[#Rule 43
		 'inlinenode', 1, undef
	],
	[#Rule 44
		 'text', 1, undef
	],
	[#Rule 45
		 'text', 2,
sub
#line 164 "lib/Text/PAN/Parser.yp"
{ $_[1] . $_[2] }
	],
	[#Rule 46
		 'blank', 0, undef
	],
	[#Rule 47
		 'blank', 2, undef
	],
	[#Rule 48
		 'bl', 1, undef
	],
	[#Rule 49
		 'bl', 2, undef
	],
	[#Rule 50
		 'ref', 3,
sub
#line 180 "lib/Text/PAN/Parser.yp"
{ $_[0]->genelem(ref => $_[2] ,
                                                       +{name =>
                                                         $_[0]->value_of($_[2])
                                                        })}
	]
],
                                  @_);
    bless($self,$class);
}

#line 188 "lib/Text/PAN/Parser.yp"



1;

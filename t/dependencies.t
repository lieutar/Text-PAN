
use strict;
use warnings;
use Test::More;
eval {
  use Test::Dependencies
    ( exclude => [qw(
                      Test::Dependencies
                      Test::Perl::Critic
                      Test::Pod
                      Test::Pod::Coverage
                      Text::PAN
                      t::lib::Parser::TestLib
                      t::lib::Tokenizer::TestLib
                   )],
      style   => 'light' );
};
plan skip_all => "Test::Dependencies required for testing" if $@;
ok_dependencies();

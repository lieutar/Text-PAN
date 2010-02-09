#!perl -T
use strict;
use warnings;
use Test::More;
BEGIN{
eval "use Test::Pod::Coverage 1.04";
}
plan skip_all =>
  "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;

my $IGNORE =
  sprintf("\\A(?:%s)\\Z",
          join "|",
          qw(
              Text::PAN::Parser\b.*
              Text::PAN::Stream\b.*
              Text::PAN::Element::Builder
              Text::PAN::Role::Tokenizer
              Text::PAN::Tokenizer::.*
           ));
my @mods = grep { !/$IGNORE/ } all_modules;
plan tests => scalar(@mods);
pod_coverage_ok ($_) foreach @mods;


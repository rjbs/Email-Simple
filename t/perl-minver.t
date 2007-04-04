#!perl
use strict;
use Test::More;

eval { use Test::MinimumVersion };
plan skip_all => "this test requires Test::MinimumVersion" if $@;

minimum_version_ok('5.005030');

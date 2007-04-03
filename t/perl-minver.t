#!perl
use strict;
use Test::More;

eval { require Test::MinimumVersion };
plan skip_all => "this test requires Test::MinimumVersion" if $@;

plan tests => 1;
Test::MinimumVersion->import;
minimum_version_ok('5.005030');

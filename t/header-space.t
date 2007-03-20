#!perl -T
use strict;
use warnings;

use Test::More tests => 8;
use Email::Simple;

my @crlf = (
  'CR'   => "\x0d",
  'CRLF' => "\x0d\x0a",
  'LF'   => "\x0a",
  'LFCR' => "\x0a\x0d",
);

while (my ($name, $eol) = splice @crlf, 0, 2) {
  my $m = Email::Simple->new("Foo-Bar: Baz${eol}${eol}test${eol}");
  is($m->header('foo-bar'), 'Baz', "no spaces trail with $name");

  is($m->crlf, $eol, "correctly detected crlf value");
}


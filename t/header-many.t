#!perl
use strict;
use Test::More tests => 12;

use_ok('Email::Simple');

my $email_text = <<END_MESSAGE;
Alpha: this header comes first
Bravo: this header comes second
Alpha: this header comes third

The body is irrelevant.
END_MESSAGE

my $email = Email::Simple->new($email_text);
isa_ok($email, "Email::Simple");

is_deeply(
  [ $email->header('alpha') ],
  [ 'this header comes first', 'this header comes third' ],
  "we get both values, in order, for a multi-entry header",
);

is_deeply(
  [ $email->header_pairs ],
  [
    Alpha => 'this header comes first',
    Bravo => 'this header comes second',
    Alpha => 'this header comes third',
  ],
  "and we get everything in order for header_pairs",
);

$email->header_set(alpha => ('header one', 'header three'));

is_deeply(
  [ $email->header('alpha') ],
  [ 'header one', 'header three' ],
  "headers are replaced in order",
);

is_deeply(
  [ $email->header_pairs ],
  [
    Alpha => 'header one',
    Bravo => 'this header comes second',
    Alpha => 'header three',
  ],
  "and we still get everything in order for header_pairs",
);

$email->header_set(alpha => qw(h1 h3 h4));

is_deeply(
  [ $email->header('alpha') ],
  [ qw(h1 h3 h4) ],
  "headers are replaced in order, extras appended",
);

is_deeply(
  [ $email->header_pairs ],
  [
    Alpha => 'h1',
    Bravo => 'this header comes second',
    Alpha => 'h3',
    Alpha => 'h4',
  ],
  "and we still get everything in order for header_pairs",
);

$email->header_set(alpha => 'one is the loneliest header');

is_deeply(
  [ $email->header('alpha') ],
  [ 'one is the loneliest header' ],
  "and we drop down to one value for alpha header ok",
);

is_deeply(
  [ $email->header_pairs ],
  [
    Alpha => 'one is the loneliest header',
    Bravo => 'this header comes second',
  ],
  "and we still get everything in order for header_pairs",
);

$email->header_set(Gamma => 'gammalon');

is_deeply(
  [ $email->header_pairs ],
  [
    Alpha => 'one is the loneliest header',
    Bravo => 'this header comes second',
    Gamma => 'gammalon',
  ],
  "a third header goes in at the end",
);

$email->header_set(alpha => ('header one', 'header omega'));

is_deeply(
  [ $email->header_pairs ],
  [
    Alpha => 'header one',
    Bravo => 'this header comes second',
    Gamma => 'gammalon',
    Alpha => 'header omega',
  ],
  "and re-adding to the previously third header puts it fourth",
);

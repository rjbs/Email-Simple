#!perl
use strict;
use warnings;

use Test::More tests => 3;

use_ok 'Email::Simple';
use_ok 'Email::Simple::Creator';

my $body = "This body uses\x0d"
         . "LF only, and not\x0d"
         . "CRLF like it might ought to do.";

my $email = Email::Simple->create(
  body   => $body,
  header => [
    Subject => 'all tests and no code make rjbs something something',
    From    => 'jack',
    To      => 'sissy',
  ],
);

unlike(
  $email->as_string,
  qr/(?<!\x0d)\x0a/,
  "message has no LF that aren't preceded by CR",
);


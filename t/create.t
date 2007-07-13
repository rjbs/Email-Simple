use strict;
use warnings;

use Test::More tests => 12;

use_ok 'Email::Simple';
use_ok 'Email::Simple::Creator';

sub tested_email {
  my (%args) = @_;

  my $email = Email::Simple->create(%args);
  isa_ok $email, 'Email::Simple';

  my $string = $email->as_string;

  my @last_two = (
    substr($string, -2, 1),
    substr($string, -1, 1),
  );
  
  is(
    sprintf("%03u %03u", map { ord } @last_two),
    '013 010',
    'stringified message ends with std CRLF'
  );

  return $email;
}

{ # should get an automatic date header
  my $email = tested_email(
    header => [
      To => 'you',
    ],
    body => 'test test',
  );

  like(
    $email->header('date'),
    qr/^[A-Z][a-z]{2},/, # lame -- rjbs, 2007-02-23
    "we got an auto-generated date header starting with a DOW",
  );
}

{ # no date header, we provided one
  my $email = tested_email(
    header => [
      Date       => 'testing',
      'X-Header' => 'one',
      'X-Header' => 'two',
      'X-Header' => 'three',
    ],
    body => q[This is a multi-
    line message.],
  );

  my $expected = <<'END_MESSAGE';
Date: testing
X-Header: one
X-Header: two
X-Header: three

This is a multi-
    line message.
END_MESSAGE

  my $string = $email->as_string;
  $string  =~ s/\x0d\x0a/\n/gsm;

  is(
    $string,
    $expected,
    "we got just the string we expected",
  );
}

{ # a few headers with false values
  my $email = tested_email(
    header => [
      Date  => undef,
      Zero  => 0,
      Empty => '',
    ],
    body => "The body is uninteresting.",
  );

  is_deeply(
    [ $email->header_pairs ],
    [
      Date => '',
      Zero => 0,
      Empty => '',
    ],
    "got the false headers back we want",
  );

  my $expected = <<'END_MESSAGE';
Date: 
Zero: 0
Empty: 

The body is uninteresting.
END_MESSAGE

  my $string = $email->as_string;
  $string  =~ s/\x0d\x0a/\n/gsm;

  is(
    $string,
    $expected,
    "we got just the string we expected",
  );
}

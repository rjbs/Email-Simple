use Test::More tests => 6;
use_ok 'Email::Simple::Creator';
use_ok 'Email::Simple';

sub test_email;

test_email 0 => {
  header => [
    To => 'you',
  ],
  body => 'test test',
} => <<__MESSAGE__;
To: you
Date: Thu, 17 Jun 2004 18:13:14 -0000

test test
__MESSAGE__

test_email 1 => {
  header => [
    Date => 'testing',
    'X-Header' => 'one',
    'X-Header' => 'two',
    'X-Header' => 'three',
  ],
  body => q[This is a multi-
  line message.],
} => <<__MESSAGE__;
Date: testing
X-Header: one
X-Header: two
X-Header: three

This is a multi-
  line message.
__MESSAGE__

sub test_email {
    my ($pass, $args, $message) = @_;
    my $email = Email::Simple->create(%{$args});
    print $email->as_string and return unless $message; # debugging
    isa_ok $email, 'Email::Simple';
    my $string = $email->as_string;
    $string  =~ s/\x0a\x0d/\n/g;
    $message =~ s/\x0a\x0d/\n/g;
    $pass ?
      is   $string, $message :
      isnt $string, $message;
}

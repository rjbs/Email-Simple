use Test::More tests => 17;
use strict;
$^W = 1;

use_ok 'Email::Simple';

my @emails;

push @emails, Email::Simple->new(<<'__MESSAGE__');
From: casey@geeknest.com
To: drain@example.com
Subject: Message in a bottle
__MESSAGE__

push @emails, Email::Simple->new(<<'__MESSAGE__');
From: casey@geeknest.com
To: drain@example.com
Subject: Message in a bottle
subject: second subject!

HELP!
__MESSAGE__

for my $email (@emails) {
  for my $method ('header_names', 'headers') {
    can_ok($email, $method);
    is_deeply(
      [ qw(From To Subject) ],
      [ $email->$method()   ],
      "have expected headers (via $method)"
    );
  }
}

my $warned;
$SIG{__WARN__} = sub { $warned = 1; warn $_[0]; };

my $email = Email::Simple->new('');

$warned = 0;
is_deeply([ $email->headers() ], [], 'method headers() returns empty list when no header was defined');
ok(!$warned, 'method headers() does not produce any warning when no header was defined');

$warned = 0;
is_deeply([ $email->header_names() ], [], 'method header_names() returns empty list when no header was defined');
ok(!$warned, 'method header_names() does not produce any warning when no header was defined');

$warned = 0;
is_deeply([ $email->header_raw('unknown') ], [], 'method header_raw returns empty list for unknwon header');
ok(!$warned, 'method header_raw() does not produce any warning when no header was defined');

$warned = 0;
is_deeply([ $email->header_raw_set('new_header', 'new_value') ], [ 'new_value' ], 'method header_raw_set returns new set value');
ok(!$warned, 'method header_raw_set() does not produce any warning when no header was defined');

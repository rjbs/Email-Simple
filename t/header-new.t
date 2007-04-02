use strict;

use Test::More tests => 7;

# This test could test all manner of Email::Simple::Header stuff, but is mostly
# just here specifically to test construction and sanity of result with both a
# string AND a reference to it. -- rjbs, 2006-11-29

BEGIN { use_ok('Email::Simple::Header'); }

my $header_string = <<'END_HEADER';
Foo: 1
Foo: 2
Bar: 3
Baz: 1
END_HEADER

for my $header_param ($header_string, \$header_string) {
  my $head = Email::Simple::Header->new($header_param);

  isa_ok($head, 'Email::Simple::Header');

  is_deeply(
    [ $head->header('foo') ],
    [ 1, 2 ],
    "multi-value header",
  );

  is_deeply(
    scalar $head->header('foo'),
    1,
    "single-value header",
  );
}

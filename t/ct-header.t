#!perl -w

use strict;

use Test::More tests => 4;

use Email::Simple;

# This asinine exception is made for Lotus Notes sending to Outlook.  When
# reconstituting this value (created by Lotus Notes), Outlook becomes unable to
# locate the MIME boundary.  The proper fix would be to note structure fields
# and analyze and reformat them correctly.  Fat chance.  -- rjbs, 2006-11-27

my $ct_text = qq{Content-Type: multipart/alternative; boundary="=_alternative 0065F3338525722E_="\n};

my $other_text = qq{Non-Content-Type: multipart/alternative; boundary="=_alternative 0065F3338525722E_="\n};

{
  my $count = my @lines = split /\n/, $other_text;
  is($count, 1, "we start with one line (non-Content-Type header)");
}

{
  my $email = Email::Simple->new($other_text);
  my $count = my @lines = split /\n/, $email->as_string;
  is($count, 2, "we end with two, because it wraps");
}

{
  my $count = my @lines = split /\n/, $ct_text;
  is($count, 1, "we start with one line (Content-Type header)");
}

{
  my $email = Email::Simple->new($ct_text);
  my $count = my @lines = split /\n/, $email->as_string;
  is($count, 1, "we end with one, because C-T doesn't wrap");
}

#!/usr/bin/perl
# This is a series of unit tests to ensure that things do what I think
# they do.
use strict;
use Email::Simple;

package Email::Simple;
use Test::More tests => 8;

# Simple "email", no body

my $text = "a\nb\nc\n";
my ($h, $b) = _split_head_from_body($text);
is($h, $text, "No body, everything's head");
is($b, "", "No body!");

# Simple "email", properly formed

$text = "a\n\nb\n";
($h, $b) = _split_head_from_body($text);
is($h, "a\n", "Simple mail, head OK");
is($b, "b\n", "Simple mail, body OK");

# Simple "email" with blank lines

$text = "a\n\nb\nc\n";
($h, $b) = _split_head_from_body($text);
is($h, "a\n", "Simple mail, head OK");
is($b, "b\nc\n", "Simple mail, body OK");

# Blank line as first line in email
$text = "a\n\n\nb\nc\n";
($h, $b) = _split_head_from_body($text);
is($h, "a\n", "Simple mail, head OK");
is($b, "\nb\nc\n", "Simple mail, body OK");


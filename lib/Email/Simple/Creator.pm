use strict;
use warnings;
package Email::Simple::Creator;
# ABSTRACT: private helper for building Email::Simple objects

sub _crlf {
  "\x0d\x0a";
}

sub _date_header {
  require Email::Date::Format;
  Email::Date::Format::email_date();
}

our @CARP_NOT = qw(Email::Simple Email::MIME);

sub _add_to_header {
  my ($class, $header, $key, $value) = @_;
  $value = '' unless defined $value;

  if ($value =~ s/[\x0a\x0b\x0c\x0d\x85\x{2028}\x{2029}]+/ /g) {
    Carp::carp("replaced vertical whitespace in $key header with space; this will become fatal in a future version");
  }

  $$header .= Email::Simple::Header->__fold_objless("$key: $value", 78, q{ }, $class->_crlf);
}

sub _finalize_header {
  my ($class, $header) = @_;
  $$header .= $class->_crlf;
}

1;

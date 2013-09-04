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

sub _add_to_header {
  my ($class, $header, $key, $value) = @_;
  $value = '' unless defined $value;
  $$header .= "$key: $value" . $class->_crlf;
}

sub _finalize_header {
  my ($class, $header) = @_;
  $$header .= $class->_crlf;
}

1;

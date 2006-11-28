package Email::Simple::Header;

use strict;
use Carp ();

$Email::Simple::Header::VERSION = '1.998';

my $crlf = qr/\x0a\x0d|\x0d\x0a|\x0a|\x0d/;  # We are liberal in what we accept.

=head1 NAME

Email::Simple::Header - the header of an Email::Simple message

=head1 SYNOPSIS

  my $email = Email::Simple->new($text);

  my $header = $email->head;
  print $header->as_string;

=head1 DESCRIPTION

This method implements the headers of an Email::Simple object.  It is a very
minimal interface, and is mostly for private consumption at the moment.

=head1 METHODS

=head2 new

  my $header = Email::Simple::Header->new($head, \%arg);

C<$head> is a string containing a valid email header, or a reference to such a
string.

Valid arguments are:

  crlf - the header's newline; defaults to "\n"

=cut

sub new {
  my ($class, $head, $arg) = @_;

  my $head_ref = ref $head ? $head : \$head;

  my $self = {};
  $self->{mycrlf} = $arg->{crlf} || "\n";

  my $headers = $class->_header_to_list($head_ref);

  for my $header (@$headers) {
    push @{ $self->{order} }, $header->[0];
    push @{ $self->{head}{ $header->[0] } }, $header->[1];
  }

  $self->{header_names} = { map { lc $_ => $_ } keys %{ $self->{head} } };

  bless $self => $class;
}

sub _header_to_list {
  my ($self, $head) = @_;

  my @headers;

  for (split /$crlf/, $$head) {
    if (s/^\s+// or not /^([^:]+):\s*(.*)/) {
      # This is a continuation line. We fold it onto the end of
      # the previous header.
      next if !@headers;  # Well, that sucks.  We're continuing nothing?

      $headers[-1][1] .= $headers[-1][1] ? " $_" : $_;
    } else {
      push @headers, [ $1, $2 ];
    }
  }

  return \@headers;
}


=head2 from_string

=head2 as_string

This returns the stringified header.

=cut

# RFC 2822, 3.6:
# ...for the purposes of this standard, header fields SHOULD NOT be reordered
# when a message is transported or transformed.  More importantly, the trace
# header fields and resent header fields MUST NOT be reordered, and SHOULD be
# kept in blocks prepended to the message.

sub as_string {
  my ($self) = @_;

  my $header_str = '';
  my @pairs      = $self->header_pairs;

  while (my ($name, $value) = splice @pairs, 0, 2) {
    $header_str .= $self->_header_as_string($name, $value);
  }

  return $header_str;
}

sub _header_as_string {
  my ($self, $field, $data) = @_;

  # Ignore "empty" headers
  return '' unless defined $data;

  my $string = "$field: $data";

  return ((length $string > 78) and (lc $field ne 'content-type'))
    ? $self->_fold($string)
    : ($string . $self->crlf);
}

sub _fold {
  my $self = shift;
  my $line = shift;

  # We know it will not contain any new lines at present
  my $folded = "";
  while ($line) {
    $line =~ s/^\s+//;
    if ($line =~ s/^(.{0,77})(\s|\z)//) {
      $folded .= $1 . $self->crlf;
      $folded .= " " if $line;
    } else {

      # Basically nothing we can do. :(
      $folded .= $line . $self->crlf;
      last;
    }
  }
  return $folded;
}

=head2 header_names

This method returns the unique header names found in this header, in no
particular order.

=cut

sub header_names {
  values %{ $_[0]->{header_names} };
}

=head2 header_pairs

This method returns all the field/value pairs in the header, in the order that
they appear in the header.

=cut

sub header_pairs {
  my ($self) = @_;

  my @headers;
  my %seen;

  for my $header (@{ $self->{order} }) {
    push @headers, ($header, $self->{head}{$header}[ $seen{$header}++ ]);
  }

  return @headers;
}

=head2 header

  my $first_value = $header->header($field);
  my @all_values  = $header->header($field);

This method returns the value or values of the given header field.  If the
named field does not appear in the header, this method returns false.

=cut

sub header {
  my ($self, $field) = @_;
  return
    unless (exists $self->{header_names}->{ lc $field })
    and $field = $self->{header_names}->{ lc $field };

  return wantarray
    ? @{ $self->{head}->{$field} }
    : $self->{head}->{$field}->[0];
}

=head2 header_set

  $header->header_set($field => @values);

This method updates the value of the given header.  Existing headers have their
values set in place.  Additional headers are added at the end.

=cut

sub header_set {
  my ($self, $field, @data) = @_;

  # I hate this block. -- rjbs, 2006-10-06
  if ($Email::Simple::GROUCHY) {
    Carp::croak "field name contains illegal characters"
      unless $field =~ /^[\x21-\x39\x3b-\x7e]+$/;
    Carp::carp "field name is not limited to hyphens and alphanumerics"
      unless $field =~ /^[\w-]+$/;
  }

  if (!exists $self->{header_names}->{ lc $field }) {
    $self->{header_names}->{ lc $field } = $field;

    # New fields are added to the end.
    push @{ $self->{order} }, $field;
  } else {
    $field = $self->{header_names}->{ lc $field };
  }

  my @loci =
    grep { lc $self->{order}[$_] eq lc $field } 0 .. $#{ $self->{order} };

  if (@loci > @data) {
    my $overage = @loci - @data;
    splice @{ $self->{order} }, $_, 1 for reverse @loci[ -$overage, $#loci ];
  } elsif (@data > @loci) {
    push @{ $self->{order} }, ($field) x (@data - @loci);
  }

  $self->{head}->{$field} = [@data];
  return wantarray ? @data : $data[0];
}

=head2 crlf

This method returns the newline string used in the header.

=cut

sub crlf { $_[0]->{mycrlf} }

1;

__END__

=head1 PERL EMAIL PROJECT

This module is maintained by the Perl Email Project

L<http://emailproject.perl.org/wiki/Email::Simple::Header>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Casey West

Copyright 2003 by Simon Cozens

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

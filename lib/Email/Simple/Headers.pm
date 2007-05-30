package Email::Simple::Headers;
use strict;

use vars qw[$VERSION];
$VERSION = '1.971';

use Carp ();
Carp::cluck 'Email::Simple::Headers is deprecated; using it does nothing'
  unless $ENV{HARNESS_ACTIVE};

1;

__END__

=head1 NAME

Email::Simple::Headers - a deprecated module that you shouldn't use!

=head1 DESCRIPTION

This module used to provide the method C<headers> for Email::Simple objects.
That method is now part of the Email::Simple module.  Loading this module will
emit a verbose diagnostic warning using C<Carp::cluck>.

=head1 SEE ALSO

L<Email::Simple>, L<Email::Simple::Header>

=cut

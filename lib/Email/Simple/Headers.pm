package Email::Simple::Headers;
use strict;

use vars qw[$VERSION];
$VERSION = '1.970';

# XXX: In the future, this should throw a "stop using me!" warning.
#      -- rjbs, 2006-08-01

1;

__END__

=head1 NAME

Email::Simple::Headers - a deprecated module that does nothing!

=head1 SYNOPSIS

  use Email::Simple;
  # use Email::Simple::Headers; # no longer needed as of 2006-08-17
  
  my $email = Email::Simple->new($string);
  
  print $email->header($_), "\n" for $email->headers;
  
=head1 DESCRIPTION

This module used to provide the method C<headers> for Email::Simple objects.
That method is now part of the Email::Simple module.

=head1 SEE ALSO

L<Email::Simple>

=head1 AUTHOR

Casey West, <F<casey@geeknest.com>>

=cut

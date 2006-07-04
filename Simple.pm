package Email::Simple;

use 5.00503;
use strict;
use Carp;

use vars qw($VERSION $GROUCHY);
$VERSION = '1.94';

my $crlf = qr/\x0a\x0d|\x0d\x0a|\x0a|\x0d/; # We are liberal in what we accept.
                                            # But then, so is a six dollar whore.

$GROUCHY = 0;

=head1 NAME

Email::Simple - Simple parsing of RFC2822 message format and headers

=head1 SYNOPSIS

    my $mail = Email::Simple->new($text);

    my $from_header = $mail->header("From");
    my @received = $mail->header("Received");

    $mail->header_set("From", 'Simon Cozens <simon@cpan.org>');

    my $old_body = $mail->body;
    $mail->body_set("Hello world\nSimon");

    print $mail->as_string;

    # AND THAT'S ALL.

=head1 DESCRIPTION

C<Email::Simple> is the first deliverable of the "Perl Email Project", a
reaction against the complexity and increasing bugginess of the
C<Mail::*> modules. In contrast, C<Email::*> modules are meant to be
simple to use and to maintain, pared to the bone, fast, minimal in their
external dependencies, and correct.

    Can you sum up plan 9 in layman's terms?
    It does everything Unix does only less reliably - kt

=head1 METHODS

Methods are deliberately kept to a minimum. This is meant to be simple.
No, I will not add method X. This is meant to be simple. Why doesn't it
have feature Y? Because it's meant to be simple.

=head2 new

Parse an email from a scalar containing an RFC2822 formatted message,
and return an object.

=cut

sub new {
    my ($class, $text) = @_;
    my ($head, $body, $mycrlf) = _split_head_from_body($text);
    my ($head_hash, $order) = _read_headers($head);
    bless {
        head => $head_hash,
        body => $body,
        order => $order,
        mycrlf => $mycrlf,
        header_names => { map { lc $_ => $_ } keys %$head_hash }
    }, $class;
}

sub _split_head_from_body {
    my $text = shift;
    # The body is simply a sequence of characters that
    # follows the header and is separated from the header by an empty
    # line (i.e., a line with nothing preceding the CRLF).
    #  - RFC 2822, section 2.1
    if ($text =~ /(.*?($crlf))\2(.*)/sm) {
        return ($1, ($3 || ''), $2);
    } else { # The body is, of course, optional.
        return ($text, "", "\n");
    }
}

# Header fields are lines composed of a field name, followed by a colon
# (":"), followed by a field body, and terminated by CRLF.  A field
# name MUST be composed of printable US-ASCII characters (i.e.,
# characters that have values between 33 and 126, inclusive), except
# colon.  A field body may be composed of any US-ASCII characters,
# except for CR and LF.

# However, a field body may contain CRLF when
# used in header "folding" and  "unfolding" as described in section
# 2.2.3.

sub _read_headers {
    my $head = shift;
    my @head_order;
    my ($curhead, $head_hash) = ("", {});
    for (split /$crlf/, $head) {
        if (s/^\s+// or not /^([^:]+):\s*(.*)/) {
            next if !$curhead; # Well, that sucks.
            # This is a continuation line. We fold it onto the end of
            # the previous header.
            chomp $head_hash->{$curhead}->[-1];
            $head_hash->{$curhead}->[-1] .= $head_hash->{$curhead}->[-1] ? " $_" : $_;
        } else {
            $curhead = $1;
            push @{$head_hash->{$curhead}}, $2;
            push @head_order, $curhead;
        }
    }
    return ($head_hash, \@head_order);
}

=head2 header

Returns a list of the contents of the given header.

If called in scalar context, will return the B<first> header so named.
I'm not sure I like that. Maybe it should always return a list. But it
doesn't.

=cut

sub header {
    my ($self, $field) = @_;
    $field = $self->{header_names}->{lc $field} || return "";
    return wantarray ? @{$self->{head}->{$field}}
                     :   $self->{head}->{$field}->[0];
}

=head2 header_set

    $mail->header_set($field, $line1, $line2, ...);

Sets the header to contain the given data. If you pass multiple lines
in, you get multiple headers, and order is retained.

=cut

sub header_set {
    my ($self, $field, @data) = @_;
    if ($GROUCHY) {
        croak "I am not going to break RFC2822 and neither are you"
            unless $field =~ /^[\x21-\x39\x3b-\x7e]+$/;
        carp "You're a miserable bastard but I'll let you off this time"
            unless $field =~ /^[\w-]+$/;
    }

    if (!exists $self->{header_names}->{lc $field}) {
        $self->{header_names}->{lc $field} = $field;
        # New fields are added to the end.
        push @{$self->{order}}, $field;
    } else {
        $field = $self->{header_names}->{lc $field};
    }

    $self->{head}->{$field} = [ @data ];
    return wantarray ? @data : $data[0];
}

=head2 body

Returns the body text of the mail.

=cut

sub body { return $_[0]->{body}      } # We like this. This is simple.

=head2 body_set

Sets the body text of the mail.

=cut

sub body_set { $_[0]->{body} = $_[1] || '' }

=head2 as_string

Returns the mail as a string, reconstructing the headers. Please note
that header fields are kept in order if they are unique, but, for,
instance, multiple "Received" headers will be grouped together. (This is
in accordance with RFC2822, honest.)

Also, if you've added new headers with C<header_set> that weren't in the
original mail, they'll be added to the end.

=cut

# However, for the purposes of this standard, header
# fields SHOULD NOT be reordered when a message is transported or
# transformed.  More importantly, the trace header fields and resent
# header fields MUST NOT be reordered, and SHOULD be kept in blocks
# prepended to the message.

sub as_string {
    my $self = shift;
    return _headers_as_string($self).$self->{mycrlf}.$self->body;
}

sub _headers_as_string {
    my $self = shift;
    my @order = @{$self->{order}};
    my %head = %{$self->{head}};
    my $stuff = "";
    while (keys %head) {
        my $thing = shift @order;
        next unless exists $head{$thing}; # We have already dealt with it
        $stuff .= $self->_header_as_string($thing, $head{$thing});
        delete $head{$thing};
    }
    return $stuff;
}

sub _header_as_string {
    my ($self, $field, $data) = @_;
    my @stuff = @$data;
    # Ignore "empty" headers
    return '' unless @stuff = grep { defined $_ } @stuff;
    return join "", map { length > 78 ? $self->_fold($_) : "$_$self->{mycrlf}" }
                    map { "$field: $_" } 
                    @stuff;
}

sub _fold {
    my $self = shift;
    my $line = shift;
    # We know it will not contain any new lines at present
    my $folded = "";
    while ($line) {
        $line =~ s/^\s+//;
        if ($line =~ s/^(.{0,77})(\s|\z)//) {
            $folded .= $1.$self->{mycrlf};
            $folded .= " " if $line;
        } else {
            # Basically nothing we can do. :(
            $folded .= $line;
            last;
        }
    }
    return $folded;
}

1;

__END__

=head1 CAVEATS

Email::Simple handles only RFC2822 formatted messages.  This means you
cannot expect it to cope well as the only parser between you and the
outside world, say for example when writing a mail filter for
invocation from a .forward file (for this we recommend you use
L<Email::Filter> anyway).  For more information on this issue please
consult RT issue 2478, http://rt.cpan.org/NoAuth/Bug.html?id=2478 .

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Casey West

Copyright 2003 by Simon Cozens

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

Perl Email Project, http://pep.kwiki.org .

=cut

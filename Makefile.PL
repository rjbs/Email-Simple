use strict;
use ExtUtils::MakeMaker;

use 5.00503;

# This is so stupid!  We need to make sure that Email::MIME, a downstream
# module, is running a version that doesn't screw around with the guts of
# Email::Simple.
my @prereq;
if (eval { require Email::MIME }) {
  unless (eval { Email::MIME->VERSION(1.857) }) {
    warn <<END_ACHTUNG;
### ACHTUNG!  You need to update Email::MIME to a later version, as versions
### before 1.857 meddled in the guts of Email::Simple, which have been changed.
### If you are using an automated installer, this should happen automatically.
###
### This installation will proceed in five seconds.
END_ACHTUNG
    sleep 5;
  }
}

WriteMakefile(
  NAME          => 'Email::Simple',
  VERSION_FROM  => 'lib/Email/Simple.pm',
  (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM     => {
    @prereq,
    'Test::More' => '0.47',
  },
);

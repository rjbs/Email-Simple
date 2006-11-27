use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME          => 'Email::Simple',
  VERSION_FROM  => 'lib/Email/Simple.pm',
  (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM     => {
    'Test::More' => '0.47',
  },
);

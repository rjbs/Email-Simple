use ExtUtils::MakeMaker;

WriteMakefile(
               NAME          => 'Email::Simple',
               VERSION_FROM  => 'lib/Email/Simple.pm',
               PREREQ_PM     => {
                                 'Test::More' => '0.47',
                                },
);

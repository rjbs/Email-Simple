use ExtUtils::MakeMaker;

WriteMakefile(
               NAME          => 'Email::Simple',
               VERSION_FROM  => 'Simple.pm',
               PREREQ_PM     => {
                                 'Test::More' => '0.47',
                                },
);

use strict;
use warnings;
use 5.010;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'Asterisk::ParseConfig',
    AUTHOR            => 'Alexander Ruzhnikov <ruzhnikov85@gmail.com>',
    LICENSE           => 'Artistic License 2.0',
    VERSION_FROM      => 'lib/Asterisk/ParseConfig.pm',
    ABSTRACT_FROM     => 'lib/Asterisk/ParseConfig.pm',
    EXE_FILES         => [qw(bin/asterisk-checksyntax)],
    PREREQ_PM         => {},
);

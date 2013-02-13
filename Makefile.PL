use 5.010;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'Asterisk::ParseConfig',
    VERSION_FROM      => 'lib/Asterisk/ParseConfig.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Asterisk/ParseConfig.pm', # retrieve abstract from module
       AUTHOR         => 'Alexander Ruzhnikov <ruzhnikov85@gmail.com>') : ()),
);

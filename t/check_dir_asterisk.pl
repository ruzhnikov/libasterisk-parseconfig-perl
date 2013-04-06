#!/usr/bin/perl

# скрипт проверки доступности папки asterisk

use strict;
use warnings;

my $astdir = undef;
my $dir = undef;

if (opendir($dir, './asterisk')) {
    $astdir = './asterisk';
} elsif (opendir($dir, './t/asterisk')) {
    $astdir = './t/asterisk';
} else {
    die "can not open asterisk directory";
}
closedir($dir) or die "can not close asterisk directory: $!";

my $extfile = 'extensions.conf';

sub constructor {
    my $astfile = Asterisk::ParseConfig::Extensions->new({  CONFIG_FILENAME     => $extfile,
                                                            ASTERISK_PATH       => $astdir});
    return $astfile;
}
#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 6;

use Asterisk::ParseConfig::Extensions;

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

my $astfile = Asterisk::ParseConfig::Extensions->new({  CONFIG_FILENAME     => $extfile,
                                                        ASTERISK_PATH       => $astdir});

isa_ok($astfile, 'Asterisk::ParseConfig::Extensions');
isa_ok($astfile, 'Asterisk::ParseConfig');
can_ok($astfile, 'new');
can_ok($astfile, 'parse');
can_ok($astfile, '_first_parse_file');
can_ok($astfile, '_first_parse_file_args');
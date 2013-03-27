#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;

require_ok('Asterisk::ParseConfig::Extensions');

# проверяем, есть ли у нас локальная папка с конфиг-файлами для парсинга
my $astdir = undef;
my $dir = undef;

if (opendir($dir, 'asterisk')) {
    $astdir = 'asterisk';
} elsif (opendir($dir, 't/asterisk')) {
    $astdir = 't/asterisk';
} else {
    die "can not open asterisk directory";
}
closedir($dir) or die "can not close asterisk directory: $!";

my $extfile = 'extensions.conf';
my $astfile = Asterisk::ParseConfig::Extensions->new({  CONFIG_FILENAME     => $extfile,
                                                        ASTERISK_PATH       => $astdir});
cmp_ok($astfile->{CONFIG}->{CONFIG_FILENAME}, 'eq', $extfile, 'check the config filename');
cmp_ok($astfile->{CONFIG}->{ASTERISK_PATH}, 'eq', $astdir, 'check the asterisk configs dir');
$astfile->parse();
cmp_ok($astfile->{PARSE}->{CONFIG}->{RECURSIVE}, 'eq', 'true', 'check parameters of the method parse');
# $astfile = undef;
# chdir $cur_dir;
# $astfile = Asterisk::ParseConfig::Extensions->new({     CONFIG_FILENAME     => $extfile,
#                                                         ASTERISK_PATH       => $astdir});
# $astfile->parse({ RECURSIVE => 'false'});
# cmp_ok($astfile->{PARSE}->{CONFIG}->{RECURSIVE}, 'eq', 'false', 'check parameters of the method parse');
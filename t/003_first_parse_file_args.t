#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

use lib './lib';

require_ok('Asterisk::ParseConfig::Extensions');

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

ok(!$astfile->_first_parse_file_args('','exten => 123,n,Answer()',['extensions.conf',10]),
                    'was not passed on the first argument');
my $exten_result = $astfile->_first_parse_file_args('exten','exten => _123.,n,Answer()',['extensions.conf'],10);
cmp_ok($$exten_result{template}, 'eq', '_123.', 'get extension');
cmp_ok($$exten_result{priority}, 'eq', 'n', 'get priority');
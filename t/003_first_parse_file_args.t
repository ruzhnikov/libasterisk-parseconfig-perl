#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 13;

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

ok(!$astfile->_first_parse_file_args('','include => context',['extensions.conf',10]),
                        'was not passed on the first argument');
my $count_warn = @{$astfile->{PARSE}->{warnings}};
cmp_ok($count_warn, '==', 1, "count warnings == 1");
cmp_ok(${$astfile->{PARSE}->{warnings}}[0], 'eq', 'extensions.conf.10: first arg not found',
                        "print first warning message");
$count_warn = undef;
ok($astfile->_first_parse_file_args('#include', '#include file.conf', ['extensions.conf',11]),
                        'line begins with the word #include');
ok($astfile->_first_parse_file_args('include', 'include => context', ['extensions.conf',22]),
                        'line begins with the word include');
ok(!$astfile->_first_parse_file_args('#include', '#include ', ['extensions.conf',12]),
                        'was not passed on the second argument');
$count_warn = @{$astfile->{PARSE}->{warnings}};
cmp_ok($count_warn, '==', 2, "count warnings == 2");
cmp_ok(${$astfile->{PARSE}->{warnings}}[1], 'eq',
                'extensions.conf.12: can not get the name of the included file',
                'print second warning message');
$count_warn = undef;
ok(!$astfile->_first_parse_file_args('include', 'include =>', ['extensions.conf',23]),
                        'was not passed on the second argument');
$count_warn = @{$astfile->{PARSE}->{warnings}};
cmp_ok($count_warn, '==', 3, "count warnings == 3");
cmp_ok(${$astfile->{PARSE}->{warnings}}[2], 'eq',
                'extensions.conf.23: can not get the name of the included context',
                'print third warning message');
ok(!$astfile->_first_parse_file_args('bla-bla', 'bla-bla => 321,1,', ['extensions.conf',24]),
                'the first argument is not defined');
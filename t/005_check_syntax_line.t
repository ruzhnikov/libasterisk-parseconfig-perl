#!/usr/bin/perl

use strict;
use warnings;
use Test::More 'no_plan';

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

$astfile->parse({   RECURSIVE   => 'true' });
ok($astfile->_check_syntax_line('exten', 'exten => 123,1,NoOP(${CHANNEL})',1,'from-internal'),
            'parse a string dial plan');
my $ext_hash = $astfile->_check_syntax_line('exten', 'exten => _XN.,n,Dial(SIP/${EXTEN:1},30,)',4,'from-internal');
cmp_ok($$ext_hash{exten}, 'eq', '_XN.', 'get extension');
cmp_ok($$ext_hash{priority}, 'eq', 'n', 'get priority');
cmp_ok($$ext_hash{app}, 'eq', 'Dial(SIP/${EXTEN:1},30,)', 'get application');
$ext_hash = undef;
$ext_hash = $astfile->_check_syntax_line('exten', 'exten => _XN.,n,Dial(SIP/${EXTEN:1},30,) ; comment',4,'from-internal');
cmp_ok($$ext_hash{app}, 'eq', 'Dial(SIP/${EXTEN:1},30,)', 'get application with comment');
$ext_hash = undef;
$ext_hash = $astfile->_check_syntax_line('exten', 'exten => _XN.,n,Dial(SIP/${EXTEN:1},30,)   ',4,'from-internal');
cmp_ok($$ext_hash{app}, 'eq', 'Dial(SIP/${EXTEN:1},30,)', 'get application with space symbols');
$ext_hash = undef;
ok(!$astfile->_check_syntax_line('', 'exten => _XN.,n,Dial(SIP/${EXTEN:1},30,) ; comment',4,'from-internal'),
            'was not passed on the first argument');
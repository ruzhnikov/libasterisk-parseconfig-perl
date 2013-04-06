#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 8;

require_ok('Asterisk::ParseConfig::Extensions');

eval {
    require 'check_dir_asterisk.pl';
};
if ($@) {
    require 't/check_dir_asterisk.pl';
};

my $astfile = constructor();

$astfile->parse({   RECURSIVE   => 'false' });
ok($astfile->_check_syntax_line('exten', 'exten => 123,1,NoOP(${CHANNEL})',1,'from-internal'),
            'parse a string dial plan');

my $ext_hash = undef;

$ext_hash = $astfile->_check_syntax_line('exten', 'exten => _XN.,n,Dial(SIP/${EXTEN:1},30,)',4,'from-internal');
is($ext_hash->{'exten'}, '_XN.', 'get extension');
is($ext_hash->{'priority'}, 'n', 'get priority');
is($ext_hash->{'app'}, 'Dial(SIP/${EXTEN:1},30,)', 'get application');

$ext_hash = undef;
$ext_hash = $astfile->_check_syntax_line('exten', 'exten => _XN.,n,Dial(SIP/${EXTEN:1},30,) ; comment',4,'from-internal');
is($ext_hash->{'app'}, 'Dial(SIP/${EXTEN:1},30,)', 'get application with comment');

$ext_hash = undef;
$ext_hash = $astfile->_check_syntax_line('exten', 'exten => _XN.,n,Dial(SIP/${EXTEN:1},30,)   ',4,'from-internal');
is($ext_hash->{'app'}, 'Dial(SIP/${EXTEN:1},30,)', 'get application with space symbols');

$ext_hash = undef;
ok(!$astfile->_check_syntax_line('', 'exten => _XN.,n,Dial(SIP/${EXTEN:1},30,) ; comment',4,'from-internal'),
            'was not passed on the first argument');
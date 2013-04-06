#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 9;

require_ok('Asterisk::ParseConfig::Extensions');

eval {
    require 'check_dir_asterisk.pl';
};
if ($@) {
    require 't/check_dir_asterisk.pl';
};
my $astfile = constructor();

isa_ok($astfile, 'Asterisk::ParseConfig::Extensions');
isa_ok($astfile, 'Asterisk::ParseConfig');
can_ok($astfile, 'new');
can_ok($astfile, 'parse');
can_ok($astfile, '_first_parse_file');
can_ok($astfile, '_first_parse_file_args');
can_ok($astfile, '_first_try_read_file');
can_ok($astfile, '_try_read_file');
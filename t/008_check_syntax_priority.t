#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 5;

require_ok('Asterisk::ParseConfig::Extensions');

eval {
    require 'check_dir_asterisk.pl';
};
if ($@) {
    require 't/check_dir_asterisk.pl';
};

my $astfile = constructor();
my $h_priority = undef;

$h_priority = $astfile->_check_syntax_priority('1');
is($h_priority->{priority}, '1');

$h_priority = undef;
$h_priority = $astfile->_check_syntax_priority('n');
is($h_priority->{priority}, 'n');

$h_priority = undef;
$h_priority = $astfile->_check_syntax_priority('n(test)');
is($h_priority->{priority}, 'n');
is($h_priority->{named}, 'test');
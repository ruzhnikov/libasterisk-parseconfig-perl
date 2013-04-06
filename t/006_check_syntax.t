#!/usr/bin/perl

use strict;
use warnings;
use Test::More 'no_plan';

require_ok('Asterisk::ParseConfig::Extensions');

eval {
    require 'check_dir_asterisk.pl';
};
if ($@) {
    require 't/check_dir_asterisk.pl';
};

my $astfile = constructor();

eval {
    $astfile->check_syntax();
};

ok($@);

$astfile->parse({   RECURSIVE   => 'true' });
$astfile->check_syntax();

my $astfile_syntax = $astfile->{'CHECK_SYNTAX'}->{'application1'}->{'exten'}->{'111'};
is($astfile_syntax->{1}, 'Log(VERBOSE, Log file)');

TODO: {
    local $TODO = 'priority \'n\' is not processed';

    is($astfile_syntax->{2}, 'GotoIf($[${CALLERID(num)} == 123]?:hang)');
    is($astfile_syntax->{3}, 'Dial(SIP/${EXTEN},,)');
    is($astfile_syntax->{3}->{'named'}, 'hang');
    is($astfile_syntax->{3}, 'Hangup()');
};
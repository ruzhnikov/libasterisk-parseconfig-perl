#!/usr/bin/perl

use strict;
use warnings;
use Test::More 'no_plan';

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

require_ok('Asterisk::ParseConfig::Extensions');

my $astfile = Asterisk::ParseConfig::Extensions->new({  CONFIG_FILENAME     => $extfile,
                                                        ASTERISK_PATH       => $astdir});

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
};
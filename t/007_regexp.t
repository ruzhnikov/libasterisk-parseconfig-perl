#!/usr/bin/perl

# Тест для проверки некоторых регулярных выражений, используемых
# в работе модуля Asterisk::ParseConfig и всех его происзводных

use strict;
use warnings;
use Test::More tests => 4;

# Asterisk::ParseConfig::Extensions::_check_syntax_line()
{
    my $string = 'exten => _XN.,n,Dial(SIP/${EXTEN:1},30,)';
    my $exten = $string;
    $exten =~ s/exten\s=>\s(.+?)(?=\,).+/$1/;
    is($exten, '_XN.');
    my $priority = $string;
    $priority =~ s/exten\s=>\s.+?,(.+?)(?=\,).+/$1/;
    is($priority, 'n');
    my $app = $string;
    $app =~ s/exten\s=>\s.+?,.+?,(.+)$/$1/;
    is($app, 'Dial(SIP/${EXTEN:1},30,)');
}

# Asterisk::ParseConfig::Extensions::_check_syntax_priority()
{
    my $priority = 'n(test)';
    like($priority, qr/^n(\(.+?\))$/);
}
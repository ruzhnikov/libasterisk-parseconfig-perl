#!/usr/bin/perl

# Тест для проверки некоторых регулярных выражений, используемых
# в работе модуля Asterisk::ParseConfig и всех его происзводных

use strict;
use warnings;
use Test::More tests => 2;

# Asterisk::ParseConfig::Extensions::_check_syntax_line()
{
    my $string = 'exten => _XN.,n,Dial(SIP/${EXTEN:1},30,)';
    my $exten = $string;
    $exten =~ s/exten\s=>\s(.+?)(?=\,).+/$1/;
    is($exten, '_XN.');
    my $priority = $string;
    $priority =~ s/exten\s=>\s.+?,(.+?)(?=\,).+/$1/;
    is($priority, 'n');
}
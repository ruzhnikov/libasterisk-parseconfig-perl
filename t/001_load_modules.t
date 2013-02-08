#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

eval {
    use Asterisk::ParseConfig;
    use Asterisk::ParseConfig::Extensions;
    use Asterisk::ParseConfig::Additional;
    use Asterisk::ParseConfig::Additional qw/parse_line/;
};

cmp_ok($@, 'eq', '', 'loading Asterisk::ParseConfig*');
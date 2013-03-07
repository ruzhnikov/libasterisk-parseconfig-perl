#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;

use_ok('Asterisk::ParseConfig');
use_ok('Asterisk::ParseConfig::Extensions');
use_ok('Asterisk::ParseConfig::Additional');
use_ok('Asterisk::ParseConfig::Additional', qw/parse_line/);
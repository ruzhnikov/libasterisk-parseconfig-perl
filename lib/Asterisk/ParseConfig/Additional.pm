#!/usr/bin/perl

package Asterisk::ParseConfig::Additional;

our $VERSION = '0.01';

use strict;
use warnings;
use Carp qw/carp/;

our @EXPORT_OK = qw(parse_line);
use parent qw(Exporter);

# функция для парсинга строки
sub parse_line {
	my ($line,$needarg,$delimiter) = @_;
	if ($needarg ne 'all' && $needarg !~ /^arg[1-9]+/) {
		carp "requested is invalid argument $needarg";
		return;
	}
	$delimiter = '\s+' unless ($delimiter);	# разделитель по-умолчанию
	chomp($line);
	my %args = ();						# массив с возвращаемыми значениями
	if ($line =~ m/^\s*$/) {		# пустая строка
		if ($needarg eq 'all') {
			$args{arg1} = '';
			return %args;
		} else {
			return '';
		}
	}
	$line =~ s/^\s*(?=\S)//;			# убираем пробелы в начале строки
	$line =~ s/^(.+?);.*$/$1/;			# убираем комментарий из строки
	$line =~ s/^(.*)(?<=\S)\s+$/$1/g;	# убираем пробелы в конце строки
	if (substr($line,0,1) eq ';') {		# строка содержит только комментарии
		if ($needarg eq 'all') {
			$args{arg1} = '';
			return %args;
		} else {
			return '';
		}
	}
	my @line_elements = split(/$delimiter/, $line);
	if ($needarg eq 'all') {
		foreach my $counter (0..$#line_elements) {
			my $argnum = $counter + 1;
			my $key = 'arg' . $argnum;
			$args{$key} = $line_elements[$counter];
			$args{$key} =~ s/^\s+(?=\S)//;
			$args{$key} =~ s/^(.*)(?<=\S)\s+$/$1/g;
		}
		return %args;
	} else {
		my $argnum = $needarg;
		$argnum =~ s/^arg(\d+)$/$1/;
		unless ($argnum) {
			carp "impossible identify the number of the argument $needarg";
			return;
		}
		my $arg = $line_elements[$argnum - 1];
		return unless ($arg);
		$arg =~ s/^\s+(?=\S)//;
		$arg =~ s/^(.*)(?<=\S)\s+$/$1/g;
		return $arg;
	}
	return %args;
}

1;

__END__
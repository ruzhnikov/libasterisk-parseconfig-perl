#!/usr/bin/perl

package Asterisk::ParseConfig::Extensions;

our $VERSION = 0.01;

use strict;
use warnings;
use Carp qw/carp croak/;
use 5.010;

use parent qw(Asterisk::ParseConfig);
use Asterisk::ParseConfig::Additional qw/parse_line/;

sub new {
	my ($class, $options) = @_;

	return $class->SUPER::new($options);
}

# метод для работы со строками при первичном парсинге
sub _first_parse_file {
    my ($self, $file, $filename) = @_;

    # файл уже был распарсен, не будем создавать петли
    if (exists $self->{PARSE}->{FILES}->{$filename}) {
        carp "WARNING: loop detection!";
        return 1;
    }

    # допустимые ключевые слова в контекстах
    my @acceptable_first_sybmols = ('#include', 'include', 'exten', 'same');

    # допустимые ключевые слова в контексте general
    my @acceptable_general = ('#include', 'static', 'writeprotect',
                                'autofallthrough', 'clearglobalvars', 'priorityjumping');
    
    # хеш для хранения информации о файле
    my %file_hash = ();

    # начинаем читать файл
    my $general = 0;    # переменная для обозначения секции general
    my $globals = 0;    # переменная для обозначения секции globals
    my $context = undef;    # имя текущего контекста
    while (my $line = <$file>) {
        chomp($line);

        # пропускаем комментарии и пустые строки
        next if ($line =~ /^\s*\;/ || $line =~ /^\s*$/);

        # читаем строку, получаем первый элемент строки
        my $delimiter = '\s*=>?\s*|\s+';    # разделитель слов в строке
        my $first_arg = parse_line($line,'arg1',$delimiter);
        if ($first_arg =~ m/^\[(.+)\].*$/) {    # имя контекста
        	$context = $1;

            # сохраняем информацию о контексте
            if (!exists $self->{PARSE}->{CONTEXTS}->{$context} ||
                $self->{PARSE}->{CONTEXTS}->{$context}->{exists} eq 'false') {
                    $self->{PARSE}->{CONTEXTS}->{$context}->{exists} = 'true';
            }
            push @{$self->{PARSE}->{FILES}->{$filename}->{contexts}}, $context;
        	$general = 1 if ($context eq 'general');
        	$globals = 1 if ($context eq 'globals');
            $general = 0 if ($context ne 'general');
            $globals = 0 if ($context ne 'globals');
            next;
        }
        if ($general == 1) {    # находимся в секции general
            unless ($first_arg ~~ @acceptable_general) {
            	carp "WARNING: $filename.$.: element $first_arg is not in the list of allowed general context";
            	next;
            }
            if ($first_arg eq '#include') {     # инклуд файла
            	my $include_file = $self->_first_parse_file_args($first_arg, $line, [$filename, $.]);
            	next unless ($include_file);
                push @{$self->{PARSE}->{FILES}->{$filename}->{includes_files}}, $include_file;
                push @{$self->{PARSE}->{CONTEXTS}->{$context}->{includes_files}}, $include_file;
            }
            next;
        }
        if ($globals == 1) {    # находимся в секции globals
            if ($first_arg eq '#include') {
                my $include_file = $self->_first_parse_file_args($first_arg, $line, [$filename, $.]);
                next unless ($include_file);
                push @{$self->{PARSE}->{FILES}->{$filename}->{includes_files}}, $include_file;
                push @{$self->{PARSE}->{CONTEXTS}->{$context}->{includes_files}}, $include_file;
            }
            next;
        }

        # обрабатываем строки в обычном контексте
        unless ($first_arg ~~ @acceptable_first_sybmols) {
            carp "WARNING: $filename.$.: element $first_arg is not in the list of allowed";
            next;
        }
        if ($first_arg eq '#include') {
            my $include_file = $self->_first_parse_file_args($first_arg, $line, [$filename, $.]);
            next unless ($include_file);
            push @{$self->{PARSE}->{FILES}->{$filename}->{includes_files}}, $include_file;
            push @{$self->{PARSE}->{CONTEXTS}->{$context}->{includes_files}}, $include_file;
        } elsif ($first_arg eq 'include') {
            my $include_context = $self->_first_parse_file_args($first_arg, $line, [$filename, $.]);
            next unless ($include_context);
            if (!exists $self->{PARSE}->{CONTEXTS}->{$include_context}->{exists}) {
                $self->{PARSE}->{CONTEXTS}->{$include_context}->{exists} = 'false';
            }
            push @{$self->{PARSE}->{CONTEXTS}->{$include_context}->{included_contexts}}, $context;
            push @{$self->{PARSE}->{CONTEXTS}->{$context}->{includes_contexts}}, $include_context;
        }
    }
    # запускаем рекурсивный поиск при необходимости
    if ($self->{PARSE}->{CONFIG}->{RECURSIVE} eq 'true') {
        if (exists $self->{PARSE}->{FILES}->{$filename}->{includes_files}) {
            my @includes_files = @{$self->{PARSE}->{FILES}->{$filename}->{includes_files}};
            if (@includes_files > 0) {
                foreach my $filename (@includes_files) {
                    my $ast_dir = $self->{CONFIG}->{ASTERISK_PATH};
                    my $ast_config_file = undef;
                    if (substr($filename,1,1) ne '/') { # относительный путь
                        $filename = $ast_dir . '/' . $filename;
                    }
                    eval {
                        open ($ast_config_file, '<', "$filename") or die "$!";
                    };
                    if ($@) {
                        carp "can not read configuration file $filename: $@";
                        next;
                    }
                    push @{$self->{fh}}, $ast_config_file;
                    ($self->_first_parse_file($ast_config_file,$filename));
                }
            }
        }
    }
    return 1;
}

# дополнительный метод для обработки строк при первичном парсинге
sub _first_parse_file_args {
    my ($self, $first_arg, $line, $config) = @_;
    my $filename = $$config[0];
    my $linenum = $$config[1];

    if ($first_arg eq '#include') {
        my $include_file = parse_line($line,'arg2');
        unless ($include_file) {
            carp "WARNING: $filename.$linenum: can not get the name of the included file";
            return;
        }
        eval {
                ($self->_try_read_file($include_file));
        };
        if ($@) {
            warn "ERROR: $filename.$linenum: $@";
            return;
        }
        return $include_file;
    } elsif ($first_arg eq 'include') {
        my $include_context = parse_line($line,'arg2','=>');
        unless ($include_context) {
            carp "WARNING: $filename.$linenum: can not get the name of the included context";
            return;
        }
        return $include_context;
    }
    return;
}

# подчищаем за собой
sub DESTROY {
    my $self = shift;

    # закрываеем все файлы, если таковые имеются
    if (exists $self->{fh}) {
        if (@{$self->{fh}} > 0) {
            foreach my $fh (@{$self->{fh}}) {
                close $fh;
            }
        }
    }
}

1;

__END__
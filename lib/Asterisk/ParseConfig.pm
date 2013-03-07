#!/usr/bin/perl

#######################################################
## Базовый модуль для модулей Asterisk::ParseConifg::*
#######################################################

package Asterisk::ParseConfig;

our $VERSION = '0.011';

use strict;
use warnings;
use Carp qw/carp croak/;

# конструктор класса
sub new {
    my ($class, $values) = @_;
    my $self = bless {}, $class;

    # пытаемся открыть папку с конфигами и прочесть файл, если нет, возвращаем undef
    if($self->_configure($values) && $self->_first_try_read_file($self->{CONFIG}->{CONFIG_FILENAME})) {
        return $self;
    }
    return;
}

# метод для первичного конфигурирования объекта
sub _configure {
    my ($self, $config) = @_;
    
    # список необходимых параметров
    my @required = qw(CONFIG_FILENAME);
    
    # список допустимых опций
    my %config_options = (  CONFIG_FILENAME     => '' ,
                            ASTERISK_PATH       => '/etc/asterisk',);
    
    # читаем полученные данные
    while ( my ($key, $value) = each(%{$config})) {
        my $opt = uc($key);
        if (!exists $config_options{$opt}) {
            carp "unknown parameter $key";
            next;
        } elsif (!defined $value) {
            next;
        }
        $self->{CONFIG}->{$opt} = $value;
    }
    
    # проверяем список необходимых параметров
    foreach my $req (@required) {
        if (!exists $self->{CONFIG}->{$req}) {
            carp "missing parameter $req!";
            return;
        }
    }
    
    # проверяем, все ли параметры были добавлены в переменные экземпляра. Если нет, добавляем
    while (my ($key, $value) = each(%config_options)) {
        if (!exists $self->{CONFIG}->{$key}) {
            $self->{CONFIG}->{$key} = $value;
        }
    }
    
    return 1;
}

# метод для проверки первичного доступа к конфиг-файлу
sub _first_try_read_file {
    my ($self, $config_filename) = @_;
    my $ast_dir = $self->{CONFIG}->{ASTERISK_PATH};
    eval {
        chdir $ast_dir or die "$!";
    };
    if ($@) {
        croak "can not change to directory $ast_dir: $@";
    }
    unless (-e $config_filename) {
        croak "can not find file $config_filename";
    }
    return 1;
}

# метод проверки доступа к конфиг-файлу
sub _try_read_file {
    my ($self, $config_filename) = @_;
    unless (-e $config_filename) {
        croak "can not find file $config_filename";
    }
    return 1;
}

# метод для первичного парсинга файла, построение "карты" файла
sub parse {
    my $self = shift;
    my $variables = shift;
    
    # список допустимых параметров
    my %config_options = (    RECURSIVE   => 'true' );
    
    # читаем полученные данные
    while (my ($key, $value) = each(%{$variables})) {
        my $opt = uc($key);
        if (!exists $config_options{$opt}) {
            carp "unknown parameter $key";
            next;
        } elsif (!defined $value) {
            next;
        }
        $self->{PARSE}->{CONFIG}->{$opt} = $value;
    }
    
    # проверяем, все ли параметры были добавлены в переменные экземпляра. Если нет, добавляем
    while (my ($key, $value) = each(%config_options)) {
        if (!exists $self->{PARSE}->{CONFIG}->{$key}) {
            $self->{PARSE}->{CONFIG}->{$key} = $value;
        }
    }
    
    # начинаем работу
    my $ast_dir = $self->{CONFIG}->{ASTERISK_PATH};
    chdir $ast_dir;
    my $filename = $self->{CONFIG}->{CONFIG_FILENAME};
    my $ast_config_file = undef;
    eval {
        open($ast_config_file, '<', "$filename") or die "$!";
    };
    if ($@) {
        croak "ERROR: can not read configuration file $filename: $@";
    }
    # добавляем дескриптор файла в массив объекта
    push @{$self->{fh}}, $ast_config_file;

    # добавляем переменные для хранения предупреждений, ошибок и уведомлений
    # $self->{PARSE}->{errors}->{'count'} = 0;
    @{$self->{PARSE}->{warnings}} = ();
    # $self->{PARSE}->{notices}->{'count'} = 0;

    # вызываем метод для первичного парсинга файла
    if ($self->_first_parse_file($ast_config_file,$filename)) {
        return 1;
    }
    return;
}

1;

__END__

=head1 NAME

    Asterisk::ParseConfig - Base class for classes Asterisk::PareConfig::*

=head2 SYNOPSIS
    
    use Asterisk::ParseConfig

=head2 DESCRIPTION

    In the class implemented objects constructor and parse() method

=head1 AUTHOR

    Alexander Ruzhnikov (ruzhnikov85@gmail.com)

=head1 COPYRIGHT AND LICENSE

    Copyright (C) 2013 by Alexander Ruzhnikov (ruzhnikov85@gmail.com)

    This module is free software.  You can redistribute it and/or modify it under the terms of the Artistic License 2.0.

    This program is distributed in the hope that it will be useful, but without any warranty; without even the implied 
    warranty of merchantability or fitness for a particular purpose.

=cut
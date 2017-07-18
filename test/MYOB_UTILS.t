#!/usr/bin/perl -w

=head1 NAME

MYOB_UTILS.t

=head1 DESCRIPTION

Test script to test the MYOB_UTILS.pm Module

=head1 AUTHOR

Douglas Young (July 2017)

=cut


use strict;
use warnings;
use lib 'lib';
use MYOB_UTILS;

use Test::More tests => 12;

my $param = '9%';
my @results = &MYOB_UTILS::get_super_rate($param);
&is_deeply(\@results, [1, 0.09], "get_super_rate($param)");

$param = '0%';
@results = &MYOB_UTILS::get_super_rate($param);
&is_deeply(\@results, [1, 0], "get_super_rate($param)");

$param = '99%';
@results = &MYOB_UTILS::get_super_rate($param);
&is_deeply(\@results, [undef, "Super rate '99' is not betweem 0-50"], "get_super_rate($param)");

$param = 'X%';
@results = &MYOB_UTILS::get_super_rate($param);
&is_deeply(\@results, [undef, "Unable to extract rate from '$param'"], "get_super_rate($param)");



$param = '0';
@results = &MYOB_UTILS::calc_income_tax($param);
&is_deeply(\@results, [1, 0], "calc_income_tax($param)");

$param = '18200';
@results = &MYOB_UTILS::calc_income_tax($param);
&is_deeply(\@results, [1, 0], "calc_income_tax($param)");

$param = '37000';
@results = &MYOB_UTILS::calc_income_tax($param);
&is_deeply(\@results, [1, 3572], "calc_income_tax($param)");

$param = '80000';
@results = &MYOB_UTILS::calc_income_tax($param);
&is_deeply(\@results, [1, 17547], "calc_income_tax($param)");

$param = '180000';
@results = &MYOB_UTILS::calc_income_tax($param);
&is_deeply(\@results, [1, 54547], "calc_income_tax($param)");

$param = '200000';
@results = &MYOB_UTILS::calc_income_tax($param);
&is_deeply(\@results, [1, 63547], "calc_income_tax($param)");

$param = '-1000';
@results = &MYOB_UTILS::calc_income_tax($param);
&is_deeply(\@results, [undef, "Invalid annual salary provided - '$param'"], "calc_income_tax($param)");

$param = 'not a salary';
@results = &MYOB_UTILS::calc_income_tax($param);
&is_deeply(\@results, [undef, "Invalid annual salary provided - '$param'"], "calc_income_tax($param)");


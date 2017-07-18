#!/usr/bin/perl -w

=head1 NAME

EMPLOYEE.t

=head1 DESCRIPTION

Test script to test the EMPLOYEE.pm class module

=head1 AUTHOR

Douglas Young (July 2017)

=cut

use strict;
use warnings;

use lib 'lib';
use EMPLOYEE;
use Error qw(:try);
use Test::More tests => 16;


my $args = {
    'first_name' => 'David',
    'last_name' => 'Rudd',
    'annual_salary' => 60050,
    'super_rate' => 0.09,
    'payment_period' => '01 March - 31 March'
};

my $employee = EMPLOYEE->new($args);


&is($employee->get_first_name(), 'David', 'get_first_name');
&is($employee->get_last_name(), 'Rudd', 'get_last_name');
&is($employee->get_annual_salary(), '60050', 'get_annual_salary');
&is($employee->get_super_rate(), '0.09', 'get_super_rate');
&is($employee->get_payment_period(), '01 March - 31 March', 'get_payment_period');
&is($employee->get_annual_income_tax(), '11063', 'get_annual_income_tax');
&is($employee->get_gross_monthly_income(), '5004', 'get_gross_monthly_income');
&is($employee->get_monthly_income_tax(), '922', 'get_monthly_income_tax');
&is($employee->get_net_monthly_income(), '4082', 'get_net_monthly_income');
&is($employee->get_super_monthly(), '450', 'get_super_monthly');
&is(ref($employee->get_monthly_payslip()), 'ARRAY', 'get_monthly_payslip');
&diag('get_monthly_payslip returns array of data as below');
&diag(&explain($employee->get_monthly_payslip()));


&diag("now testing the 'set' methods by calling them and then testing the values with their corresponding 'get' methods");
$args = {
    'first_name' => 'John',
    'last_name' => 'Smith',
    'annual_salary' => 100000,
    'super_rate' => 0.1,
    'payment_period' => '01 April - 30 April'
};

$employee->set_first_name($args);
&is($employee->get_first_name(), 'John', "set_first_name");

$employee->set_last_name($args);
&is($employee->get_last_name(), 'Smith', "set_last_name");

$employee->set_annual_salary($args);
&is($employee->get_annual_salary(), 100000, "set_annual_salary");

$employee->set_super_rate($args);
&is($employee->get_super_rate(), 0.1, "set_super_rate");

$employee->set_payment_period($args);
&is($employee->get_payment_period(), '01 April - 30 April', "set_payment_period");


#exception tests

&diag("now testing edge cases");
$args = {
    'first_name' => 'John',
    'last_name' => 'Smith',
    'annual_salary' => 'XXXXXX',
    'super_rate' => 0.8,
    'payment_period' => '01 April - 30 April'
};

try {
    $employee->set_annual_salary($args);
}
catch Error with {
    my $ex = shift;
    my $result = ($ex =~ /annual_salary provided is invalid/);
    &is($result, 1, "set_annual_salary('XXXXXX')");
};

try {
    $employee->set_super_rate($args);
}
catch Error with {
    my $ex = shift;
    my $result = ($ex =~ /Super rate.*is not betweem 0 and 0\.5/);
    &is($result, 1, "set_super_rate(0.8)");
};



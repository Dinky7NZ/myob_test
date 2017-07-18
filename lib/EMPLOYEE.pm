#!/usr/bin/perl -w

=head1 NAME

EMPLOYEE.pm

=head1 SYNOPSIS

use EMPLOYEE;

my $employee = &EMPLOYEE->new($args);

print $employee->get_annual_income_tax();

=head1 DESCRIPTION

Employee Class
Capture details about employee and has method to do payslip calculations

=head1 AUTHOR

Douglas Young (July 2017)

=head1 METHODS

=cut


package EMPLOYEE;

use strict;
use warnings;
use lib 'lib';
use MYOB_UTILS;
use Math::Round;

=head2 new

    Constructor
    Takes a hash ref of initial values to setup object with these
    attributes:
    first_name, last_name, annual_salary, super_rate, payment_period

=cut
sub new {
    my ($class, $args) = @_;

    my $self = {};
    bless ($self, $class);

    #die and throw an exception if the annual salary is not valid.
    unless ($args->{'annual_salary'} =~ /^\s*\d+\s*$/) {
        die "annual_salary provided is invalid - '" . $args->{'annual_salary'} . "'";
    }

    $self->{'first_name'} = $args->{'first_name'} || '';
    $self->{'last_name'} = $args->{'last_name'} || '';
    $self->{'annual_salary'} = $args->{'annual_salary'} || 0;
    $self->{'super_rate'} = $args->{'super_rate'} || 0;
    $self->{'payment_period'} = $args->{'payment_period'} || '';

    return $self;
}


=head2 set_first_name

    Method to set the attribute 'first_name' 

=cut
sub set_first_name {
    my ($self, $args) = @_;

    $self->{'first_name'} = $args->{'first_name'};

    return;
}


=head2 get_first_name

    Method to get the attribute 'first_name'

=cut
sub get_first_name {
    my ($self) = @_;

    return $self->{'first_name'};
}


=head2 set_last_name

    Method to set the attribute 'last_name'

=cut
sub set_last_name {
    my ($self, $args) = @_;

    $self->{'last_name'} = $args->{'last_name'};

    return;
}


=head2 get_last_name

    Method to get the attribute 'last_name'

=cut
sub get_last_name {
    my ($self) = @_;

    return $self->{'last_name'};
}


=head2 set_annual_salary

    Method to set the attribute 'annual_salary'

=cut
sub set_annual_salary {
    my ($self, $args) = @_;

    #die and throw an exception if the annual salary is not valid.
    unless ($args->{'annual_salary'} =~ /^\s*\d+\s*$/) {
        die "annual_salary provided is invalid - '" . $args->{'annual_salary'} . "'";
    }

    $self->{'annual_salary'} = $args->{'annual_salary'};

    return;
}


=head2 get_annual_salary

    Method to get the attribute 'annual_salary'

=cut
sub get_annual_salary {
    my ($self) = @_;

    return $self->{'annual_salary'};
}


=head2 set_super_rate

    Method to set the attribute 'super_rate'

=cut
sub set_super_rate {
    my ($self, $args) = @_;

    die "invalid rate" unless (defined $args->{'super_rate'});

    #test instructions state the rate is to be between 0-50%
    #the rate should be passed in as a floating point value so
    #it can be used in calculations direct
    if ($args->{'super_rate'} < 0 || $args->{'super_rate'} > 0.5) {
        die "Super rate '" . $args->{'super_rate'} . "' is not betweem 0 and 0.5 (0% - 50%)";
    }

    $self->{'super_rate'} = $args->{'super_rate'};

    return;
}


=head2 get_super_rate

    Method to get the attribute 'super_rate'

=cut
sub get_super_rate {
    my ($self) = @_;

    return $self->{'super_rate'};
}


=head2 set_payment_period

    Method to set the attribute 'payment_period'

=cut
sub set_payment_period {
    my ($self, $args) = @_;

    $self->{'payment_period'} = $args->{'payment_period'};

    return;
}


=head2 get_payment_period

    Method to get the attribute 'payment_period'

=cut
sub get_payment_period {
    my ($self) = @_;

    return $self->{'payment_period'};
}


#DESIGN NOTE: Could make annual income (and the other values being returned in this class)
#    an object variable in this class and just return that.
#    To do that, whenever the annual income is updated it will have to
#    calculate and update the anuall income tax value
#    otherwise the value will get stale and invalid.


=head2 get_annual_income_tax

    Method to get the employee's annual income tax.
    Result is rounded to nearest dollar.

=cut
sub get_annual_income_tax{
    my ($self) = @_;

    my ($ret, $annual_income_tax) = &MYOB_UTILS::calc_income_tax($self->get_annual_salary());
    unless ($ret) {
        die "Error calculating income tax - $annual_income_tax\n";
    }

    return $annual_income_tax;
}


=head2 get_gross_monthly_income

    Method to get the employee's gross monthly income.
    Result is rounded to nearest dollar.

=cut
sub get_gross_monthly_income {
    my ($self) = @_;

    return &round($self->get_annual_salary/12);
}


=head2 get_monthly_income_tax

    Method to get the employee's monthly income tax.
    Result is rounded to nearest dollar.

=cut
sub get_monthly_income_tax {
    my ($self) = @_;

    return &round($self->get_annual_income_tax()/12);
}


=head2 get_net_monthly_income

    Method to get the employee's net monthly income

=cut
sub get_net_monthly_income {
    my ($self) = @_;

    return ($self->get_gross_monthly_income() - $self->get_monthly_income_tax());
}


=head2 get_super_monthly

    Method to get the employee's monthly superannuation amount based on their
    annual income and super rate.
    Result is rounded to nearest dollar.

=cut
sub get_super_monthly {
    my ($self) = @_;

    return &round($self->get_gross_monthly_income() * $self->get_super_rate());
}


=head2 get_monthly_payslip

    Method to get the output of their monthly payslip.
    Returns an array of their name, pay period, gross monthly income,
    monthly income tax, net monthly income, and monthly super amount

=cut
sub get_monthly_payslip {
    my ($self) = @_;


    return [$self->get_first_name() . ' ' . $self->get_last_name(), $self->get_payment_period(),
            $self->get_gross_monthly_income(),$self->get_monthly_income_tax(),
            $self->get_net_monthly_income,$self->get_super_monthly];
}


1;

#!/usr/bin/perl -w

=head1 NAME

MYOB_UTILS.pm

=head1 SYNOPSIS

use MYOB_UTILS;
my ($success, $result) = &MYOB_UTILS::calc_income_tax(100000);
if ($success) {print $result;}

=head1 DESCRIPTION

Utility Module with helpful functions

=head1 AUTHOR

Douglas Young (July 2017)

=head1 METHODS

=cut


package MYOB_UTILS;

use strict;
use warnings;
use Math::Round;


=head2 get_super_rate

    Given string with number(percent) with percent sign e.g. '9%', return the percentage as a number '0.09'

    Valid percent range is between 0-50

    Input
        (string)

    Output
        (undef, <error>) on error
        (1, <super rate>) on success

=cut
sub get_super_rate {
    my $rate_string = shift || return (undef, "No super rate provided");
    my $rate;

    #handle leading and trailing spaces to be more forgiving.
    $rate_string =~ /\s*(\d+)\%\s*/;
    $rate = $1;

    unless (defined($rate) && $rate =~ /\d+/) {
        return (undef, "Unable to extract rate from '$rate_string'");
    }

    #test instructions state the rate is to be between 0-50% so check that here.
    if ($rate < 0 || $rate > 50) {
        return (undef, "Super rate '$rate' is not betweem 0-50");
    }

    #convert '9 percent' to '0.09' to use usable in calculations
    return (1, $rate/100);
}


=head2 calc_income_tax

    given an annual salary, calculate the annual income tax

    input
        (number)

    Output
        (undef, <error>) on error
        (1, <income tax>) on success

=cut
sub calc_income_tax {
    my $annual_salary = shift;

    unless (defined $annual_salary && $annual_salary =~ /^\d+$/ && $annual_salary >= 0) {
        return (undef, "Invalid annual salary provided - '$annual_salary'");
    }
    my $income_tax = 0;

    #using <= in an increasing value means I don't have to check 'if salary between X and Y'. more efficient
    if ($annual_salary <= 18200) {
        #this handles situations where annual salary is less than 0, it'll return 0 income tax in that case.
        #the data has been validated before this so shouldn't get salary < 0
        $income_tax = 0;
    }
    elsif ($annual_salary <= 37000) {
        $income_tax = (($annual_salary - 18200) * 0.19);
    }
    elsif ($annual_salary <= 80000) {
        $income_tax = 3572 + (($annual_salary - 37000) * 0.325);
    }
    elsif ($annual_salary <= 180000) {
        $income_tax = 17547 + (($annual_salary - 80000) * 0.37);
    }
    elsif ($annual_salary > 180000) {
        $income_tax = 54547 + (($annual_salary - 180000) * 0.45);
    }

    return (1, &round($income_tax));
}


1;

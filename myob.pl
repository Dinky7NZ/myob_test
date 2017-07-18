#!/usr/bin/perl

=head1 NAME

myob.pl

=head1 SYNOPSIS

Usage: ./myob.pl -f <INPUT FILE NAME> [-o <OUTPUT FILE NAME>] [-d DEBUG]

=head1 DESCRIPTION

Script to load a file of employee data and process their monthly payslips.
Result is output to a csv file.
Default output filename is myob_output.csv unless one is provided using -o option

=head1 AUTHOR

Douglas Young (July 2017)

=cut

use strict;
use warnings;
use lib 'lib';
use Data::Dumper; 
use Text::CSV;
use Getopt::Long qw(GetOptions);
use MYOB_UTILS;
use EMPLOYEE;
use Error qw{:try};

my $DEBUG = 0;
my $input_file;
my $output_file;

&GetOptions(
    'debug|d' => \$DEBUG,
    'file|f=s' => \$input_file,
    'output|o=s' => \$output_file
) or die "Usage: $0 -f <INPUT FILE NAME> [-o <OUTPUT FILE NAME>] [-d]\n";


print "myob test\n\n" if $DEBUG;

#$input_file |= 'myob_input.csv'; #set a default if desired and don't make input file name mandatory
$input_file or die "No input file given. Usage: $0 -f <INPUT FILE NAME> [-o <OUTPUT FILE NAME>] [-d]\n";

print "input_file = '$input_file'\n\n" if $DEBUG;

my $csv = Text::CSV->new ({
  auto_diag => 1,
  sep_char  => ','    # not really needed as this is the default but lets make it explicit
});


#Read in input file and store the data
my $data_records_ref;

my $count = 1;
open(my $data, '<:encoding(utf8)', $input_file) or die "Could not open '$input_file' - $!\n";
while (my $fields = $csv->getline( $data )) {

    #translate super rate from string '9%' to floating point number '0.09'
    my ($ret, $super_rate) = &MYOB_UTILS::get_super_rate($fields->[3]);
    unless ($ret) {
        warn "Error getting super rate for '$fields->[3]' - $super_rate\n";
        #default to 0% rate if errors to allow script to continue and not cause wierd behaviour
        $super_rate = 0;
    }

    push @$data_records_ref, {
        'first_name' => $fields->[0],
        'last_name' => $fields->[1],
        'annual_salary' => $fields->[2],
        'super_rate' => $super_rate,
        'payment_period' => $fields->[4]
    };

    $count++;
}
if (not $csv->eof) {
  $csv->error_diag();
}
close $data;

print "$count records read\n" if $DEBUG;
print &Dumper($data_records_ref) if $DEBUG;


#array to capture each payslip data line to be written to file.
my @rows;

#process the data
foreach my $record (@$data_records_ref) {

    try {
        my $employee = EMPLOYEE->new($record);

        if ($DEBUG) {
            print "get_first_name - " . $employee->get_first_name() . "\n";
            print "get_last_name - " . $employee->get_last_name() . "\n";
            print "get_annual_salary - " . $employee->get_annual_salary() . "\n";
            print "get_super_rate - " . $employee->get_super_rate() . "\n";
            print "get_payment_period - " . $employee->get_payment_period() . "\n";
            print "get_annual_income_tax - " . $employee->get_annual_income_tax() . "\n";
            print "get_gross_monthly_income - " . $employee->get_gross_monthly_income() . "\n";
            print "get_monthly_income_tax - " . $employee->get_monthly_income_tax() . "\n";
            print "get_net_monthly_income - " . $employee->get_net_monthly_income() . "\n";
            print "get_super_monthly - " . $employee->get_super_monthly() . "\n";
            print "get_monthly_payslip - " . &Dumper($employee->get_monthly_payslip()) . "\n";
        }

        #Push the payslip output into array
        push @rows, $employee->get_monthly_payslip();
    }
    catch Error with {
        my $ex = shift;
        chomp $ex;
        print "Caught exception '$ex'\n";
    };


}

#setup csv object for writing
my $csv_out = Text::CSV->new ({
  auto_diag => 1,
  eol       => $/,    # set eol char for csv file
  sep_char  => ','    # not really needed as this is the default but lets make it explicit
});

#open output file.
$output_file ||= 'myob_output.csv';
print "output_file = '$output_file'\n" if $DEBUG;

#write to file
open (my $output_fh, '>:encoding(utf8)', $output_file) or die "Unable to open file '$output_file' for writing - $!\n";
$csv_out->print ($output_fh, $_) for @rows;
close $output_fh;


print "Finished.\n" if ($DEBUG);


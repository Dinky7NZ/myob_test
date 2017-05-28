#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper; 
use Text::CSV;
use Getopt::Long qw(GetOptions);
use Math::Round qw(round);

my $DEBUG = 0;
my $input_file;
my $output_file;

&GetOptions(
    'debug|d' => \$DEBUG,
    'file|f=s' => \$input_file,
    'output|o=s' => \$output_file
) or die "Usage: $0 -f <INPUT FILE NAME> [-o <OUTPUT FILE NAME>] [-d]\n";


#print "DEBUG = $DEBUG\n\n";
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

    #check if salary is valid. checks for digits only but allows for leading and trailing spaces
    unless ($fields->[2] =~ /^\s*\d+\s*$/) {
        #the test script says salary should be positive integer
        #without asking for more info I can simply print a warning. else could stop the script here.

        #output warning and let script continue for other records.
        warn "Salary is not valid '$fields->[2]' at line $count of input file\n";

        #I've decided to default to 0 and let script continue.
        #also the rest of the script may have wierd behaviour if I left the value be invalid.
        $fields->[2] = 0;
    }

    #translate super rate from string '9%' to floating point number '0.09'
    my ($ret, $super_rate) = &get_super_rate($fields->[3]);
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
        'payment_start_date' => $fields->[4]
    };

    $count++;
}
if (not $csv->eof) {
  $csv->error_diag();
}
close $data;

print &Dumper($data_records_ref) if $DEBUG;


my @rows;

#process the data
foreach my $record (@$data_records_ref) {
    my ($ret, $gross_income_monthly, $income_tax_monthly, $net_income_monthly, $super_amount_monthly);
    my ($super_rate, $annual_income_tax);

    ($ret, $annual_income_tax) = &calc_income_tax($$record{'annual_salary'});
    unless ($ret) {
        warn "Error calculating income tax for '$$record{'annual_salary'}' - $annual_income_tax\n";
        next;
    }

    #do rounding when getting the final value, else will loose decimal accuracy if
    #  value gets used in lots of calculations before here.
    $gross_income_monthly = &round($$record{'annual_salary'}/12);
    $income_tax_monthly = &round($annual_income_tax/12);
    $net_income_monthly = $gross_income_monthly - $income_tax_monthly; #don't need to round this as its integer values only
    $super_amount_monthly = &round($gross_income_monthly * $$record{'super_rate'});

    #put reach record in an arrary for writing to file.
    push @rows, ["$$record{'first_name'} $$record{'last_name'}",$$record{'payment_start_date'},
                 $gross_income_monthly,$income_tax_monthly,$net_income_monthly,$super_amount_monthly];

    if ($DEBUG) {
        print "$$record{'first_name'} $$record{'last_name'},$$record{'payment_start_date'}," .
              "$gross_income_monthly,$income_tax_monthly,$net_income_monthly,$super_amount_monthly\n";
    }
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

open (my $output_fh, '>:encoding(utf8)', $output_file) or die "Unable to open file '$output_file' for writing - $!\n";
$csv_out->print ($output_fh, $_) for @rows;
close $output_fh;


#given a salary, calculate the income tax
sub calc_income_tax {
    my $annual_salary = shift;

    unless (defined $annual_salary && $annual_salary >= 0 && $annual_salary =~ /^\d+$/) {
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

    return (1, $income_tax);
}

#given string with number(percent) with percent sign e.g. '9%', return the percentage as a number '0.09'
#putting this in a function to make it modular.
# - allows for changes i.e. the rate limit of 0-50 might change. the format my change
sub get_super_rate {
    my $rate_string = shift || return (undef, "No super rate provided");
    my $rate;

    #handle leading and trailing spaces to be more forgiving.
    $rate_string =~ /\s*(\d+)\%\s*/;
    $rate = $1;

    unless (defined $rate) {
        return (0, "Unable to extract rate from '$rate_string'");
    }

    #test instructions state the rate is to be between 0-50% so check that here.
    #just output warning as don't have instructions on how to treat this. could set a default like the annual salary.
    if ($rate < 0 || $rate > 50) {
        return (0, "Super rate is not betweem 0-50% '$rate'");
    }

    #convert '9' percent to 0.09
    return (1, $rate/100);
}




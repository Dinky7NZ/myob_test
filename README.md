# Setup instructions

Copy the scripts myob.pl and Test input file (myob_input.csv) to same directory on machine with perl installed.
Copy all files in the lib/ and test/ directories to the same location where the myob.pl script is located.

```
./myob.pl
./myob_input.csv
./lib/EMPLOYEE.pm
./lib/MYOB_UTILS.pm
./test/EMPLOYEE.t
./test/MYOB_UTILS.t
```

# Execution instructions

```
Usage: ./myob.pl -f <INPUT FILE NAME> [-o <OUTPUT FILE NAME>] [-d]
e.g.
./myob.pl -f myob_input.csv -o myob_output.csv -d
```

output file name is not mandatory, defaults to 'myob_output.csv' if not provided.

Example output file:
```
"David Rudd","01 March - 31 March",5004,922,4082,450
"Ryan Chen","01 March - 31 March",10000,2696,7304,1000
```


# Unit tests

To run unit tests execture the test files like a normal perl file

e.g. 
```
$ perl test/EMPLOYEE.t
1..18
ok 1 - get_first_name
ok 2 - get_last_name
ok 3 - get_annual_salary
ok 4 - get_super_rate
ok 5 - get_payment_period
ok 6 - get_annual_income_tax
ok 7 - get_gross_monthly_income
ok 8 - get_monthly_income_tax
ok 9 - get_net_monthly_income
ok 10 - get_super_monthly
ok 11 - get_monthly_payslip
# get_monthly_payslip returns array of data as below
# [
#   'David Rudd',
#   '01 March - 31 March',
#   '5004',
#   '922',
#   4082,
#   '450'
# ]
# now testing the 'set' methods by calling them and then testing the values with their corresponding 'get' methods
ok 12 - set_first_name
ok 13 - set_last_name
ok 14 - set_annual_salary
ok 15 - set_super_rate
ok 16 - set_payment_period
# now testing edge cases
ok 17 - set_annual_salary('XXXXXX')
ok 18 - set_super_rate(0.8)
```

For a summarize test report use the 'prove' command (should come with standard distribution of perl:
```
$ prove test/EMPLOYEE.t
test/EMPLOYEE....ok 1/18# get_monthly_payslip returns array of data as below
# [
#   'David Rudd',
#   '01 March - 31 March',
#   '5004',
#   '922',
#   4082,
#   '450'
# ]
# now testing the 'set' methods by calling them and then testing the values with their corresponding 'get' methods
# now testing edge cases
test/EMPLOYEE....ok
All tests successful.
Files=1, Tests=18,  0 wallclock secs ( 0.04 cusr +  0.01 csys =  0.05 CPU)
```



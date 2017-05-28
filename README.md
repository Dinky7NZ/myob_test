=========================
MOYB Test

Total time taken
2hours to do functional script
2hours to do other requirements and validation
1.5hours to do detailed testing and debugging.

----------------------
Execution instructions
----------------------
copy main script myob.pl and input file to same directory on box with perl installed.

Usage: ./myob.pl -f <INPUT FILE NAME> [-o <OUTPUT FILE NAME>] [-d]
e.g.
./myob.pl -f myob_input.csv -o myob_output.csv -d

output file name is not mandatory, defaults to 'myob_output.csv' if not provided.
=========================

=========================
Start 9:30pm Sat 27/05/2017
========
Problem/Requirements
--------
Given a CSV file with records containing empoyee salary details, calculate some payment details such as gross income, tax, super.
Do rounding of the values.
A table of tax values with tax amounts based on salary brackets is to be used.
Write results to an output file.

=======================================
Solution Design & Design Considerations
---------------------------------------
Read the input file and grab data for each record.
Store the data in memory
 - the data is not huge and the number of records the largest companies will be insignificant to cause memory issues.
 - this will achieve a faster processing time
 - this also allows the input file to be closed quickly to advoid problems from keeping a file open for too long
 
Create a function for calculating the tax for a given salary
 - This kind of data can change so making a libary function would make it modular and easy to update
 - This kind of calculation is be used in multiple places or by other scripts so better make it re-useable (for demonstrating design principles for this test)
Eh, while we're at it we can also make functions for the other calculations

have a loop to do the calculations 

write to output file.

11:30pm
##functional script complete##

=========================
Sunday 11:30am 28/05/2017
-------------------------
details requirements
- rounding to nearest dollar
- validations: super rate is 0-50% inclusive, salary is positive integer
- error output method and approach
 - for this test I've made the script forgiving on input errors.
   - this is a test and better to run thorugh entire logic and see the outcomes
   - enables the run to go thorugh entire input and see all the errors instead of stopping at each one.

used Math::Round module to do rounding. printf uses round to even so won't work here.

wrote to csv using module instead of print string
Use a robust CSV reader even if its simple test as real life data can be complex i.e. have comma's in fields.

I have created a test file to test common data exceptions (incorrect format, missing values, out of range)
The code also handles these common exceptions often by defaulting values where suitable or output debugging logs for debugging after running the script  
Ideally automated unit test cases will be written for testing for the functions but for this test the test file data demonstrates the type of test cases done.

Assumptions
 - the payment date is just text. its not being used for any logic processing in this test. 
   - the working example simply divids by 12 so assumption is payment period will always be in months.
   - it is possible to extract the payment period and do calculations with the dates in a real life scenario.
   

finish 1:30pm
(2:30 with 1h break)
-----------------------------

4:30pm - 6pm 
Detailed testing.
Adding documentation.
Made some adjustments to the error handling and fixed a bug.
Final touches.

Do perl critic

=================================

upload to GitHub


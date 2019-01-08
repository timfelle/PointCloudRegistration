# Testing
All tests are defined in shell scripts and can be called in an organised matter
through the scripts in this folder. 

## Run Test
\> runtest.sh TESTNAME1 [TESTNAME2 ...]
The script runtest.sh can be used to run the tests locally. The test scripts are
located in the shell folder. Running the tests with this function will create 
temporary folders and export the figures and such to a figure folder when 
complete. All tests are performed in parallel processes and the output and 
errors will be located in the log folder for the test.

## Submit Test
\> submit.sh TESTNAME1 [TESTNAME2 ...]
This function will sort the files nescesary for testing into logfolders and 
submit the tests onto the LSF based system on the DTU HPC cluster. The defined 
tests are located in the folder called submit.
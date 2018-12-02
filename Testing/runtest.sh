#!/bin/sh
# runtest.sh TESTNAME [TESTNAME ...]
#
# This script works as a function which run tests for the executables
# implementated in the PointCloudRegistration folder of the project.
# 
# The <TESTNAME> variable refers to the filename of the TESTNAME.sh files
# located in the folder shell. These TESTNAME.sh files contain the 
# definition of the test which should be run.

# Submit function
submit(){
	
	if [ ! -s error.err ]; then
	 	echo "No error"
	else
		echo "We have error"
	fi
}

# Help commands
if  [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
	echo "runtest.sh TESTNAME [TESTNAME ...]"
	echo "This function run tests for the executables implemented in the"
	echo "PointCloudRegistration folder of the project."
	echo ""
	echo "The <TESTNAME> variable refers to the filename of the TESTNAME.sh"
	echo "files located in the folder shell. These TESTNAME.sh files contain "
	echo "the definition of the test which should be run."
	exit
fi


# Define all needed folders relative to the Testing folder.
EPATH=../PointCloudRegistration
DPATH=data
FPATH=figures
LPATH=logs
SPATH=shell

# Check for test specifications
if [ -z "$1" ] ; then
	>&2 echo "================================================================="
	>&2 echo "| ERROR in runtest.sh: (No test)                                |"
	>&2 echo "|    Please specify which test to run.                          |"
	>&2 echo "|    Jobs are specified by the filename only.                   |"
	>&2 echo "|    Possible files can be seen in \"$SPATH\":                  |"
	>&2 echo "|                                                               |"
	>&2 ls $SPATH
	>&2 echo "================================================================="
	exit
else
	TEST="$@"
fi

# Make sure the excecutables exists
cd $EPATH;
if [ ! -f GenerateData.exe ] ; then
	>&2 echo "================================================================="
	>&2 echo "| ERROR in runtest.sh: (Missing executable)                     |"
	>&2 echo "|    GenerateData.exe not found. Aborting tests.                |"
	>&2 echo "|    Please attempt a manual compilation.                       |"
	>&2 echo "================================================================="
	exit
fi
if [ ! -f Registration.exe ] ; then
	>&2 echo "================================================================="
	>&2 echo "| ERROR in runtest.sh: (Missing executable)                     |"
	>&2 echo "|    Registration.exe not found. Aborting tests.                |"
	>&2 echo "|    Please attempt a manual compilation.                       |"
	>&2 echo "================================================================="
	exit
fi
cd ../Testing

# Define files needed by the execution in all tests
EXEC="$EPATH/Registration.exe $EPATH/GenerateData.exe"

# Create all needed folders
mkdir -p $DPATH $FPATH $LPATH

# Run the tests
set -e
echo " "
echo "------------------------------------------------------------------"
echo "Queueing tests: "; echo " "
for test in $TEST
do
	echo "  $test."
	if [ -f "$SPATH/$test.sh" ] ; then
		# Create the folder needed
		rm -fr $LPATH/$test
		mkdir -p $LPATH/$test

		# Copy all files needed
		cp -t $LPATH/$test -f $SPATH/$test.sh $EXEC

		# Move to the directory submit the code and return
		cd $LPATH/$test
		./$test.sh >output.out 2>error.err &
		cd ../../
	else
		>&2 echo "File $SPATH/$test.sh was not found"
	fi
done
# you catch errors with this if
echo " "
echo "------------------------------------------------------------------"
echo "Tests queued."
wait
echo "Tests finished:"
for test in $TEST
do
	if [ -f "$SPATH/$test.sh" ] ; then
		# Move to the directory 
		cd $LPATH/$test
		if [ -s error.err ] ; then
			echo "Error: \"$test\" not completed."
			echo "       See error file for details."
			echo "       $LPATH/$test/error.err"
		else
			echo "  $test completed."
		fi
		cd ../../
	fi
	
done
cp -frt ../../Latex/Figures $FPATH/*

# # EOF # #

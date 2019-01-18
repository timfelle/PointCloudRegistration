#!/bin/sh
# submit.sh TESTNAME [TESTNAME ...]
#
# This script works as a function which run tests for the executables
# implementated in the PointCloudRegistration folder of the project.
# 
# The <TESTNAME> variable refers to the filename of the TESTNAME.sh files
# located in the folder shell. These TESTNAME.sh files contain the 
# definition of the test which should be run.

# Help commands
if  [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
	echo "submit.sh TESTNAME [TESTNAME ...]"
	echo "This function run tests for the executables implemented in the"
	echo "PointCloudRegistration folder of the project."
	echo " "
	echo "The <TESTNAME> variable refers to the filename of the TESTNAME.sh"
	echo "files located in the folder submit. These TESTNAME.sh files contain "
	echo "the definition of the test which should be run."
	exit
fi

# Find all tests if specified
if [ "$1" = "all" ] ; then
	for test in `ls submit/*`;
	do 
		t_name=`basename -- "$test"`
		tests+="${t_name%.*} "
	done
	./submit.sh $tests
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
	>&2 echo "| ERROR in submit.sh: (No test)                                 |"
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
if [ ! -f GenerateData.exe ] || [ ! -f Registration.exe ] ; then
	make -s;
fi
if [ ! -f GenerateData.exe ] ; then
	>&2 echo "================================================================="
	>&2 echo "| ERROR in submit.sh: (Missing executable)                      |"
	>&2 echo "|    GenerateData.exe not found. Aborting tests.                |"
	>&2 echo "|    Please attempt a manual compilation.                       |"
	>&2 echo "================================================================="
	exit
fi
if [ ! -f Registration.exe ] ; then
	>&2 echo "================================================================="
	>&2 echo "| ERROR in submit.sh: (Missing executable)                      |"
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
echo " "
echo "------------------------------------------------------------------"
echo "Queueing tests: "; echo " "
for test in $TEST
do
	echo "$test."
	if [ ! -f "$SPATH/$test.sh" ] || [ ! -f "submit/$test.sh" ] ; then
		if [ ! -f "$SPATH/$test.sh" ] ; then
			>&2 echo "  $SPATH/$test.sh: Test not found."
		fi 
		if [ ! -f "submit/$test.sh" ] ; then
			>&2 echo "  submit/$test.sh: Settings not found."
		fi
	else
		bkill -J $test
		sleep 2
		# Create the folder needed
		rm -fr $LPATH/$test
		mkdir -p $LPATH/$test

		# Copy all files needed
		cp submit/$test.sh $LPATH/$test/submit$test.sh
		cp -t $LPATH/$test -f $SPATH/$test.sh $EXEC

		# Move to the directory submit the code and return
		cd $LPATH/$test
		bsub < submit$test.sh
		cd ../../
	fi
done
echo " "
echo "------------------------------------------------------------------"
# # EOF # #

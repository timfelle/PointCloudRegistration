#!/bin/sh
#==============================================================================
# Define Preparation of data ect.

Prepare()
{
	# Setup folders needed
	TNAME=`basename -- "$0"`
	FIG=../../figures/${TNAME%.*}
	DAT=../../data/seal
	MAT=../../matlab

	mkdir -p fig $FIG $FIG/data dat

	# Define input and output paths
	export INPUT_PATH="dat/"
	export OUTPUT_PATH="dat/"

	echo "Input and output paths defined by:"
	echo "   Input : $INPUT_PATH"
	echo "   Output: $OUTPUT_PATH"
	echo ' '

	case "$OSTYPE" in
		linux*)   DATA="*" ;;
		cygwin*)  DATA="0[2-3]*" ;;
	esac

	SETS="left right upright"
	for orientation in $SETS ; do
		mkdir -p dat/$orientation 
		cp -ft dat/$orientation/ $DAT/$orientation/pointcloud_$DATA
	done
}

# End of Preparation
#==============================================================================
# Define the actual test part of the script 

Program()
{
	export ALPHA=1.5

	for s in $SETS ; 
	do
		FPFH_VERSION=open3d \
		FGR_VERSION=local \
		INPUT_PATH=dat/$s/ \
		OUTPUT_PATH=dat/$s/ \
		OUTPUT_NAME=local \
			./Registration.exe pointcloud
		
		FPFH_VERSION=open3d \
		FGR_VERSION=open3d \
		INPUT_PATH=dat/$s/ \
		OUTPUT_PATH=dat/$s/ \
		OUTPUT_NAME=open3d \
			./Registration.exe pointcloud
	done
}

# End of Program
#==============================================================================
# Define Visualize

Visualize()
{
	echo ' '
	echo Visualizing
	MATOPT="-wait -nodesktop -nosplash"
	DISREG="'pointcloud','local','open3d'"
	
	for s in $SETS;
	do
		matlab $MATOPT \
		-r "addpath('$MAT');displayRegistration({$DISREG},'dat/$s','fig/$s');"
	done
}

# End of Visualize
#==============================================================================
# Define Finalize

Finalize()
{
	rm -fr $FIG
	mkdir -p fig $FIG $FIG/data 
	
	mv -ft $FIG fig/*
	mv -ft $FIG/data dat/*
	rm -fr *.exe *.sh fig dat

	echo "   Figures moved to $FIG."
	echo "   Data used located in $FIG/data"
}

# End of Visualize
#==============================================================================
# Define Early Termination

Early()
{
	rm -fr *.ply *.exe *.sh fig dat
	echo ' '
	echo ' ================= WARNING: EARLY TERMINATION ================= '
	cat error.err 
	echo ' ===================== ERRORS SHOWN ABOVE ===================== '
	echo ' '
}

# End of Early Termination
#==============================================================================
# Call Functions
echo __________________________________________________________________________
echo 'Preparing data and folders'
echo ' '
full_start=`date +%s.%N`
Prepare

if [ -s error.err ] ; then
	Early
	exit
fi

echo ' '
echo __________________________________________________________________________
echo 'Commencing tests:'
echo ' '
test_start=`date +%s.%N`

Program

test_end=`date +%s.%N`
runtime=$(echo $test_end $test_start | awk '{ printf "%f", $1 - $2 }')
echo "Computation time for test: $runtime seconds."
if [ -s error.err ] ; then
	Early
	exit
fi

echo ' '
echo __________________________________________________________________________

Visualize

if [ -s error.err ] ; then
	Early
	exit
fi

echo ' '
echo __________________________________________________________________________
echo ' '
echo Finalizing

Finalize

if [ -s error.err ] ; then
	Early
	exit
fi
full_end=`date +%s.%N`
runtime=$(echo $full_end $full_start | awk '{ printf "%f", $1 - $2 }')
echo "Computation time for full test: $runtime seconds."
echo 'Test concluded successfully.'
echo __________________________________________________________________________
# ==============================   End of File   ==============================
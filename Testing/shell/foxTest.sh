#!/bin/sh
#==============================================================================
# Define Preparation of data ect.

Prepare()
{
	# Setup folders needed
	TNAME=`basename -- "$0"`
	FIG=../../figures/${TNAME%.*}
	DAT=../../data/fox
	MAT=../../matlab

	mkdir -p fig 

	# Define input and output paths
	export INPUT_PATH="dat/"
	export OUTPUT_PATH="dat/"

	echo "Input and output paths defined by:"
	echo "   Input : $INPUT_PATH"
	echo "   Output: $OUTPUT_PATH"
	echo ' '

	case "$OSTYPE" in
		linux*)   DATA="*" ;;
		cygwin*)  DATA="0[0-2]*" ;;
	esac

	SETS="left right upright upsidedown"
	for orientation in $SETS ; do
		mkdir -p dat/$orientation fig/$orientation
		cp -ft dat/$orientation/ $DAT/$orientation/pointcloud_$DATA
	done
}

# End of Preparation
#==============================================================================
# Define the actual test part of the script 

Program()
{
	export ALPHA=1.7

	DISREG="'pointcloud','local','open3d'"

	for s in $SETS ; 
	do
		FPFH_VERSION=open3d \
		INPUT_PATH=dat/$s/ \
		OUTPUT_PATH=dat/$s/ \
		OUTPUT_NAME=local \
			./Registration.exe pointcloud
		
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

	for s in $SETS;
	do
		matlab $MATOPT \
		-r "addpath('$MAT');displayRegistration({$DISREG},'dat/$s','fig/$s');exit;"
	done
}

# End of Visualize
#==============================================================================
# Define Finalize

Finalize()
{
	rm -fr $FIG
	mkdir -p fig $FIG $FIG/data 

	mv -ft $FIG fig/* 2>/dev/null
	mv -ft $FIG/data dat/* 2>/dev/null
	rm -fr *.exe *.sh fig dat

	echo "   Figures moved to $FIG."
	echo "   Data used located in $FIG/data"
}

# End of Visualize
#==============================================================================
# Define Early Termination

Early()
{
	if [ -s error.err ] ; then
		rm -fr *.ply *.exe *.sh fig dat
		echo ' '
		echo ' ================= WARNING: EARLY TERMINATION ================= '
		cat error.err 
		echo ' ===================== ERRORS SHOWN ABOVE ===================== '
		echo ' '
		exit
	fi
}

# End of Early Termination
#==============================================================================
# Call Functions
echo __________________________________________________________________________
echo 'Preparing data and folders'
echo ' '
full_start=`date +%s.%N`

Early && Prepare

echo ' '
echo __________________________________________________________________________
echo 'Commencing tests:'
echo ' '
test_start=`date +%s.%N`
Early && Program

test_end=`date +%s.%N`
runtime=$(echo $test_end $test_start | awk '{ printf "%f", $1 - $2 }')
echo "Computation time for test: $runtime seconds."



echo ' '
echo __________________________________________________________________________

Early && Visualize

echo ' '
echo __________________________________________________________________________
echo ' '
echo Finalizing

Early && Finalize

Early
full_end=`date +%s.%N`
runtime=$(echo $full_end $full_start | awk '{ printf "%f", $1 - $2 }')
echo "Computation time for full test: $runtime seconds."
echo 'Test concluded successfully.'
echo __________________________________________________________________________
# ==============================   End of File   ==============================

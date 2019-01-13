#!/bin/sh
#==============================================================================
# Define Preparation of data ect.

Prepare()
{
	# Setup folders needed
	TNAME=`basename -- "$0"`
	FIG=../../figures/${TNAME%.*}
	DAT=../../data
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
	cp -ft dat $DAT/seal/left/pointcloud_$DATA

}

# End of Preparation
#==============================================================================
# Define the actual test part of the script 

Program()
{
	ALPHA=1.5 \
	FPFH_VERSION=open3d \
	FGR_VERSION=local \
		./Registration.exe pointcloud
}

# End of Program
#==============================================================================
# Define Visualize

Visualize()
{
	echo ' '
	echo Visualizing
	MATOPT="-wait -nodesktop -nosplash -softwareopengl"

	DISREG="'pointcloud','result'"

	matlab $MATOPT \
	-r "addpath('$MAT');displayRegistration({$DISREG},'dat/','fig/');exit"
	matlab $MATOPT \
	-r "addpath('$MAT');animateRegistration('pointcloud','result','dat/','fig');exit;"
}

# End of Visualize
#==============================================================================
# Define Finalize

Finalize()
{
	mv -ft $FIG fig/*
	mv -ft $FIG/data dat/*
	rm -fr *.exe *.sh fig dat

	echo '   Figures moved to $FIG.'
	echo '   Data used located in $FIG/data'
	echo 'Test concluded successfully.'
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

Prepare

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

echo ' '
echo __________________________________________________________________________
echo ' '
echo Finalizing

Finalize

echo ' '
echo __________________________________________________________________________
# ==============================   End of File   ==============================

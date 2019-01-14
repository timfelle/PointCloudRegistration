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

	mkdir -p fig $FIG $FIG/data dat/left dat/right dat/upright dat/upsidedown

	# Define input and output paths
	export INPUT_PATH="dat/"
	export OUTPUT_PATH="dat/"

	echo "Input and output paths defined by:"
	echo "   Input : $INPUT_PATH"
	echo "   Output: $OUTPUT_PATH"
	echo ' '

	case "$OSTYPE" in
		linux*)   DATA="*" ;;
		cygwin*)  DATA="0[0-1]*" ;;
	esac
	cp -ft dat/left $DAT/fox/left/pointcloud_$DATA
	cp -ft dat/right $DAT/fox/right/pointcloud_$DATA
	cp -ft dat/upright $DAT/fox/upright/pointcloud_$DATA
	cp -ft dat/upsidedown $DAT/fox/upsidedown/pointcloud_$DATA

}

# End of Preparation
#==============================================================================
# Define the actual test part of the script 

Program()
{
	ALPHA=1.5 \
	FPFH_VERSION=open3d \
	FGR_VERSION=local \
	INPUT_PATH=dat/left/ \
	OUTPUT_NAME=foxLeft \
		./Registration.exe pointcloud

	ALPHA=1.5 \
	FPFH_VERSION=open3d \
	FGR_VERSION=local \
	INPUT_PATH=dat/right/ \
	OUTPUT_NAME=foxRight \
		./Registration.exe pointcloud

	ALPHA=1.5 \
	FPFH_VERSION=open3d \
	FGR_VERSION=local \
	INPUT_PATH=dat/upright/ \
	OUTPUT_NAME=foxUpright \
		./Registration.exe pointcloud

	ALPHA=1.5 \
	FPFH_VERSION=open3d \
	FGR_VERSION=local \
	INPUT_PATH=dat/upsidedown/ \
	OUTPUT_NAME=foxUpsidedown \
		./Registration.exe pointcloud	
}

# End of Program
#==============================================================================
# Define Visualize

Visualize()
{
	echo ' '
	echo Visualizing
	MATOPT="-wait -nodesktop -nosplash"

	DISREG="'foxLeft','foxRight','foxUpright','foxUpsidedown'"

	matlab $MATOPT \
	-r "addpath('$MAT');displayRegistration({$DISREG},'dat/','fig/');exit"

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
echo 'Test concluded successfully.'
echo __________________________________________________________________________
# ==============================   End of File   ==============================

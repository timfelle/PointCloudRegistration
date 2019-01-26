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

	# Fetch the data needed from the data folder
	cp $DAT/bunnyPartial1.ply dat/bunnyClean.ply
	cp $DAT/bunnyPartial2.ply dat/bunnyTransform.ply

	mkdir -p dat/seal2 dat/seal4 dat/seal6
	cp -ft dat/seal2 $DAT/seal/left/pointcloud_0[0-1].ply
	cp -ft dat/seal4 $DAT/seal/left/pointcloud_0[0-3].ply
	cp -ft dat/seal6 $DAT/seal/left/pointcloud_0[0-5].ply

	# Alter the moddels as needed
	ROTATION="0.52,0.52,0.79" \
	TRANSLATION="0.0,0.0,0.0" \
		./GenerateData.exe bunnyTransform.ply bunnyTransform.ply

}

# End of Preparation
#==============================================================================
# Define the actual test part of the script 

Program()
{
	# Tests using the bunny data ----------------------------------------------
	export ALPHA="1.5"

	echo 'Testing project implementation'
	start=`date +%s.%N`

	FPFH_VERSION=project \
	FGR_VERSION=project \
	OUTPUT_NAME=project \
		./Registration.exe bunny

	end=`date +%s.%N`
	runtime=$(echo $end $start | awk '{ printf "%f", $1 - $2 }')
	echo ' '
	echo "project: $runtime"
	echo ' '
	echo ---------------------------------------------------------------

	echo 'Testing FPFH open3d'
	start=`date +%s.%N`
	
	FPFH_VERSION=open3d \
	FGR_VERSION=project \
	OUTPUT_NAME=fpfh_open3d \
		./Registration.exe bunny

	end=`date +%s.%N`
	runtime=$(echo $end $start | awk '{ printf "%f", $1 - $2 }')
	echo ' '
	echo "FPFH: $runtime"
	echo ' '
	echo ---------------------------------------------------------------

	echo 'Testing FGR open3d'
	start=`date +%s.%N`

	FPFH_VERSION=open3d \
	FGR_VERSION=open3d \
	OUTPUT_NAME=fgr_open3d \
		./Registration.exe bunny

	end=`date +%s.%N`
	runtime=$(echo $end $start | awk '{ printf "%f", $1 - $2 }')
	echo ' '
	echo "FGR: $runtime"

	# -------------------------------------------------------------------------

	seal="2 4 6"
	start=`date +%s.%N`

	FPFH_VERSION=project \
	FGR_VERSION=project \
	INPUT_PATH=dat/seal2/ \
		./Registration.exe pointcloud >> tmp.txt

	end=`date +%s.%N`
	runtime=$(echo $end $start | awk '{ printf "%f", $1 - $2 }')
	echo "Project seal 2: $runtime"
	echo "Project seal 4: NA"
	echo "Project seal 6: NA"


	for s in $seal; do
		start=`date +%s.%N`

		FPFH_VERSION=open3d \
		FGR_VERSION=project \
		INPUT_PATH=dat/seal$s/ \
			./Registration.exe pointcloud >> tmp.txt

		end=`date +%s.%N`
		runtime=$(echo $end $start | awk '{ printf "%f", $1 - $2 }')
		echo "FPFH seal $s: $runtime"
	done
	for s in $seal; do
		start=`date +%s.%N`

		FPFH_VERSION=open3d \
		FGR_VERSION=open3d \
		INPUT_PATH=dat/seal$s/ \
			./Registration.exe pointcloud >> tmp.txt

		end=`date +%s.%N`
		runtime=$(echo $end $start | awk '{ printf "%f", $1 - $2 }')
		echo "FGR seal $s: $runtime"
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
	MATTESTS="'project','fpfh_open3d','fgr_open3d'"
	matlab $MATOPT \
	-r "addpath('$MAT');displayRegistration({$MATTESTS},'dat/','fig/',[],20);exit"
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
	rm -fr *.exe *.txt *.sh fig dat

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
set -e

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

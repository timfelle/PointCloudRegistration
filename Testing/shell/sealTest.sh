#!/bin/sh
echo "====================================================================="
echo "sealTest.sh:"
echo "   This is a full-scale test of the algorithm examining the left"
echo "   oriented seal dataset"
echo " "

FIG=../../figures/sealTest
DAT=../../data
MAT=../../matlab

export INPUT_PATH="dat/"
export OUTPUT_PATH="dat/"

# ==============================================================================
# Generate all the data needed

echo "Input and output paths defined by:                                   "
echo "Input : $INPUT_PATH                                                  "
echo "Output: $OUTPUT_PATH                                                 "
echo "                                                                     "
mkdir -p dat
cp -ft dat $DAT/seal/left/pointcloud_0[2-3]*

echo "====================================================================="
echo "Commencing tests:                                                    "
echo " "

export ROTATION=1.7,0.0,1.5
#./GenerateData pointcloud_00.ply pointcloud_00.ply

# Test registration
export INI_R=0.0100
export END_R=0.0005
export NUM_R=10
export ALPHA=1.5
export FPFH_VERSION=open3d
export FGR_VERSION=local
./Registration.exe pointcloud

if [ -s error.err ] ; then
	echo "Errors have been found. Exiting."
	echo " "
	rm -fr *.ply *.exe *.sh fig dat
	exit
fi
# ==============================================================================
# Export the figures using matlab
echo " "
echo "====================================================================="
echo "Running matlab to complete visualisation.                            "
mkdir -p fig $FIG $FIG/data
matlab -wait -nodesktop -nosplash -r "addpath('$MAT');
	displayRegistration('pointcloud','$INPUT_PATH','fig');
	displayRegistration('result','$OUTPUT_PATH','fig');
	%animateRegistration('pointcloud','result','dat/','fig');
	exit;"
mv -ft $FIG fig/*
mv -ft $FIG/data dat/*
rm -fr *.exe *.sh fig dat
echo "Results placed in folder:                                            "
echo $FIG
echo "====================================================================="

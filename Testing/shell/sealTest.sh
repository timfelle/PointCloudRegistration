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

mkdir -p dat
cp -ft dat $DAT/seal/left/pointcloud*
# ==============================================================================
# Generate all the data needed

echo "Input and output paths defined by:                                   "
echo "Input : $INPUT_PATH                                                  "
echo "Output: $OUTPUT_PATH                                                 "
echo "                                                                     "

echo "====================================================================="
echo "Commencing tests:                                                    "
echo " "

# Test registration
export MIN_R=0.0100
export MAX_R=0.0001
export STP_R=0.9
export ALPHA=1.7
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
mkdir -p fig $FIG
matlab -wait -nodesktop -nosplash -r "addpath('$MAT');
	%displayRegistration('pointcloud','$INPUT_PATH','fig');
	displayRegistration('result','$OUTPUT_PATH','fig');
	%animateRegistration('pointcloud','result','dat/','fig');
	exit;"
mv -ft $FIG fig/*
rm -fr *.ply *.exe *.sh fig dat
echo "Results placed in folder:                                            "
echo $FIG
echo "====================================================================="

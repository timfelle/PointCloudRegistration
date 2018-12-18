#!/bin/sh
echo "====================================================================="
echo "sealTest.sh:"
echo "   This is a full-scale test of the algorithm examining the left"
echo "   oriented seal dataset"
echo " "

DAT=../../data
FIG=../../figures/sealTest
MAT=../../matlab

mkdir -p dat
cp -ft dat $DAT/seal/left/pointcloud*
# ==============================================================================
# Generate all the data needed
export INPUT_PATH="./dat/"
export OUTPUT_PATH="./dat/"

echo "Input and output paths defined by:                                   "
echo "Input : $INPUT_PATH                                                  "
echo "Output: $OUTPUT_PATH                                                 "
echo "                                                                     "

echo "====================================================================="
echo "Commencing tests:                                                    "
echo " "

# Test registration
export MIN_R=0.005
export MAX_R=0.050
export STP_R=1.1
./Registration pointcloud

if [ -s error.err ] ; then
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
	%animateRegistration('pointcloud','result','./dat/','fig');
	exit;"
mv -ft $FIG fig/*
rm -fr *.ply *.exe *.sh fig
echo "Results placed in folder:                                            "
echo $FIG
echo "====================================================================="

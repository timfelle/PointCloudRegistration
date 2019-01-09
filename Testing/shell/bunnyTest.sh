#!/bin/sh
echo "====================================================================="
echo "bunnyTest.sh:"
echo "   This is a full-scale test of the algorithm examining the raw"
echo "   bunny dataset."
echo " "

FIG=../../figures/bunnyTest
DAT=../../data
MAT=../../matlab

export INPUT_PATH="dat/"
export OUTPUT_PATH="dat/"

mkdir -p dat
cp -ft dat $DAT/bunny/*
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
#export INI_R=0.0001
#export END_R=0.070
#export NUM_R=1000
export ALPHA=1.5
./Registration.exe bunny

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
	displayRegistration('bunny','$INPUT_PATH','fig');
	displayRegistration('result','$OUTPUT_PATH','fig');
	animateRegistration('bunny','result','dat/','fig');
	exit;"
mv -ft $FIG fig/* dat
rm -fr *.exe *.sh fig
echo "Results placed in folder:                                            "
echo $FIG
echo "====================================================================="

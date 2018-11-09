#!/bin/sh
echo "====================================================================="
echo "generateData.sh:                                                     "
echo "   This is the test generateData. This test will display the effect  "
echo "   of several settings for the data generation program.              "
echo "                                                                     "

DAT=../../data/
FIG=../../figures/
MAT=../../matlab

# ==============================================================================
# Generate all the data needed
export INPUT_PATH=./
export OUTPUT_PATH=./

echo "Input and output paths defined by:                                   "
echo "Input : $INPUT_PATH                                                  "
echo "Output: $OUTPUT_PATH                                                 "
echo "                                                                     "

# Clean model
echo "Fetching clean model"
cp $DAT/bunnyPartial1.ply bunnyClean.ply
MODEL="'bunnyClean', "

echo "====================================================================="
echo "Commencing tests:                                                    "

# Test transformation
echo "   Transformation.                                                   "
export NOISE_TYPE=none
export ROTATION="0.52,0.52,0.79" # degrees: 30, 30, 45
export TRANSLATION="0.0,0.0,0.0"
./GenerateData $DAT/bunnyPartial2.ply bunnyTransform.ply

MODEL+="'bunnyTransform' "

# Test registration

./Registration $DAT/bunnyPartial2.ply bunnyTransform.ply

rm -fr loadingBar.out # Remove all the loading bars again.
# ==============================================================================
# Export the figures using matlab
echo "Running matlab to complete visualisation.                            "
mkdir fig
matlab -wait -nodesktop -nosplash \
	-r "addpath('$MAT');displayRegistration('bunny','./','fig');exit;" 
matlab -wait -nodesktop -nosplash \
	-r "addpath('$MAT');displayRegistration('result','./','fig');exit;" 
mv -t $FIG fig/*
echo "Results placed in folder:                                            "
echo $FIG
echo "====================================================================="
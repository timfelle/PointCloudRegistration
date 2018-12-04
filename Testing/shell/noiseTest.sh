#!/bin/sh
echo "====================================================================="
echo "generateData.sh:                                                     "
echo "   This is the test generateData. This test will display the effect  "
echo "   of several settings for the data generation program.              "
echo "                                                                     "

DAT=../../data
FIG=../../figures/NoiseTest
MAT=../../matlab

# ==============================================================================
# Generate all the data needed
export INPUT_PATH="./"
export OUTPUT_PATH="./"

echo "Input and output paths defined by:                                   "
echo "Input : $INPUT_PATH                                                  "
echo "Output: $OUTPUT_PATH                                                 "
echo "                                                                     "

# Clean model
echo "   Fetching clean models"
cp $DAT/bunnyPartial1.ply bunnyClean.ply
cp $DAT/bunnyPartial2.ply bunnyTransform.ply

# Test transformation
echo "   Generating transformed model."
export NOISE_TYPE=none
export ROTATION="0.52,0.52,0.79" # degrees: 30, 30, 45
export TRANSLATION="0.0,0.0,0.0"
./GenerateData bunnyTransform.ply bunnyTransform.ply

export NOISE_TYPE=gaussian
export NOISE_STRENGTH=0.5
./GenerateData bunnyClean.ply gaussianBunny1.ply
./GenerateData bunnyTransform.ply gaussianBunny2.ply

export NOISE_TYPE=gaussian
export NOISE_STRENGTH=1.0
./GenerateData bunnyClean.ply gaussianBunny3.ply
./GenerateData bunnyTransform.ply gaussianBunny4.ply

echo "====================================================================="
echo "Commencing tests:                                                    "
echo " "

# Test registration
echo "Clean ---------------------------------------------------------------"
OUTPUT_NAME=resultClean  ./Registration bunnyClean.ply bunnyTransform.ply
echo " "
echo "Gaussian 1 ----------------------------------------------------------"
OUTPUT_NAME=resultGauss1 \
	MIN_R=0.02 \
	MAX_R=0.10 \
	./Registration gaussianBunny1.ply gaussianBunny2.ply
echo " "
echo "Gaussian 2 ----------------------------------------------------------"
OUTPUT_NAME=resultGauss2 ./Registration gaussianBunny3.ply gaussianBunny4.ply

rm -fr loadingBar.out # Remove all the loading bars again.
# ==============================================================================
# Export the figures using matlab
echo " "
echo "====================================================================="
echo "Running matlab to complete visualisation.                            "
mkdir fig $FIG -p
matlab -wait -nodesktop -nosplash \
	-r "addpath('$MAT');displayRegistration('resultClean','./','fig');exit;" 
matlab -wait -nodesktop -nosplash \
	-r "addpath('$MAT');displayRegistration('resultGauss1','./','fig');exit;" 
matlab -wait -nodesktop -nosplash \
	-r "addpath('$MAT');displayRegistration('resultGauss2','./','fig');exit;" 
mv -t $FIG fig/*
rm -f *.ply *.exe *.sh
echo "Results placed in folder:                                            "
echo $FIG
echo "====================================================================="

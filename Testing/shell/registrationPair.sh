#!/bin/sh
echo "====================================================================="
echo "generateData.sh:                                                     "
echo "   This is the test generateData. This test will display the effect  "
echo "   of several settings for the data generation program.              "
echo "                                                                     "

FIG=../../figures/RegistrationPair
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

# Clean model
echo "   Fetching clean models"
cp $DAT/bunnyPartial1.ply bunnyClean.ply
cp $DAT/bunnyPartial2.ply bunnyTransform.ply

# Test transformation
echo "   Generating transformed model."
export NOISE_TYPE=none
export ROTATION="0.52,0.52,0.79" # degrees: 30, 30, 45
export TRANSLATION="0.05,0.0,-0.01"
./GenerateData.exe bunnyTransform.ply bunnyTransform.ply

echo "====================================================================="
echo "Commencing tests:                                                    "

# Test registration
./Registration.exe bunnyClean.ply bunnyTransform.ply

if [ -s error.err ] ; then
	echo "Errors have been found. Exiting."
	echo " "
	rm -fr *.ply *.exe *.sh fig dat
	exit
fi
# ==============================================================================
# Export the figures using matlab
echo "Running matlab to complete visualisation.                            "
mkdir -p fig $FIG $FIG/data
matlab -wait -nodesktop -nosplash -r "addpath('$MAT');
	displayRegistration('bunny','dat/','fig');
	displayRegistration('result','dat/','fig');
	animateRegistration('bunny','result','dat/','fig');
	exit;" 
mv -ft $FIG fig/*
mv -ft $FIG/data dat/*
rm -fr *.exe *.sh fig dat
echo "Results placed in folder:                                            "
echo $FIG
echo "====================================================================="

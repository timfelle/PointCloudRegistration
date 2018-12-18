#!/bin/sh
echo "====================================================================="
echo "correspondences.sh:"
echo "   This test display the correspondences before and after"
echo "	 registration."
echo " "

DAT=../../data
FIG=../../figures/Correspondences
MAT=../../matlab

export INPUT_PATH="./"
export OUTPUT_PATH="./"

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
export TRANSLATION="0.0,0.0,0.0"
./GenerateData.exe bunnyTransform.ply bunnyTransform.ply

echo "====================================================================="
echo "Commencing tests:                                                    "

# Test registration
export EXPORT_CORRESPONDENCES="true"
./Registration.exe bunnyClean.ply bunnyTransform.ply

if [ -s error.err ] ; then
	exit
fi
# ==============================================================================
# Export the figures using matlab
echo "Running matlab to complete visualisation.                            "
mkdir fig $FIG -p
matlab -wait -nodesktop -nosplash -minimize -r "addpath('$MAT');
	animateCorrespondences('Corr','./','fig');
	exit;"
mv -ft $FIG fig/*
rm -fr *.ply *.exe *.sh fig
echo "Results placed in folder:                                            "
echo $FIG
echo "====================================================================="

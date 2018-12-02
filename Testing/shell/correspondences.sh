#!/bin/sh
echo "====================================================================="
echo "generateData.sh:                                                     "
echo "   This is the test generateData. This test will display the effect  "
echo "   of several settings for the data generation program.              "
echo "                                                                     "

DAT=../../data
FIG=../../figures/Correspondences
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

echo "====================================================================="
echo "Commencing tests:                                                    "

# Test registration
export EXPORT_CORRESPONDENCES="true"
(
	set -e
	./Registration bunnyClean.ply bunnyTransform.ply
)
if [ $? -ne 0 ]; then
  exit $?
fi

rm -fr loadingBar.out # Remove all the loading bars again.
# ==============================================================================
# Export the figures using matlab
echo "Running matlab to complete visualisation.                            "
mkdir fig $FIG -p
matlab -wait -nodesktop -nosplash -minimize \
	-r "addpath('$MAT');animateCorrespondences('Corr','./','fig');exit;"
mv -t $FIG fig/*
echo "Results placed in folder:                                            "
echo $FIG
echo "====================================================================="

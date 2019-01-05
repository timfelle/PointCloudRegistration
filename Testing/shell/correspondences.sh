#!/bin/sh
echo "====================================================================="
echo "correspondences.sh:"
echo "   This test display the correspondences before and after"
echo "	 registration."
echo " "

FIG=../../figures/Correspondences
DAT=../../data
MAT=../../matlab

mkdir dat
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
cp $DAT/bunnyPartial1.ply dat/bunnyClean.ply
cp $DAT/bunnyPartial2.ply dat/bunnyTransform.ply

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
	echo "Errors have been found. Exiting."
	echo " "
	rm -fr *.ply *.exe *.sh fig dat
	exit
fi
# ==============================================================================
# Export the figures using matlab
echo "Running matlab to complete visualisation.                            "
mkdir fig $FIG -p
matlab -wait -nodesktop -nosplash -minimize -r "addpath('$MAT');
	displayCorrespondences('Corr','dat/','fig');
	animateCorrespondences('Corr','dat/','fig');
	exit;"
mv -ft $FIG fig/* dat
rm -fr *.exe *.sh fig
echo "Results placed in folder:                                            "
echo $FIG
echo "====================================================================="

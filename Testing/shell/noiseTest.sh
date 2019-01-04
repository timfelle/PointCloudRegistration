#!/bin/sh
echo "====================================================================="
echo "noiseTest.sh:"
echo "   Noise test. This will run the program for several amounts and"
echo "   types of noise and display the results."
echo " "

FIG=../../figures/NoiseTest
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
mkdir dat
cp $DAT/bunnyPartial1.ply dat/bunnyClean.ply
cp $DAT/bunnyPartial2.ply dat/bunnyTransform.ply

# Test transformation
echo "   Generating transformed model."
# Rotation in degrees: 30, 30, 45 
NOISE_TYPE=none \
	ROTATION="0.52,0.52,0.79" \
	TRANSLATION="0.05,0.0,-0.01" \
	./GenerateData.exe bunnyTransform.ply bunnyTransform.ply


echo "====================================================================="
echo "Commencing tests:                                                    "
echo " "

echo "Clean ---------------------------------------------------------------"
echo " "
OUTPUT_NAME=resultClean \
	ALPHA=1.6 MIN_R=0.0001 MAX_R=0.01 \
	./Registration.exe bunnyClean.ply bunnyTransform.ply 
echo " "
echo "Gaussian   ----------------------------------------------------------"
echo " "
export NOISE_TYPE=gaussian
export NOISE_STRENGTH=0.01
./GenerateData.exe bunnyClean.ply gaussianBunny1.ply 
./GenerateData.exe bunnyTransform.ply gaussianBunny2.ply 
echo " "

OUTPUT_NAME=resultGauss1 \
	ALPHA=1.5 MIN_R=0.0001 MAX_R=0.01 \
	./Registration.exe gaussianBunny1.ply gaussianBunny2.ply
echo "----------------------------------------------------------"
echo " "
export NOISE_TYPE=gaussian
export NOISE_STRENGTH=0.1
./GenerateData.exe bunnyClean.ply gaussianBunny3.ply 
./GenerateData.exe bunnyTransform.ply gaussianBunny4.ply 
echo " "

OUTPUT_NAME=resultGauss2 \
	ALPHA=1.8 MIN_R=0.001 MAX_R=0.05 \
	./Registration.exe gaussianBunny3.ply gaussianBunny4.ply

echo " "
echo "Outliers   ----------------------------------------------------------"
echo " "
export NOISE_TYPE=outliers
export OUTLIER_AMOUNT=1.0
./GenerateData.exe bunnyClean.ply outlierBunny1.ply 
./GenerateData.exe bunnyTransform.ply outlierBunny2.ply 
echo " "

OUTPUT_NAME=resultOut1 \
	ALPHA=1.6 MIN_R=0.0001 MAX_R=0.01 \
	./Registration.exe outlierBunny1.ply outlierBunny2.ply 

echo "----------------------------------------------------------"
echo " "
export NOISE_TYPE=outliers
export OUTLIER_AMOUNT=5.0
./GenerateData.exe bunnyClean.ply outlierBunny3.ply 
./GenerateData.exe bunnyTransform.ply outlierBunny4.ply 
echo " "

OUTPUT_NAME=resultOut2 \
	ALPHA=1.6 MIN_R=0.0001 MAX_R=0.01 \
	./Registration.exe outlierBunny3.ply outlierBunny4.ply 

echo "----------------------------------------------------------"
echo " "
export NOISE_TYPE=outliers
export OUTLIER_AMOUNT=10.0
./GenerateData.exe bunnyClean.ply outlierBunny5.ply 
./GenerateData.exe bunnyTransform.ply outlierBunny6.ply 
echo " "

OUTPUT_NAME=resultOut3 \
	ALPHA=1.6 MIN_R=0.0001 MAX_R=0.01 \
	./Registration.exe outlierBunny5.ply outlierBunny6.ply 
echo "----------------------------------------------------------"
wait
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
	displayRegistration('bunny','dat/','fig');
	displayRegistration('resultClean','dat/','fig');
	displayRegistration('resultGauss1','dat/','fig');
	displayRegistration('resultGauss2','dat/','fig');
	displayRegistration('resultOut1','dat/','fig');
	displayRegistration('resultOut2','dat/','fig');
	displayRegistration('resultOut3','dat/','fig');
	exit;"
mv -ft $FIG fig/*
rm -fr *.exe *.sh fig
echo "Results placed in folder:                                            "
echo $FIG
echo "====================================================================="

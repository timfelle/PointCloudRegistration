#!/bin/sh
echo "====================================================================="
echo "registrationMulti.sh:"
echo "   Registration.exe of multiple surfaces"
echo " "

FIG=../../figures/RegistrationMulti
DAT=../../data
MAT=../../matlab

mkdir -p dat
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
cp $DAT/bunnyPartial2.ply dat/bunnyTransform1.ply
cp $DAT/bunny.ply dat/bunnyTransform2.ply

# Test transformation
echo "   Generating transformed models."
ROTATION="0.52,0.52,0.79" \
	TRANSLATION="0.05,0.0,-0.01" \
	./GenerateData.exe bunnyTransform1.ply bunnyTransform1.ply

ROTATION="0.22,0.62,-0.79" \
	TRANSLATION="-0.1,0.05,-0.01" \
	./GenerateData.exe bunnyTransform2.ply bunnyTransform2.ply

echo "====================================================================="
echo "Commencing tests:                                                    "

# Test registration
export INI_R=0.0001
export END_R=0.0100
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
echo "Running matlab to complete visualisation.                            "
mkdir -p fig $FIG $FIG/data
matlab -wait -nodesktop -nosplash -r "addpath('$MAT');
	displayRegistration('bunny','dat/','fig');
	displayRegistration('result','dat/','fig');
	%animateRegistration('bunny','result','dat/','fig');
	exit;" 
mv -ft $FIG fig/*
mv -ft $FIG/data dat/*
rm -fr *.exe *.sh fig dat
echo "Results placed in folder:                                            "
echo $FIG
echo "====================================================================="

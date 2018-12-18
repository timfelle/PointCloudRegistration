#!/bin/sh
echo "====================================================================="
echo "registrationMulti.sh:"
echo "   Registration.exe of multiple surfaces"
echo " "

DAT=../../data
FIG=../../figures/RegistrationMulti
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
cp $DAT/bunnyPartial2.ply bunnyTransform1.ply
cp $DAT/bunny.ply bunnyTransform2.ply

# Test transformation
echo "   Generating transformed models."
ROTATION="0.52,0.52,0.79" \
	TRANSLATION="0.1,-0.4,-0.1" \
	./GenerateData.exe bunnyTransform1.ply bunnyTransform1.ply

ROTATION="0.22,0.62,-0.79" \
	TRANSLATION="-0.1,0.3,-0.3" \
	./GenerateData.exe bunnyTransform2.ply bunnyTransform2.ply

echo "====================================================================="
echo "Commencing tests:                                                    "

# Test registration
./Registration.exe bunny

if [ -s error.err ] ; then
	exit
fi
# ==============================================================================
# Export the figures using matlab
echo "Running matlab to complete visualisation.                            "
mkdir fig $FIG -p
matlab -wait -nodesktop -nosplash -r "addpath('$MAT');
	displayRegistration('bunny','./','fig');
	displayRegistration('result','./','fig');
	animateRegistration('bunny','result','./','fig');
	exit;" 
mv -ft $FIG fig/*
rm -fr *.ply *.exe *.sh fig
echo "Results placed in folder:                                            "
echo $FIG
echo "====================================================================="

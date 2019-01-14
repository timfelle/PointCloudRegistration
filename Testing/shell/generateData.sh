#!/bin/sh
#==============================================================================
# Define Preparation of data ect.

Prepare()
{
	# Setup folders needed
	TNAME=`basename -- "$0"`
	FIG=../../figures/${TNAME%.*}
	DAT=../../data
	MAT=../../matlab

	mkdir -p fig $FIG $FIG/data dat

	# Define input and output paths
	export INPUT_PATH="dat/"
	export OUTPUT_PATH="dat/"

	echo "Input and output paths defined by:"
	echo "   Input : $INPUT_PATH"
	echo "   Output: $OUTPUT_PATH"
	echo ' '

	# Fetch the data needed from the data folder
	cp $DAT/bunny.ply dat/bunnyClean.ply
}

# End of Preparation
#==============================================================================
# Define the actual test part of the script 

Program()
{
	MODEL="'bunnyClean', "

	# Test the Gaussian noise
	echo "   Gaussian noise."
	export NOISE_TYPE=gaussian
	export NOISE_STRENGTH=1.5
	./GenerateData.exe bunnyClean.ply bunnyGaussian.ply

	MODEL+="'bunnyGaussian', "

	# Test the Outlier noise
	echo "   Outlier addition."
	export NOISE_TYPE=outliers
	export OUTLIER_AMOUNT=5.0
	./GenerateData.exe bunnyClean.ply bunnyOutliers.ply

	MODEL+="'bunnyOutliers', "

	# Test combination noise
	echo "   Combined noise and outlier."
	export NOISE_TYPE=both
	export NOISE_STRENGTH=2.0
	export OUTLIER_AMOUNT=5.0
	./GenerateData.exe bunnyClean.ply bunnyNoise.ply

	MODEL+="'bunnyNoise', "

	# Test transformation
	echo "   Transformation."
	export NOISE_TYPE=none
	export ROTATION="0.52,0.52,0.79" # degrees: 30, 30, 45
	export TRANSLATION="0.0,0.0,0.0"
	./GenerateData.exe bunnyClean.ply bunnyTransform.ply

	MODEL+="'bunnyTransform' "

}

# End of Program
#==============================================================================
# Define Visualize

Visualize()
{
	echo ' '
	echo Visualizing
	MATOPT="-wait -nodesktop -nosplash"
	matlab $MATOPT \
		-r "addpath('$MAT');displayModel({$MODEL},'dat/','fig/');exit;"
}

# End of Visualize
#==============================================================================
# Define Finalize

Finalize()
{
	mv -ft $FIG fig/*
	mv -ft $FIG/data dat/*
	rm -fr *.exe *.sh fig dat

	echo '   Figures moved to $FIG.'
	echo '   Data used located in $FIG/data'
	echo 'Test concluded successfully.'
}

# End of Visualize
#==============================================================================
# Define Early Termination

Early()
{
	rm -fr *.ply *.exe *.sh fig dat
	echo ' '
	echo ' ================= WARNING: EARLY TERMINATION ================= '
	cat error.err 
	echo ' ===================== ERRORS SHOWN ABOVE ===================== '
	echo ' '
}

# End of Early Termination
#==============================================================================
# Call Functions
echo __________________________________________________________________________
echo 'Preparing data and folders'
echo ' '

Prepare

if [ -s error.err ] ; then
	Early
	exit
fi

echo ' '
echo __________________________________________________________________________
echo 'Commencing tests:'
echo ' '
test_start=`date +%s.%N`

Program

test_end=`date +%s.%N`
runtime=$(echo $test_end $test_start | awk '{ printf "%f", $1 - $2 }')
echo "Computation time for test: $runtime seconds."
if [ -s error.err ] ; then
	Early
	exit
fi

echo ' '
echo __________________________________________________________________________

Visualize

if [ -s error.err ] ; then
	Early
	exit
fi

echo ' '
echo __________________________________________________________________________
echo ' '
echo Finalizing

Finalize

if [ -s error.err ] ; then
	Early
	exit
fi
echo 'Test concluded successfully.'
echo __________________________________________________________________________
# ==============================   End of File   ==============================

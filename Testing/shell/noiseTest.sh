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
	cp $DAT/bunnyPartial1.ply dat/bunnyClean.ply
	cp $DAT/bunnyPartial2.ply dat/bunnyTransform.ply

	# Rotation in degrees: 30, 30, 45 
	NOISE_TYPE=none \
	ROTATION="0.52,0.52,0.79" \
	TRANSLATION="0.05,0.0,-0.01" \
		./GenerateData.exe bunnyTransform.ply bunnyTransform.ply

}

# End of Preparation
#==============================================================================
# Define the actual test part of the script 

Program()
{

	echo "Clean ---------------------------------------------------------------"
	echo " "
	OUTPUT_NAME=resultClean \
		ALPHA=1.6 INI_R=0.0001 END_R=0.01 \
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
		ALPHA=1.6 INI_R=0.0005 END_R=0.01 \
		./Registration.exe gaussianBunny1.ply gaussianBunny2.ply

	echo "---------------------------------------------------------------------"
	echo " "
	export NOISE_TYPE=gaussian
	export NOISE_STRENGTH=0.2
	./GenerateData.exe bunnyClean.ply gaussianBunny3.ply
	./GenerateData.exe bunnyTransform.ply gaussianBunny4.ply
	echo " "

	OUTPUT_NAME=resultGauss2 \
		ALPHA=1.5 INI_R=0.001 END_R=0.08 \
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
		ALPHA=1.5 INI_R=0.0001 END_R=0.01 \
		./Registration.exe outlierBunny1.ply outlierBunny2.ply 

	echo "---------------------------------------------------------------------"
	echo " "
	export NOISE_TYPE=outliers
	export OUTLIER_AMOUNT=5.0
	./GenerateData.exe bunnyClean.ply outlierBunny3.ply 
	./GenerateData.exe bunnyTransform.ply outlierBunny4.ply 
	echo " "

	OUTPUT_NAME=resultOut2 \
		ALPHA=1.6 INI_R=0.0005 END_R=0.01 \
		./Registration.exe outlierBunny3.ply outlierBunny4.ply 

	echo "---------------------------------------------------------------------"
	echo " "
	export NOISE_TYPE=outliers
	export OUTLIER_AMOUNT=10.0
	./GenerateData.exe bunnyClean.ply outlierBunny5.ply 
	./GenerateData.exe bunnyTransform.ply outlierBunny6.ply 
	echo " "

	OUTPUT_NAME=resultOut3 \
		ALPHA=1.6 INI_R=0.0001 END_R=0.01 \
		./Registration.exe outlierBunny5.ply outlierBunny6.ply 
	echo "---------------------------------------------------------------------"

}

# End of Program
#==============================================================================
# Define Visualize

Visualize()
{
	echo ' '
	echo Visualizing

	MATTESTS="'bunny','resultClean',"
	MATTESTS+="'resultGauss1','resultGauss2',"
	MATTESTS+="'resultOut1','resultOut2','resultOut3'"

	MATOPT="-wait -nodesktop -nosplash"
	matlab $MATOPT \
	-r "addpath('$MAT');displayRegistration({$MATTESTS},'dat/','fig/');exit"
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

echo ' '
echo __________________________________________________________________________
echo ' '
echo Finalizing

Finalize

echo ' '
echo __________________________________________________________________________
# ==============================   End of File   ==============================

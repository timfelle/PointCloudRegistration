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
	export NOISE_TYPE=gaussian
	export NOISE_STRENGTH=0.2
	./GenerateData.exe bunnyClean.ply gaussianBunny1.ply
	./GenerateData.exe bunnyTransform.ply gaussianBunny2.ply
	echo " "

	export ALPHA=1.6
	export NUM_R=2
	export EXPORT_CORRESPONDENCES=true

	INI_R=0.99 END_R=0.1 \
	OUTPUT_NAME=bun10  ./Registration.exe bunny > tmp.txt &

	INI_R=0.99 END_R=0.1 \
	OUTPUT_NAME=gauss10 ./Registration.exe gaussian > tmp.txt &
	
	
	INI_R=0.14 END_R=0.15 \
	OUTPUT_NAME=bun15  ./Registration.exe bunny > tmp.txt &

	INI_R=0.14 END_R=0.15 \
	OUTPUT_NAME=gauss15 ./Registration.exe gaussian > tmp.txt &
	wait
}

# End of Program
#==============================================================================
# Define Visualize

Visualize()
{
	echo ' '
	echo Visualizing

	MATTESTS="'bun10','gauss10','bun15','gauss15'"

	MATOPT="-wait -nodesktop -nosplash"
	matlab $MATOPT \
	-r "addpath('$MAT');displayCorrespondences({$MATTESTS},'dat/','fig/',[],20);exit"
}

# End of Visualize
#==============================================================================
# Define Finalize

Finalize()
{
	rm -fr $FIG
	mkdir -p fig $FIG $FIG/data 

	mv -ft $FIG fig/* 2>/dev/null
	mv -ft $FIG/data dat/* 2>/dev/null
	rm -fr *.exe *.sh fig dat

	echo "   Figures moved to $FIG."
	echo "   Data used located in $FIG/data"
}

# End of Visualize
#==============================================================================
# Define Early Termination

Early()
{
	if [ -s error.err ] ; then
		rm -fr *.ply *.exe *.sh fig dat
		echo ' '
		echo ' ================= WARNING: EARLY TERMINATION ================= '
		cat error.err 
		echo ' ===================== ERRORS SHOWN ABOVE ===================== '
		echo ' '
		exit
	fi
}

# End of Early Termination
#==============================================================================
# Call Functions
echo __________________________________________________________________________
echo 'Preparing data and folders'
echo ' '
full_start=`date +%s.%N`
set -e

Early && Prepare

echo ' '
echo __________________________________________________________________________
echo 'Commencing tests:'
echo ' '
test_start=`date +%s.%N`
Early && Program

test_end=`date +%s.%N`
runtime=$(echo $test_end $test_start | awk '{ printf "%f", $1 - $2 }')
echo "Computation time for test: $runtime seconds."



echo ' '
echo __________________________________________________________________________

Early && Visualize

echo ' '
echo __________________________________________________________________________
echo ' '
echo Finalizing

Early && Finalize

Early
full_end=`date +%s.%N`
runtime=$(echo $full_end $full_start | awk '{ printf "%f", $1 - $2 }')
echo "Computation time for full test: $runtime seconds."
echo 'Test concluded successfully.'
echo __________________________________________________________________________
# ==============================   End of File   ==============================

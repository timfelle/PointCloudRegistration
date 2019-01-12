#!/bin/sh 

# --  General options 

# Naming of the job and queue name
#BSUB -J versionCompare
#BSUB -q hpc

# Specify
#BSUB -oo output.out 
#BSUB -eo error.err 

# -- Technical options

# Ask for n cores placed on R host.
#BSUB -n 1
#BSUB -R "span[ptile=1]"

# Memory specifications. Amount we need and when to kill the
# program using too much memory.
#BSUB -R "rusage[mem=5GB]"
#BSUB -M 5GB

# Time specifications (hh:mm)
#BSUB -W 00:30

# -- Notification options

# Set the email to recieve to and when to recieve it
##BSUB -u your_email_address
#BSUB -B		# Send notification at start
#BSUB -N 		# Send notification at completion

echo --------------------------------------------------------------------------
echo 'Job: '$LSB_JOBNAME', is running on '$LSB_DJOB_NUMPROC' cores.'
echo --------------------------------------------------------------------------
echo LSB: job identifier is $LSB_JOBID
echo LSB: execution queue is $LSB_QUEUE
echo LSB: total number of processors is $LSB_MAX_NUM_PROCESSORS
echo LSB: working directory is $LSB_OUTDIR
echo --------------------------------------------------------------------------

# End of LSB info
#==============================================================================
# Define Preparation

Prepare()
{
	FIG=../../figures/Correspondences
	DAT=../../data
	MAT=../../matlab

	export INPUT_PATH="dat/"
	export OUTPUT_PATH="dat/"
	mkdir -p fig $FIG $FIG/data dat

	
	echo "Input and output paths defined by:"
	echo "Input : $INPUT_PATH"
	echo "Output: $OUTPUT_PATH"
	echo " "

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

	export ROTATION="0.32,0.32,0.59" # degrees: 30, 30, 45
	export TRANSLATION="0.0,0.2,0.01"
	./GenerateData.exe bunnyclean.ply bunnyTransform2.ply

}

# End of Preparation
#==============================================================================
# Define Program

Program()
{
	echo ' '
	echo Running computations

	
	# -------------------------------------------------------------------------
	# Define the actual test part of the script 
		

	echo "====================================================================="
	echo "Commencing tests:                                                    "

	export ALPHA="1.5"

	echo "Testing local for both"
	start=`date +%s.%N`
	FPFH_VERSION=local FGR_VERSION=local \
		OUTPUT_NAME=local \
		./Registration.exe bunny
	end=`date +%s.%N`
	runtime=$(echo $end $start | awk '{ printf "%f", $1 - $2 }')
	echo "Local: $runtime"
	echo " "

	echo "Testing FPFH open3d"
	start=`date +%s.%N`
	FPFH_VERSION=open3d FGR_VERSION=local \
		OUTPUT_NAME=fpfh_open3d \
		./Registration.exe bunny
	end=`date +%s`
	runtime=$(echo $end $start | awk '{ printf "%f", $1 - $2 }')
	echo "FPFH: $runtime"
	echo " "

	echo "Testing FGR open3d"
	start=`date +%s.%N`
	FPFH_VERSION=open3d FGR_VERSION=open3d \
		OUTPUT_NAME=fgr_open3d \
		./Registration.exe bunny
	end=`date +%s.%N`
	runtime=$(echo $end $start | awk '{ printf "%f", $1 - $2 }')
	echo "FGR: $runtime"



	# -------------------------------------------------------------------------

}

# End of Program
#==============================================================================
# Define Visualize

Visualize()
{
	echo ' '
	echo Visualizing
	matlab -wait -nodesktop -nosplash -r "addpath('$MAT');
		displayRegistration('local','dat/','fig/');
		displayRegistration('fpfh_open3d','dat/','fig/');
		displayRegistration('fgr_open3d','dat/','fig/');
		exit;"
}

# End of Visualize
#==============================================================================
# Define Finalize

Finalize()
{
	echo ' '
	echo Finalizing

	mv -ft $FIG fig/*
	mv -ft $FIG/data dat/*
	rm -fr *.exe *.sh fig dat

	echo Figures moved to $FIG.
	echo Test concluded successfully.
}

# End of Visualize
#==============================================================================
# Define Early Termination

early()
{
	echo ' '
	echo ' ================= WARNING: EARLY TERMINATION ================= '
	echo ' '
}
trap 'early' 2 9 15

# End of Early Termination
#==============================================================================
# Call Functions

Prepare

echo ' '
echo --------------------------------------------------------------------------

Program

if [ -s error.err ] ; then
	echo "Errors have been found. Exiting."
	echo " "
	rm -fr *.ply *.exe *.sh fig dat
	exit
fi

echo ' '
echo --------------------------------------------------------------------------

Visualize

echo ' '
echo --------------------------------------------------------------------------

Finalize

echo ' '
echo --------------------------------------------------------------------------
# ==============================   End of File   ==============================

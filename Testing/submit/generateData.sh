#!/bin/sh 

# --  General options 

# Naming of the job and queue name
#BSUB -J generateData
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
#BSUB -W 10:00

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

DAT=../../data/
FIG=../../figures/GenerateData
MAT=../../matlab

export INPUT_PATH="$DAT"
export OUTPUT_PATH="dat/"

Prepare()
{
	echo ' '
	echo Preparing
	mkdir fig $FIG -p
	lscpu >> $LSB_JOBNAME.cpu

}

# End of Preparation
#==============================================================================
# Define Program

Program()
{
	echo ' '
	echo Running computations

	start=`date +%s`
	# -------------------------------------------------------------------------
	# Define the actual test part of the script 
	
	# ==============================================================================
	# Generate all the data needed

	echo "Input and output paths defined by:                                   "
	echo "Input : $INPUT_PATH                                                  "
	echo "Output: $OUTPUT_PATH                                                 "
	echo "                                                                     "
	mkdir -p dat
	# Clean model
	echo "Fetching clean model"
	cp $DAT/bunny.ply dat/bunnyClean.ply
	MODEL="'bunnyClean', "

	echo "====================================================================="
	echo "Commencing tests:                                                    "

	# Test the Gaussian noise
	echo "   Gaussian noise.                                                   "
	export NOISE_TYPE=gaussian
	export NOISE_STRENGTH=1.5
	./GenerateData.exe bunny.ply bunnyGaussian.ply

	MODEL+="'bunnyGaussian', "

	# Test the Outlier noise
	echo "   Outlier addition.                                                 "
	export NOISE_TYPE=outliers
	export OUTLIER_AMOUNT=5.0
	./GenerateData.exe bunny.ply bunnyOutliers.ply

	MODEL+="'bunnyOutliers', "

	# Test combination noise
	echo "   Combined noise and outlier.                                       "
	export NOISE_TYPE=both
	export NOISE_STRENGTH=2.0
	export OUTLIER_AMOUNT=5.0
	./GenerateData.exe bunny.ply bunnyNoise.ply

	MODEL+="'bunnyNoise', "

	# Test transformation
	echo "   Transformation.                                                   "
	export NOISE_TYPE=none
	export ROTATION="0.52,0.52,0.79" # degrees: 30, 30, 45
	export TRANSLATION="0.0,0.0,0.0"
	./GenerateData.exe bunny.ply bunnyTransform.ply

	MODEL+="'bunnyTransform' "

	if [ -s error.err ] ; then
		exit
	fi
	# -------------------------------------------------------------------------
	end=`date +%s`

	runtime=$((end-start))
	echo "Time spent on computations: $runtime"
}

# End of Program
#==============================================================================
# Define Visualize

Visualize()
{
	echo ' '
	echo Visualizing
	matlab -nodesktop -nosplash \
		-r "addpath('$MAT');renderModel({$MODEL},'dat/','fig/');exit;"
}

# End of Visualize
#==============================================================================
# Define Finalize

Finalize()
{
	echo ' '
	echo Finalizing

	mv -ft $FIG fig/*
	rm -fr *.ply *.exe *.sh fig dat

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

echo ' '
echo --------------------------------------------------------------------------

Visualize

echo ' '
echo --------------------------------------------------------------------------

Finalize

echo ' '
echo --------------------------------------------------------------------------
# ==============================   End of File   ==============================

#!/bin/sh 

# --  General options 

# Naming of the job and queue name
#BSUB -J correspondences
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

FIG=../../figures/Correspondences
DAT=../../data
MAT=../../matlab

export INPUT_PATH="dat/"
export OUTPUT_PATH="dat/"

Prepare()
{
	echo ' '
	echo Preparing
	mkdir -p fig $FIG dat
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
	export ALPHA="1.5"
	./Registration.exe bunnyClean.ply bunnyTransform.ply

	if [ -s error.err ] ; then
		echo "Errors have been found. Exiting."
		echo " "
		rm -fr *.ply *.exe *.sh fig dat
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
	matlab -r "addpath('$MAT');animateCorrespondences('Corr','dat/','fig');exit;"
}

# End of Visualize
#==============================================================================
# Define Finalize

Finalize()
{
	echo ' '
	echo Finalizing

	mv -ft $FIG fig/* dat
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

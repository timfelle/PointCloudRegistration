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

#BSUB -R "rusage[mem=10GB]"
#BSUB -M 10GB

# Time specifications (hh:mm)
#BSUB -W 4:00

# -- Notification options

# Set the email to recieve to and when to recieve it
#BSUB -N 		# Send notification at completion

echo --------------------------------------------------------------------------
echo 'Job: '$LSB_JOBNAME', is running on '$LSB_DJOB_NUMPROC' cores.'
echo --------------------------------------------------------------------------
echo LSB: job identifier is $LSB_JOBID
echo LSB: execution queue is $LSB_QUEUE
echo LSB: total number of processors is $LSB_MAX_NUM_PROCESSORS
echo LSB: working directory is $LSB_OUTDIR
echo --------------------------------------------------------------------------

lscpu >> $LSB_JOBNAME.cpu
./$LSB_JOBNAME.sh

# ==============================   End of File   ==============================

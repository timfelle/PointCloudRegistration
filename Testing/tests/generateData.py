'''
runtest.sh TESTNAME [TESTNAME ...]

This script works as a function which run tests for the executables
implementated in the PointCloudRegistration folder of the project.
 
The <TESTNAME> variable refers to the filename of the TESTNAME.sh files
located in the folder tests. These TESTNAME.sh files contain the 
definition of the test which should be run.
'''

# =============================================================================
# Imports
import sys, os, subprocess, shutil
sys.path.append(os.path.realpath('../../python'))
sys.path.append(os.path.realpath('../python'))
from registration 	import Registration
from generatedata 	import GenerateData
from testing		import Testing

# Define common symbols
seperator = '________________________________________________________________\n'

TNAME=os.path.splitext(sys.argv[0])[0]

T = Testing(TNAME); T.Prepare()

print(seperator)
# =========================================================================
# Define the actual test part of the script 

models="'bunnyClean', "

# Test the Gaussian noise
print("   Gaussian noise.")
Gen = GenerateData(
	noise_type='gaussian',
	noise_strength='1.5'
)
Gen.compute('bunnyClean.ply', 'bunnyGaussian.ply')

models+="'bunnyGaussian', "

# Test the Outlier noise
print("   Outlier addition.")
Gen = GenerateData(
	noise_type='outliers',
	outlier_amount='5.0'
)
Gen.compute('bunnyClean.ply', 'bunnyOutliers.ply')

models+="'bunnyOutliers', "

# Test combination noise
print("   Combined noise and outlier.")
Gen = GenerateData(
	noise_type='both',
	noise_strength='1.5',
	outlier_amount='5.0'
)
Gen.compute('bunnyClean.ply', 'bunnyNoise.ply')

models+="'bunnyNoise', "

# Test transformation
print("   Transformation.")
Gen = GenerateData(
	noise_type='none',
	rotation='0.52,0.52,0.79',
	translation='0,0,0'
)
Gen.compute('bunnyClean.ply', 'bunnyTransform.ply')

models+="'bunnyTransform' "

# =============================================================================

print(seperator)
T.Visualise(models); T.Finalize()

# =============================================================================
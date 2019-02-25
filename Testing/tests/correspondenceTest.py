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
sys.path.append(os.path.realpath('../../'))
sys.path.append(os.path.realpath('../'))
from python.registration 	import Registration
from python.generatedata 	import GenerateData
from python.testing		import Testing

# Define common symbols
seperator = '________________________________________________________________\n'

TNAME=os.path.splitext(sys.argv[0])[0]

T = Testing(TNAME)
print(seperator)
# =============================================================================
# Specify the data needed
T.Prepare(['bunnyPartial1.ply','bunnyPartial2.ply'])

GenerateData(translation='0.15,0,0.15').compute( 
	'bunnyPartial2.ply', 'bunnyPartial2.ply' 
)

Registration(export_correspondences='true').compute( 'bunny' )

# =============================================================================

print(seperator)
T.Visualise(['bunny','result']); T.Finalize()

# =============================================================================
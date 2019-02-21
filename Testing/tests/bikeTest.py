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
T.Prepare(['bikePartial1.ply','bikePartial2.ply','bikePartial3.ply'])

GenerateData(rotation="1.6,-1.0,0.0").compute(
	'bikePartial1.ply', 'bikePartial1.ply'
)
GenerateData(rtation='5.6,5,4', translation='30,1,1').compute(
	'bikePartial3.ply', 'bikePartial3.ply'
)
Registration().compute('bike')

# =============================================================================

print(seperator)
T.Visualise("'bike','result'"); T.Finalize()

# =============================================================================
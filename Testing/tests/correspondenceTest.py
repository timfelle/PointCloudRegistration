'''
correspondenceTest.py
	This test uses the Bunny data set. The test attempts to align two parts 
	of the dataset to eachother. The result is figures showing the 
	correspondence pairs before and after registration.
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
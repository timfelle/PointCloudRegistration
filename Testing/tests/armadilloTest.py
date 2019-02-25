'''
armadilloTest.py
	This test uses the Armadillo data set. The test attempts to align two parts 
	of the dataset to eachother. The result is then saved as a figure of before
	and after registration.
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
T.Prepare(['armadilloPartial1.ply','armadilloPartial2.ply'])

GenerateData(rotation="1.6,1.6,0.0").compute(
	'armadilloPartial1.ply', 'armadilloPartial1.ply')
Registration(alpha=0.0).compute('armadillo')

# =============================================================================

print(seperator)
T.Visualise(['armadillo','result']); T.Finalize()

# =============================================================================
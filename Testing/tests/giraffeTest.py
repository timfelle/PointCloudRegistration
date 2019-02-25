'''
giraffeTest.py
	This test uses the Giraffe data set. The test attempts to align two parts 
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
T.Prepare(['giraffePartial1.ply','giraffePartial2.ply'])

GenerateData(rotation='1.6,1.6,0.0').compute(
	'giraffePartial1.ply', 'giraffePartial1.ply')
Registration(alpha=0.5).compute('giraffe')

# =============================================================================

print(seperator)
T.Visualise('giraffe,result'); T.Finalize()

# =============================================================================
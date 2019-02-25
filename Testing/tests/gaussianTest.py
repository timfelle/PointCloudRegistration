'''
gaussianTest.py
	This test uses the Bunny data set. The test attempts to show the impact of 
	gaussian noise for large radii of local neighbourhoods. Results are a set 
	of figures showing the correspondences found for two different radii.
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

GenerateData( rotation="0.52,0.52,0.79", translation="0.05,0.0,-0.01" 
).compute('bunnyPartial2.ply', 'bunnyPartial2.ply')


Gen = GenerateData(noise_type='gaussian', noise_strength=0.2)
Gen.compute('bunnyPartial1.ply','gaussianBunny1.ply')
Gen.compute('bunnyPartial2.ply','gaussianBunny2.ply')

Reg = Registration(
	alpha=1.6, 
	num_r=2, min_r=0.99, max_r=0.1,
	export_correspondences='true'
)
Reg.set_environment('OUTPUT_NAME','bun10'	).compute('bunny')
Reg.set_environment('OUTPUT_NAME','gauss10'	).compute('gaussian')

Reg.set_environment(['MIN_R','MAX_R'],[0.14,0.15])

Reg.set_environment('OUTPUT_NAME','bun15'	).compute('bunny')
Reg.set_environment('OUTPUT_NAME','gauss15'	).compute('gaussian')


# =============================================================================

print(seperator)
T.Visualise(['bun10','bun15','gauss10','gauss15'],type='matlab_corr')
T.Finalize()

# =============================================================================
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

# -----------------------------------------------------------------------------
print('Clean')

Gen = Gen = GenerateData()
Gen.compute('bunnyPartial1.ply', 'bunnyClean.ply')

Gen = Gen = GenerateData(rotation='0.52,0.52,0.79',translation='0.05,0.0,-0.01')
Gen.compute('bunnyPartial2.ply', 'bunnyTransform.ply')
models ='bunny,'

Reg = Registration(
	output_name='resultClean',
	alpha=1.6, 
	min_r=0.0001, 
	max_r=0.01 
)
Reg.compute(['bunnyClean.ply','bunnyTransform.ply'])
models += Reg.output_name + ','

# -----------------------------------------------------------------------------
print('Gaussian')

# 0.01 Gaussian noise
Gen = GenerateData( noise_type='gaussian', noise_strength=0.01 )

Gen.compute('bunnyClean.ply', 'gaussianBunny1.ply')
Gen.compute('bunnyTransform.ply', 'gaussianBunny2.ply')

Reg = Registration(
	output_name='resultGauss1',
	alpha=1.6,
	min_r=0.005,
	max_r=0.1,
	num_r=10
)
Reg.compute(['gaussianBunny1.ply', 'gaussianBunny2.ply'])
models += Reg.output_name + ','

# 0.05 Gaussian noise
Gen = GenerateData( noise_type='gaussian', noise_strength=0.05 )

Gen.compute('bunnyClean.ply', 'gaussianBunny3.ply')
Gen.compute('bunnyTransform.ply', 'gaussianBunny4.ply')

Reg = Registration(
	output_name='resultGauss2' ,
	alpha=1.5,
	min_r=0.001,
	max_r=0.08
)
Reg.compute(['gaussianBunny3.ply', 'gaussianBunny4.ply'])
models += Reg.output_name + ','

# -----------------------------------------------------------------------------
print('Outliers')

# 1% outliers
Gen = GenerateData( noise_type='outliers', outlier_amount=1.0 )

Gen.compute('bunnyClean.ply', 'outlierBunny1.ply' )
Gen.compute('bunnyTransform.ply', 'outlierBunny2.ply' )

Reg = Registration( output_name='resultOut1' )
Reg.compute(['outlierBunny1.ply', 'outlierBunny2.ply' ])
models += Reg.output_name + ','

# 5% outliers
Gen = GenerateData( noise_type='outliers', outlier_amount=5.0 )

Gen.compute('bunnyClean.ply','outlierBunny3.ply' )
Gen.compute('bunnyTransform.ply','outlierBunny4.ply' )

Reg = Registration( output_name='resultOut2' )
Reg.compute(['outlierBunny3.ply','outlierBunny4.ply'])
models += Reg.output_name + ','

# 10% outliers
Gen = GenerateData( noise_type='outliers', outlier_amount=10.0 )

Gen.compute('bunnyClean.ply', 'outlierBunny5.ply' )
Gen.compute('bunnyTransform.ply', 'outlierBunny6.ply' )

Reg = Registration( output_name='resultOut3' )
Reg.compute(['outlierBunny5.ply', 'outlierBunny6.ply' ])
models += Reg.output_name

# =============================================================================

print(seperator)
T.Visualise(models); T.Finalize()

# =============================================================================
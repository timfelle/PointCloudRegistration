'''
generateData.py
	This test uses the Bunny data set. The test produce visual examples of using
	the program "GenerateData.exe". Each of the capabilities of the program are 
	visualised in the exported images.
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

T = Testing(TNAME)
print(seperator)
# =========================================================================
# Specify the data needed
T.Prepare('bunny.ply')

# Define the actual test part of the script 
Gen = GenerateData()
Gen.compute('bunny.ply', 'bunnyClean.ply')
models='bunnyClean,'

# Test the Gaussian noise
print("   Gaussian noise.")
Gen = GenerateData(
	noise_type='gaussian',
	noise_strength='1.5'
)
Gen.compute('bunnyClean.ply', 'bunnyGaussian.ply')

models+='bunnyGaussian,'

# Test the Outlier noise
print("   Outlier addition.")
Gen = GenerateData(
	noise_type='outliers',
	outlier_amount='5.0'
)
Gen.compute('bunnyClean.ply', 'bunnyOutliers.ply')

models+='bunnyOutliers,'

# Test combination noise
print("   Combined noise and outlier.")
Gen = GenerateData(
	noise_type='both',
	noise_strength='1.5',
	outlier_amount='5.0'
)
Gen.compute('bunnyClean.ply', 'bunnyNoise.ply')

models+='bunnyNoise,'

# Test transformation
print("   Transformation.")
Gen = GenerateData(
	noise_type='none',
	rotation='0.52,0.52,0.79',
	translation='0,0,0'
)
Gen.compute('bunnyClean.ply', 'bunnyTransform.ply')

models+='bunnyTransform'

# =============================================================================

print(seperator)
T.Visualise(models); T.Finalize()

# =============================================================================
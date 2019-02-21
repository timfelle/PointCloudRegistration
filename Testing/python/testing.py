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
from registration import Registration
from generatedata import GenerateData

# Define common symbols
seperator = '________________________________________________________________\n'

class Testing:
	def __init__(self,test):
		self.test_name = test
		self.FIG = '../../figures/' + test + '/'
		self.DAT = '../../data/'
		self.MAT = '../../matlab/'
	#==========================================================================
	# Define Preparation of data ect.

	def Prepare(self,data):
		if os.stat('error.err').st_size >= 6: exit()

		# Setup folders needed

		os.makedirs( 'fig' 				, exist_ok=True)
		os.makedirs( 'dat'				, exist_ok=True)

		# Define input and output paths
		self.INPUT_PATH = "dat/"
		self.OUTPUT_PATH = "dat/"

		print("Input and output paths defined by:")
		print('   Input : ' + self.INPUT_PATH)
		print('   Output: ' + self.OUTPUT_PATH)
		print(' ')

		# Fetch the data needed from the data folder

		if not isinstance(data,(list,)):
			data = [data]
		for d in data:
			shutil.copy( self.DAT + d, self.INPUT_PATH )
		
		if os.stat('error.err').st_size >= 6: exit()

#==============================================================================
# Define Visualise

	def Visualise(self,models):
		if os.stat('error.err').st_size >= 6: exit()

		print('Visualising')

		if isinstance(models,str):
			S = subprocess.Popen(
				['matlab','-wait','-nodesktop','-nosplash','-r',
				"addpath('"+self.MAT+"');"+
				"displayRegistration({"+models+"},'dat/','fig/',[],20);exit;"],
				universal_newlines=True)
			S.communicate()

		if os.stat('error.err').st_size >= 6: exit()

#==============================================================================
# Define Finalize

	def Finalize(self):
		if os.stat('error.err').st_size >= 6: exit()
			
		# Prepare the folders
		shutil.rmtree(self.FIG			, ignore_errors=True)
		os.makedirs( self.FIG 			, exist_ok=True)
		os.makedirs( self.FIG + 'data' 	, exist_ok=True)

		# Copy over figures and data
		figs = os.listdir('fig/')
		dats = os.listdir('dat/')
		for f in figs:
			shutil.move('fig/'+f,self.FIG)
		for d in dats:
			shutil.move('dat/'+d,self.FIG+'data/')
		
		# Clean log folder
		shutil.rmtree('fig'				, ignore_errors=True)
		shutil.rmtree('dat'				, ignore_errors=True)
		os.remove('Registration.exe')
		os.remove('GenerateData.exe')
		os.remove(sys.argv[0])

		print("   Figures moved to " + self.FIG )
		print("   Data used located in " + self.FIG + "data")

		if os.stat('error.err').st_size >= 6: exit()

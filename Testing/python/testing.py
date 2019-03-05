'''
testing.ply
	Class designed to handle testing of the PointCloudRegistration system 
	developed here. It is used to Prepare the folders and files needed for 
	testing, call the appropriate visualisation and cleanup all temporary files.
'''

# =============================================================================
# Imports
import sys, os, subprocess, shutil
sys.path.append(os.path.realpath('../../python'))
sys.path.append(os.path.realpath('../python'))
from registration 	import Registration
from generatedata 	import GenerateData
from display 		import display

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

	def Visualise(self,models,type='matlab'):
		if os.stat('error.err').st_size >= 6: exit()

		print('Visualising')
		if type == 'matlab'		:		self._vis_matlab		(models)
		if type == 'matlab_corr': 		self._vis_matlab_corr	(models)
		if type == 'python'		:		self._vis_python		(models)

		if os.stat('error.err').st_size >= 6: exit()

# -----------------------------------------------------------------------------
# Visualisation sub functions
	def _vis_matlab(self,models):
		if isinstance(models,str): models = str.split(models,sep=',')
		mod = ''
		for m in models: mod += "'" + m + "',"
		models = mod[0:-1]

		S = subprocess.Popen(
			['matlab', '-wait', '-nodesktop', '-nosplash', '-r',
			"addpath('"+self.MAT+"');"+
			"displayRegistration({"+models+"},'dat/','fig/',[],20);exit;"],
			universal_newlines=True)
		S.communicate()

	def _vis_matlab_corr(self,models):
		if not isinstance(models,str):
			mod = ''
			for m in models: mod += "'" + m + "',"
			models = mod[0:-1]

		S = subprocess.Popen(
			['matlab', '-wait', '-nodesktop', '-nosplash', '-r',
			"addpath('"+self.MAT+"');"+
			"displayCorrespondences({"+models+"},'dat/','fig/',true);exit;"],
			universal_newlines=True)
		S.communicate()

	def _vis_python(self,models):
		if isinstance(models,str):
			models = str.split(models,sep=',')

		for mod in models: 
			P = display()
			for f in os.listdir('dat/'):
				f = os.path.splitext(f)[0]
				if mod in f:
					P.read_data('dat/'+ f + '.ply')
				
			P.pointcloud()
			P.export(FileName = mod)



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

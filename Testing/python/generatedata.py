'''
generateData.ply
	Class designed to call the GenerateData system developed here. It 
	will open a subprocess and run the program for the inputs defined by the 
	user. Applying specific settings are done through a number of inputs for 
	the initialisation of the class, or by calling the method "set_enviroment".
	The method compute run the computation.
'''

# =============================================================================
# Import definitions
import sys
import subprocess
from os.path import isfile

# =============================================================================

class GenerateData:
	'''Class to controll the usage of GenerateData.exe'''

	# -------------------------------------------------------------------------
	# Initialisation 
	def __init__(self,
			# Path to the executable
			exec_path 		= './',
			# IO definitions
			input_path 		= 'dat/',
			output_path 	= 'dat/',
			output_name 	= '',
			# Transformation Settings
			rotation		= '',
			translation 	= '',
			# Noise Settings'
			noise_type 		= '',
			noise_strength	= '',
			outlier_amount	= ''
		):

		# Initialise self
		self._out = ''
		self._err = ''
		self.exec_path = exec_path

		# Setup the environment in a dictionary
		self.environment = dict()

		# IO definitions
		if input_path: 	self.environment['INPUT_PATH'] 	= str(input_path)
		if output_path:	self.environment['OUTPUT_PATH']	= str(output_path)
		if output_name:	self.environment['OUTPUT_NAME']	= str(output_name)

		# Transformation Settings
		if rotation:	self.environment['ROTATION']	= str(rotation)
		if translation:	self.environment['TRANSLATION']	= str(translation)

		# Noise Settings
		if noise_type:
			self.environment['NOISE_TYPE']		= str(noise_type)
		if noise_strength:
			self.environment['NOISE_STRENGTH']	= str(noise_strength)
		if outlier_amount:
			self.environment['OUTLIER_AMOUNT']	= str(outlier_amount)

	# -------------------------------------------------------------------------
	# Change environment
	def set_exec_path(self,path):
		self.exec_path = path
		return self

	def set_environment(self,key,value):
		if not isinstance(key,(list,)):
			key = [key]; value = [value]
		for i in range(0,len(key)):
			self.environment[key[i]] = str(value[i])
		return self
	# -------------------------------------------------------------------------
	# Compute GenerateData of data
	def compute(self, input_data, output_data):
		self.__check_self__()

		Sub = subprocess.Popen( 
			[ self.__exec__(), input_data, output_data ],
			stdout				= subprocess.PIPE,
			universal_newlines	= True,
			env					= self.environment
		)
		self._out, self._err = Sub.communicate()
		if self._err 	: print( self._err ); exit()
		
		self._computed = True
		return self
	
	# -------------------------------------------------------------------------
	

	# -------------------------------------------------------------------------
	# Utility functions
	def print(self): print( self._out ); return self
	
	# -------------------------------------------------------------------------
	# Private functions

	# Function to return the full name of the GenerateData program
	def __exec__(self) : 
		return self.exec_path + 'GenerateData.exe'
	
	# Corrections and error checks
	def __check_self__(self):

		# Path corrections
		if self.exec_path[-1] != '/': self.exec_path += '/'
		for path in ['INPUT_PATH','OUTPUT_PATH']:
			if self.environment[path][-1] != '/': self.environment[path] += '/'
		
		# Executable existence
		exec = self.exec_path + 'GenerateData.exe'
		if not isfile(exec):
			print("File not found:", exec,file=sys.stderr)
			exit()


# # EOF # #
# =============================================================================
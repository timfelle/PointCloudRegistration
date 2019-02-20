# =============================================================================
# WRITE MY DESCRIPTION

# =============================================================================
# Import definitions
import sys
import subprocess
from os.path import isfile

# =============================================================================

class Registration:
	'''Class to controll the usage of Registration.exe'''

	# -------------------------------------------------------------------------
	# Initialisation 
	def __init__(self,
			# Path to the executable
			exec_path 	= './',
			# IO definitions
			input_path 	= 'dat/',
			output_path = 'dat/',
			output_name = '',
			# Feature settings
			fpfh_version= '',
			min_r 		= '', 
			max_r		= '', 
			num_r		= '',
			# Registration settings
			fgr_version = '',
			tol_e		= '',
			tol_nu		= '',
			alpha		= ''
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

		# Feature settings
		if fpfh_version:self.environment['FPFH_VERSION']= str(fpfh_version)
		if min_r: 		self.environment['MIN_R']		= str(min_r)
		if max_r: 		self.environment['MAX_R']		= str(max_r)
		if num_r: 		self.environment['NUM_R']		= str(num_r)
		
		# Registration settings
		if fgr_version:	self.environment['FGR_VERSION']	= str(fgr_version)
		if tol_e: 		self.environment['TOL_E']		= str(tol_e)
		if tol_nu: 		self.environment['TOL_NU']		= str(tol_nu)
		if alpha: 		self.environment['ALPHA']		= str(alpha)

	# -------------------------------------------------------------------------
	# Change environment
	def set_exec_path(self,path):
		self.exec_path = path

	def set_environment(self,key,value):
		#TODO expand this to handle lists
		self.environment[key] = str(value)

	# -------------------------------------------------------------------------
	# Compute registration of data
	def compute(self, data):
		if not isinstance(data,(list,)):
			data = [data]
		self.environment['INPUT_NAME'] = data[0]
		self.__check_self__()
		cmd = [ self.__exec__() ]

		for d in data:
			cmd.append(d)

		Sub = subprocess.Popen( 
			cmd,
			stdout				= subprocess.PIPE,
			universal_newlines	= True,
			env					= self.environment
		)
		self._out, self._err = Sub.communicate()
		if self._err 	: print( self._err ); exit()
		
		self._computed = True
	
	# -------------------------------------------------------------------------
	

	# -------------------------------------------------------------------------
	# Utility functions
	def print(self): print( self._out )
	
	# -------------------------------------------------------------------------
	# Private functions

	# Function to return the full name of the registration program
	def __exec__(self) : 
		return self.exec_path + 'Registration.exe'
	
	# Corrections and error checks
	def __check_self__(self):

		# Path corrections
		if self.exec_path[-1] != '/': self.exec_path += '/'
		for path in ['INPUT_PATH','OUTPUT_PATH']:
			if self.environment[path][-1] != '/': self.environment[path] += '/'
		
		# Executable existence
		exec = self.exec_path + 'Registration.exe'
		if not isfile(exec):
			print("File not found:", exec,file=sys.stderr)
			exit()


# # EOF # #
# =============================================================================
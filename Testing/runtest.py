'''
runtest.sh TESTNAME [TESTNAME ...]
	This script works as a function which run tests for the executables
	implementated in the PointCloudRegistration folder of the project.
 
	The <TESTNAME> variable refers to the filename of the TESTNAME.py files
	located in the folder tests. These TESTNAME.py files contain the 
	definition of the test which should be run.
'''

# =============================================================================
# Imports
import sys, os, subprocess, shutil

# =============================================================================
# Help command
if len(sys.argv) == 1 or ('-h' in sys.argv[1] or '--help' in sys.argv[1]):
	print(__doc__); exit(True)

# =============================================================================
# Define all needed folders relative to the Testing folder.
EPATH = '../PointCloudRegistration'
DPATH = 'data'
FPATH = 'figures'
LPATH = 'logs'
TPATH = 'tests'

# Define common symbols
seperator = '================================================================\n'

# =============================================================================
# Find all tests if specified
tests = []
if 'all' in sys.argv:
	for test in os.listdir(TPATH):
		tests.append(os.path.splitext(test)[0])
else : 
	for test in sys.argv[1:]:
		if (test+'.py') in os.listdir(TPATH): tests.append(test)

if len(tests) == 0 :
	# Check for test specifications
	error = seperator
	error+= 'ERROR in runtest.sh: (No test)\n'
	error+= '    Please specify which test to run.\n'
	error+= '    Jobs are specified by the filename only.\n'
	error+= '    Possible files can be seen in: "tests/":\n'
	error+= seperator
	print(error,file=sys.stderr); exit(False)

# =============================================================================
# Ensure the excecutables exists
if not ('GenerateData.exe' in os.listdir(EPATH) and 
	'Registration.exe' in os.listdir(EPATH)):
	S = subprocess.Popen(['make'], 
		stdout=subprocess.PIPE, 
		cwd=EPATH,
		universal_newlines=True)
	out = 'Executables not found, attempting make. Output:\n'
	out+= seperator + S.communicate()[0] + seperator
	print(out)

if not 'GenerateData.exe' in os.listdir(EPATH):
	error = seperator
	error+= 'ERROR in runtest.sh: (Missing executable)\n'
	error+= '    GenerateData.exe not found. Aborting tests.\n'
	error+= '    Please attempt a manual compilation.\n'
	error+= seperator
	print(error,file=sys.stderr); exit(False)

if not 'Registration.exe' in os.listdir(EPATH):
	error = seperator
	error+= 'ERROR in runtest.sh: (Missing executable)\n'
	error+= '    Registration.exe not found. Aborting tests.\n'
	error+= '    Please attempt a manual compilation.\n'
	error+= seperator
	print(error,file=sys.stderr); exit(False)

# =============================================================================
# Define files needed by the execution in all tests
EXEC = [ EPATH + '/Registration.exe',EPATH + '/GenerateData.exe']

# Create all needed folders
os.makedirs(DPATH, exist_ok=True)
os.makedirs(FPATH, exist_ok=True)
os.makedirs(LPATH, exist_ok=True)

# =============================================================================
# Start the tests
print( seperator + 'Queueing tests: \n' )
S = []
for test in tests:
	path = LPATH + '/' + test + '/'
	# Create the folder needed
	shutil.rmtree(path,ignore_errors=True)
	os.makedirs(path, exist_ok=True)

	# Copy all files needed
	shutil.copy2(EXEC[0],path + '/Registration.exe')
	shutil.copy2(EXEC[1],path + '/GenerateData.exe')
	shutil.copy2(TPATH + '/' + test + '.py'
		,path + test + '.py')

	# Move to the directory submit the code and return
	with open(path + 'output.out',"wb") as out, \
		open(path + 'error.err',"wb") as err:
		S.append(subprocess.Popen(
			['python3', test + '.py'],
			stdout=out, stderr=err,
			cwd=path,
			universal_newlines=True,
			shell=True))
	print('  {:s}'.format(test))

# =============================================================================
# Ensure tests complete and print errors
index = 0
for s in S:
	s.communicate('exit()')
print( '\nTests finished \n' + seperator ) 

# Print errors for all unfinished tests
for test in tests:
	path = LPATH + '/' + test + '/'
	# If the test did exists and was running
	if os.stat(path + 'error.err').st_size >= 6:
		f = open(path + 'error.err','r')
		print(seperator + test + ' NOT COMPLETED:')
		print(f.read())
		print(seperator)
	

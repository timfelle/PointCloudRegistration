#README for jacobiSolver
----------------------------------------------------------------------------
The registration algorithm is implemented into the registration executable.

Default call to the function will be as bellow, 
	> ./Registration.exe S0 S1 [S2 ...]

where the inputs define names of Point Clouds saved in .ply files.
If no arguments are given, the user will recieve a prompt in the terminal to 
manually specify the file names.

----------------------------------------------------------------------------
The solver will read for several environment variables and change behavior
based on these. The environment variables supported are listed bellow. Variables
can be set either before the program is run or through 'export ENV_NAME=value'.

Extra environment variables: ( > ENV_NAME=value ./Registration.exe ...)
	INPUT_PATH: [default: ../Testing/data/]
		Defines where the input files are located.

	OUTPUT_PATH: [default: ../Testing/data/]
		Defines where the output files should be placed.

	OUTPUT_NAME: [default: result]
		Defines the base name for all output files. Files will be labeled as,
		OUTPUT_NAME_index.ply

% = = EOF = = %
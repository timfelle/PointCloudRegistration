#README for GenerateData program
----------------------------------------------------------------------------
This program is used to generate synthetically modified pointclouds from 
existing models.

Default call to the program will be as bellow, 
	> ./GenerateData.exe Input Output 

where the inputs define names of Point Clouds saved in .ply files.

----------------------------------------------------------------------------
The solver will read for several environment variables and change behavior
based on these. The environment variables supported are listed bellow. Variables
can be set either before the program is run or through 'export ENV_NAME=value'.

Extra environment variables: ( > ENV_NAME=value ./Registration.exe ...)
	INPUT_PATH: 			[default: ../Testing/data/]
		Defines where the input files are located.

	OUTPUT_PATH: 			[default: ../Testing/data/]
		Defines where the output files should be placed.

	OUTPUT_NAME: 			[default: result]
		Defines the base name for all output files. Files will be labeled as,
		OUTPUT_NAME_index.ply
	
	EXPORT_CORRESPONDENCES: [default: false]
		Define if correspondences should be exported as pointclouds for
		visualisation. 
	
	TOL_NU: 				[default: 1e-6]
		Tolerence for penalty variable nu.

	TOL_E: 					[default: 1e-6] 
		Tolerence for average correspondece distance.

	MAX_R: 					[default: 0.010]
		Maximal radius for neighbourhoods used in feature estimation.

	MIN_R: 					[default: 0.005]
		Minimal radius for neighbourhoods used in feature estimation.

	STP_R: 					[default: 1.1]
		Radius stepping size, r_{k+1} = r_k * STP_R.
	
	ALPHA:					[default: 1.96]
		Scale for when to mark a point as unique. Default value corresponds to
		5% of the normal destribution will be unique.

% = = EOF = = %
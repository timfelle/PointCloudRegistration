# README for Registration program
----------------------------------------------------------------------------
The registration algorithm is implemented into the registration executable.

Default call to the function is one of the following,  
	> ./Registration.exe S0 S1 [S2 ...]  
	> ./Registration.exe S_basename  
	> ./Registration.exe  

where the inputs define names of Point Clouds saved in .ply files.

Called with a "S_basename" will search through the input folder and run 
registration on all files which match the basename,  
	> ./Registration.exe pointcloud  
would find all of the files bellow,  
	pointcloud_0.ply, pointcloud_1.ply, pointcloud_2.ply, ...

Called with no input argument the user will be prompted to write the names of
point clouds which should be aligned through the registration.

----------------------------------------------------------------------------
The solver will read for several environment variables and change behavior
based on these. The environment variables supported are listed bellow. Variables
can be set either before the program is run or through 'export ENV_NAME=value'.

Extra environment variables: ( > ENV_NAME=value ./Registration.exe ...)

	INPUT_PATH: 			[default: ../Testing/data/]  
		Defines where the input files are located.  

	OUTPUT_PATH: 			[default: ../Testing/logs/debugging/]  
		Defines where the output files should be placed.  

	OUTPUT_NAME: 			[default: result]  
		Defines the base name for all output files. Files will be labeled as,  
		OUTPUT_NAME_index.ply  
	
	EXPORT_CORRESPONDENCES: [default: false]  
		Define if correspondences should be exported as point clouds for  
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
		Please note: STP_R can be less than 1.0, however it is then required   
		that MAX_R < MIN_R. This will cause the loop to start at a large value   
		and end at a low value. This is useful for emphasising large geometric   
		features.  
	
	ALPHA:					[default: 1.96]  
		Scale for when to mark a point as unique. Default value corresponds to  
		5% of the normal destribution will be unique.  

% = = EOF = = %
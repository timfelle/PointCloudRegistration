# README for GenerateData program
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

	INPUT_PATH:             [default: ../Testing/data/]  
		Defines where the input files are located.

	OUTPUT_PATH:            [default: ../Testing/logs/debugging/]  
		Defines where the output files should be placed.

	TRANSLATION:            [default: "0.0,0.0,0.0"]
		Define the translation which should be applied to the model.

	ROTATION:               [default: "0.0,0.0,0.0"]
		Define the rotation which should be applied to the model. These three  
		numbers correspond to the rotation around the x, y and z axis measured  
		in radians.

	NOISE_TYPE:             [default: none]
		Define Type of noise which should be applied, "gaussian", "outliers"   
		or "both" is supported.
	
	NOISE_STRENGTH:	        [default: 0.0]
		Define the standard deviation of any gaussian noise added to the model.
	
	OUTLIER_AMOUNT:	        [default: 0.0]
		Define the percentage of points which should be outliers in the dataset.

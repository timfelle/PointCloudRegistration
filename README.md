# Point Cloud Registration
Describe project and reasons behind

## Folder structure
The repository contain two folders, 
- PointCloudRegistration
	- 	Contain all files needed for compiling the programs Registration and 
		GenerateData. A visual studio project is included and a readme 
		describing the functionality of the programs in depth.
- Testing
	- 	Containg shell scripts and matlab code used for testing and visualizing
		the results of the program.
[//]: # - Technical report describing the process of developing the code and the 
[//]: # theory the behind problem and method.

### Prerequisites and libraries
In order to compile and run the code the following libraries must be available: 
(the versions specified in paranthesis are the tested versions).
- Eigen  (3.3.5)
- Open3D (0.4.0)

### Installing
Visual Studio 2017 projects are available in the Point Cloud Registration folder 
along with a solution file (.sln). These should be updated to include the 
correct directories for the libraries.

## Running the tests
For direct usage of the program files in the commandline please see the 
readmes located in the PointCloudRegistration folder. These describes the 
functionality in depth.
The test scripts located in Testing/shell is designed to run through the main 
test script runtest.sh. Runtest.sh is designed to setup temporary file locations
and log files for the tests.
Matlab version R2018b is used for testing.

## Authors
* **Tim Felle Olsen** -  [TimFelle](https://github.com/TimFelle)

## Project supervisors
* **J. Andreas Bærentzen**

# Point Cloud Registration
Point cloud registration is the process of aligning 3D point cloud datasets to 
eachother when they contain overlapping regions. This repository is an 
implmentation of such an algorithm which is the main focus for my master thesis.
The thesis is included in the folder as well, describing the implementations and
theoretical derivation of the algorithm.  
Most of the work are based on articles by Qian-Yi Zhou, Jaesik Park and Vladlen 
Koltun, who are the authors of the Open3D library.

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
[//]: #   theory the behind problem and method.

### Prerequisites and libraries
In order to compile and run the code the following libraries must be available: 
(the versions specified in paranthesis are the tested versions).
- Eigen  (3.3.5)
- Open3D (0.4.0)

### Installation
Visual Studio 2017 projects are available in the Point Cloud Registration folder
along with a solution file (.sln). These should be updated to include the 
correct directories for the libraries.
Makefiles are also included for compilation of the programs. Again some
alteration will be required in order to locate the correct libraries.

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

// ============================================================================
// INCLUDES

#include <stdio.h>
#include <iostream>
#include <string>

#include "point_cloud_utility.h"
#include "utility_functions.h"

using namespace std;

// ============================================================================
// MAIN FUNCTION

int main(int argc, char *argv[])
{
	// ------------------------------------------------------------------------
	// Handle input numbers and help.
	if (argc == 1){
		printf(
			"\n./registration.bin S1 S2 [S3 S4 ...]\n"
			"This function accepts the following arguments,\n"
			"	S1,	name of the first surface.\n"
			"	S2,	name of the second surface.\n"
			"	S3,	[Optional] name of the third surface.\n"
			"See README for additional information.\n"
		);
		return EXIT_SUCCESS;
	}
	else if (argc < 3) cerr << "Not enough input arguments." << endl;

	// ------------------------------------------------------------------------
	// Handle Environment variables
	const char* output_path, *input_path;
	if ( (input_path = getenv("INPUT_PATH")) == NULL )
		input_path = "data/";
	if ( (output_path = getenv("OUTPUT_PATH")) == NULL )
		output_path = "data/";

	
	// ------------------------------------------------------------------------
	// Read inputs and organize data names
	int nSurfaces = argc-1;
	vector<string> dataName;
	int nErrors = 0;
	for (int i = 0; i < nSurfaces; i++){
		
		// Read the input path and the name of the file.
		dataName.push_back(string(input_path) + string(argv[i+1]));

		// Ensure files have the correct 
		if ( ( dataName[i].find(".") ) == string::npos )
			dataName[i] = dataName[i] + string(".ply");

		if( dataName[i].find(".ply")  == string::npos ){
			cerr << "\nError in input " << i+1 << ": " << dataName[i] << endl;
			cerr << "   Incorrect file extension." << endl;
			nErrors++;
		}
		// Ensure the files exist
		else if ( !is_file_exist( dataName[i] )){
			cerr << "\nError in input " << i+1 << ": " << dataName[i] << endl;
			cerr << "   File not found." << endl;
			nErrors++;
		}
	}
	if (nErrors > 0) return EXIT_FAILURE;
	// ------------------------------------------------------------------------
	// Load the datafiles
	vector<PLYModel> model;
	for (int i = 0; i < nSurfaces; i++)
		model.push_back(PLYModel( dataName[i].c_str(), false, false ));
	
	// ------------------------------------------------------------------------
	// Compute normals
	for (int i = 0; i<nSurfaces; i++)
		computePointCloudNormals( &model[i] );
	
	// ------------------------------------------------------------------------
	// Compute surface registration

	// ------------------------------------------------------------------------
	// Save the results
	vector<string> resultName;
	for (int i = 0; i < nSurfaces; i++){
		resultName.push_back(string("result") + dataName[i]);
		model[i].PLYWrite( resultName[i].c_str(), false, false);
	}

	// ------------------------------------------------------------------------
	// Cleanup and delete variables
	
	return EXIT_SUCCESS;
}

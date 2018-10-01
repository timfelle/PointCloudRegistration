// ============================================================================
// INCLUDES

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>
#include <cstring>

#include "point_cloud_utility.h"
#include "utility_functions.h"
#include "plyloader.h"

using namespace std;

// ============================================================================
// MAIN FUNCTION

inline bool is_file_exist(string fileName)
{
    return (bool)std::ifstream(fileName);
}

int main(int argc, char *argv[])
{
	// ------------------------------------------------------------------------
	// Handle input numbers and help.
	if (argc == 1){
		printf(
		"INSERT HELP TEXT HERE \n");
		return EXIT_SUCCESS;
	}
	else if (argc < 3) cerr << "Not enough input arguments" << endl;

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
	string dataName[nSurfaces];
	int nErrors = 0;
	for (int i = 0; i < nSurfaces; i++){
		
		// Read the input path and the name of the file.
		dataName[i] = string(input_path) + string(argv[i+1]);

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
	PLYModel model[nSurfaces];
	for (int i = 0; i < nSurfaces; i++)
		model[i] = PLYModel( dataName[i].c_str(), false, false );
	
	// ------------------------------------------------------------------------
	// Compute normals
	for (int i = 0; i<nSurfaces; i++)
		computePointCloudNormals( &model[i] );
	
	// ------------------------------------------------------------------------
	// Compute surface registration

	// ------------------------------------------------------------------------
	// Save the results
	string resultName[nSurfaces];
	for (int i = 0; i < nSurfaces; i++){
		resultName[0] = string(output_path) + string("result") + dataName[0];
		model[0].PLYWrite( resultName[0].c_str(), false, false);
	}

	// ------------------------------------------------------------------------
	// Cleanup and delete variables
	
	return EXIT_SUCCESS;
}

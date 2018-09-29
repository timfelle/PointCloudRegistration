// ============================================================================
// INCLUDES

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>

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
	// Handle input and help.
	if (argc == 1){
		printf(
		"INSERT HELP TEXT HERE \n");
		return EXIT_SUCCESS;
	}
	else if (argc < 3) cerr << "Not enough input arguments" << endl;

	int nSurfaces = argc-1;
	char *dataName[nSurfaces];
	int nErrors = 0;
	for (int i = 0; i < nSurfaces; i++){
		dataName[i] = argv[i+1];
		if ( ( (string)dataName[i] ).find(".ply") == string::npos ){
			cerr << "Error in input " << i+1 << ": " << dataName[i] << endl;
			cerr << "   Unsupported file type." << endl;
			nErrors++;
		}
		else if ( !is_file_exist(dataName[i]) ){
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
		model[i] = PLYModel( dataName[i], false, false );
	
	// ------------------------------------------------------------------------
	// Compute normals

	// ------------------------------------------------------------------------
	// Compute surface registration


	// ------------------------------------------------------------------------
	// Save the results
	const char *resultName[nSurfaces];
	resultName[0] = "Result_1.ply";
	resultName[1] = "Result_2.ply";

	model[0].PLYWrite( resultName[0], false, false);
	model[1].PLYWrite( resultName[1], false, false);

	// ------------------------------------------------------------------------
	// Cleanup and delete variables
	
	return EXIT_SUCCESS;
}

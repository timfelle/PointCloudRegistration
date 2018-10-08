// ============================================================================
// INCLUDES

#include <stdio.h>
#include <iostream>
#include <string>
#include <glm/glm.hpp>

#include "point_cloud_utility.h"
#include "utility_functions.h"

using namespace std;
using namespace glm;

// ============================================================================
// MAIN FUNCTION

int main(int argc, char *argv[])
{
	// ------------------------------------------------------------------------
	// Handle input numbers and help.
	if (argc == 1){
		printf(
			"\n./generateData.bin S1\n"
			"This function accepts the following arguments,\n"
			"	S1,	name of the surface which should be altered.\n"
			"The surface is altered based on the environment variables set,\n"
			"	NOISE_TYPE		=[none,gaussian,salt]\n"
			"	NOISE_STRENGTH	=float\n"
			"\nSee README for additional information.\n"
		);
		return EXIT_SUCCESS;
	}
	else if (argc < 2) cerr << "Not enough input arguments." << endl;

	// ------------------------------------------------------------------------
	// Handle Environment variables
	const char *output_path, *input_path, *noise_type, *noise_strength;
	const char *rotation, *translation;
	if ( (input_path = getenv("INPUT_PATH")) == NULL )
		input_path = "../data/";
	if ( (output_path = getenv("OUTPUT_PATH")) == NULL )
		output_path = "../data/";
	if ( (noise_type = getenv("NOISE_TYPE")) == NULL )
		noise_type = "none";
	if ( (noise_strength = getenv("NOISE_STRENGTH")) == NULL )
		noise_strength = "0.0";
	if ( (rotation = getenv("ROTATION")) == NULL )
		rotation = "4.0,2.0,1.0";
	if ( (translation = getenv("TRANSLATION")) == NULL )
		translation = "0.0,0.0,1.0";
		

	
	
	// ------------------------------------------------------------------------
	// Read inputs and organize data names
	int nErrors = 0;

	// Read the input path and the name of the file.
	string dataName = string(argv[1]);
	string inputName = string(input_path) + dataName;

	// Ensure files have the correct 
	if ( ( dataName.find(".") ) == string::npos )
	{
		dataName  += string(".ply");
		inputName += string(".ply");
	}
		

	if( dataName.find(".ply")  == string::npos ){
		cerr << "\nError in input " << ": " << dataName << endl;
		cerr << "   Incorrect file extension." << endl;
		nErrors++;
	}
	// Ensure the files exist
	else if ( !is_file_exist( inputName )){
		cerr << "\nError in input : " << inputName << endl;
		cerr << "   File not found." << endl;
		nErrors++;
	}

	if (nErrors > 0) return EXIT_FAILURE;
	
	// ------------------------------------------------------------------------
	// Load the datafiles
	PLYModel model = PLYModel( inputName.c_str(), false, false );
	
	// ------------------------------------------------------------------------
	// Apply noise

	//applyNoise(&model, string(noise_type), atof(noise_strength));

	// ------------------------------------------------------------------------
	// Transform model
	vector<double> rot, trans;
	mat4 T;
	charToVec(rotation, rot);
	charToVec(translation, trans);
	transformationMatrix(T,rot,trans);
	transformModel(&model, T);

	
	// ------------------------------------------------------------------------
	// Save the results
	
	string outputName = string(output_path) + string("modified") + dataName;
	model.PLYWrite( outputName.c_str(), false, false);

	// ------------------------------------------------------------------------
	// Cleanup and delete variables
	
	return EXIT_SUCCESS;
}

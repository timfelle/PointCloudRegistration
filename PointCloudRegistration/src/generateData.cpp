// ============================================================================
// INCLUDES

#include <stdio.h>
#include <stdlib.h>
#include <cstdlib>
#include <iostream>
#include <string>

#include <Open3D/Core/Core.h>	// Open3D 
#include <Open3D/IO/IO.h>		// Open3D 
#include <Eigen/Dense>

#include "point_cloud_utility.h"
#include "utility_functions.h"

#if _cpluplus <= 201703L
#define PUTENV _putenv
#else
#define PUTENV _putenv
#endif

using namespace std;
using namespace open3d;
using namespace Eigen;

// ============================================================================
// MAIN FUNCTION

int main(int argc, char *argv[])
{
	// ------------------------------------------------------------------------
	// Handle input numbers and help.
	if ((argc > 1) && (string(argv[1]).compare("-h") == 0)) {
		printf(
			"\n./generateData.bin S1\n"
			"This function accepts the following arguments,\n"
			"	S1,	name of the surface which should be altered.\n"
			"The surface is altered based on the environment variables set,\n"
			"	NOISE_TYPE		=[none,gaussian,outlier]\n"
			"	NOISE_STRENGTH	=float\n"
			"   ROTATION        =pitch,yaw,roll\n"
			"   TRANSLATION     =x,y,z\n"
			"\nSee README for additional information.\n"
		);
		return EXIT_SUCCESS;
	}
	
	// ------------------------------------------------------------------------
	// Handle Environment variables
	const char *output_path, *input_path;
	const char *noise_type, *noise_strength, *outlier_amount;
	const char *rotation, *translation;

	// Path variables
	if ((input_path		= getenv("INPUT_PATH"))		== NULL)
		input_path		= "../Testing/data/";
	if ((output_path	= getenv("OUTPUT_PATH"))	== NULL)
		output_path		= "../Testing/logs/debugging/";

	// Transformation variables
	if ((rotation		= getenv("ROTATION"))		== NULL)
		rotation		= "0.0,0.0,0.0";
	if ((translation	= getenv("TRANSLATION"))	== NULL)
		translation		= "0.0,0.0,0.0";

	// Noise variables
	if ((noise_type = getenv("NOISE_TYPE")) == NULL)
		PUTENV("NOISE_TYPE=none");
	if ((noise_strength = getenv("NOISE_STRENGTH")) == NULL)
		PUTENV("NOISE_STRENGTH=0.0");
	if ((outlier_amount = getenv("OUTLIER_AMOUNT")) == NULL)
		PUTENV("OUTLIER_AMOUNT=0.0");

	// ------------------------------------------------------------------------
	// Read inputs and organize data names
	string inputName, outputName;
	int nSurfaces = 0;

	// Read the input from terminal.
	if (argc >= 2)
	{
		int nErrors = 0;
		inputName = string(input_path) + string(argv[1]);

		// Ensure file name have the correct extension
		if (inputName.find(".ply") != (inputName.size() - 4)) {
			cerr << "\nERROR: Input 1: " << inputName << endl;
			cerr << "   Incorrect file extension." << endl;
			nErrors++;
		}
		// Ensure the files exist
		else if (!is_file_exist(inputName)) {
			cerr << "\nERROR: Input 1: " << inputName << endl;
			cerr << "   File not found." << endl;
			cerr << "   " << inputName << endl;
			nErrors++;
		}
		if (nErrors != 0) inputName = string("");
	}
	if (argc == 3)
	{
		int nErrors = 0;
		outputName = string(output_path) + string(argv[2]);

		// Ensure file name have the correct extension
		if (outputName.find(".ply") != (outputName.size() - 4)) {
			cerr << "\nERROR: Input 2: " << outputName << endl;
			cerr << "   Incorrect file extension." << endl;
			nErrors++;
		}
		if (nErrors != 0) outputName = string("");
	}

	// If input arguments is missing or invalid.
	if (inputName.empty() || inputName.size() == 0 || 
		outputName.empty() || outputName.size() == 0) 
	{
		cout << "File names are missing, please specify filenames bellow. " 
			<< "Enter \"q\" to exit." << endl; 
	}
	// Prompt user for missing filenames.
	while (inputName.empty() || inputName.size() == 0 || 
		outputName.empty() || outputName.size() == 0)
	{
		if ( inputName.empty() || inputName.size() == 0 )
			cout << "Input file: ";
		else if ( outputName.empty() || outputName.size())
			cout << "Output file: ";

		string char_input;
		cin >> char_input;

		// Exit if the input is q
		if ( string(char_input).compare("q") == 0 )
			return EXIT_SUCCESS;

		if (inputName.empty() || inputName.size() == 0)
		{
			inputName = string(input_path) + char_input;

			int nErrors = 0;
			// Ensure files have the correct extension
			if (inputName.find(".ply") != (inputName.size() - 4)) {
				cerr << "\nERROR: Input 1: " << inputName << endl;
				cerr << "   Incorrect file extension." << endl;
				nErrors++;
			}
			// Ensure the files exist
			else if (!is_file_exist(string(input_path) + inputName)) {
				cerr << "\nError in input " << ": " << char_input << endl;
				cerr << "   File not found." << endl;
				cerr << "   " << inputName << endl;
				nErrors++;
			}
			if (nErrors != 0) inputName = string("");
		}
		else if (outputName.empty() || outputName.size() == 0)
		{
			outputName = string(output_path) + char_input;

			int nErrors = 0;
			// Ensure files have the correct extension
			if (outputName.find(".ply") != (outputName.size() - 4)) {
				cerr << "\nERROR: Input 2: " << outputName << endl;
				cerr << "   Incorrect file extension." << endl;
				nErrors++;
			}
			if (nErrors != 0) outputName = string("");
		}
	}

	if (inputName.size() == 0 || outputName.size() == 0) {
		cerr << "\nERROR: Must have both input and ouput names specified.";
		cerr << endl;
		return EXIT_FAILURE;
	}

	// ------------------------------------------------------------------------
	// Load the datafiles
	SetVerbosityLevel(VerbosityLevel::VerboseError);
	PointCloud model;
	ReadPointCloud(inputName, model);
	
	// ------------------------------------------------------------------------
	// Apply noise

	applyNoise(&model);

	// ------------------------------------------------------------------------
	// Transform model
	Vector3d rot, trans;
	
	charToVec(rotation, rot);
	charToVec(translation, trans);
	Matrix4d T;
	T = transformationMatrix(rot, trans);
	model.Transform(T);

	
	// ------------------------------------------------------------------------
	// Save the results
	WritePointCloud( outputName, model);
	if (( rot.norm() + trans.norm()) >= 1e-6 )
		cout << "Transformation:\n" << T << endl;
	cout << "Data generated:" << endl << "  ";
	cout << inputName << " >> " << outputName << endl;

	// ------------------------------------------------------------------------
	// Cleanup and delete variables
	
	return EXIT_SUCCESS;
}

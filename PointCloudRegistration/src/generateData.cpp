// ============================================================================
// INCLUDES

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>

#include <Open3D/Core/Core.h>	// Open3D 
#include <Open3D/IO/IO.h>		// Open3D 
#include <Eigen/Dense>

#include "point_cloud_utility.h"
#include "utility_functions.h"

#if __cplusplus > 201402L
#define PUTENV putenv
#else
#define PUTENV _putenv
#endif

#define __FILE_NAME__ "generateData"

using namespace std;
using namespace open3d;
using namespace Eigen;

// ============================================================================
// MAIN FUNCTION

int main(int argc, char *argv[])
{
	// ------------------------------------------------------------------------
	// Handle input numbers and help.
	if ((argc != 3) && (string(argv[1]).compare("-h") == 0)) {
		printf(
			"\n./generateData.bin S1\n"
			"This function accepts the following arguments,\n"
			"	S1,	name of the surface which should be altered.\n"
			"The surface is altered based on the environment variables set,\n"
			"	NOISE_TYPE		=[none,gaussian,outliers]\n"
			"	NOISE_STRENGTH	=float\n"
			"	OUTLIER_AMOUNT	=float\n"
			"   ROTATION        =pitch,yaw,roll\n"
			"   TRANSLATION     =x,y,z\n"
			"\nSee README_gen for additional information.\n"
		);
		return EXIT_SUCCESS;
	}

	// ------------------------------------------------------------------------
	// Handle Environment variables
	const char *output_path, *input_path;
	const char *noise_type, *noise_strength, *outlier_amount;
	const char *rotation, *translation;

	// Path variables
	if ((input_path = getenv("INPUT_PATH")) == NULL)
		input_path = "../Testing/data/";
	if ((output_path = getenv("OUTPUT_PATH")) == NULL)
		output_path = "../Testing/logs/debugging/";

	// Transformation variables
	if ((rotation = getenv("ROTATION")) == NULL)
		rotation = "0.0,0.0,0.0";
	if ((translation = getenv("TRANSLATION")) == NULL)
		translation = "0.0,0.0,0.0";

	// Noise variables
	if ((noise_type = getenv("NOISE_TYPE")) == NULL)
		PUTENV("NOISE_TYPE=none");
	if ((noise_strength = getenv("NOISE_STRENGTH")) == NULL)
		PUTENV("NOISE_STRENGTH=0.0");
	if ((outlier_amount = getenv("OUTLIER_AMOUNT")) == NULL)
		PUTENV("OUTLIER_AMOUNT=0.0");

	// ------------------------------------------------------------------------
	// Read inputs and organize data names
	vector<string> dataName = { string(argv[1]), string(argv[2]) };
	bool fileNameStatus = checkFileName(string(input_path) + dataName[0]);
	if (dataName.size() != 2 || !fileNameStatus)
	{
		cerr << __FILE_NAME__ << ":" << __func__ << ":" << __LINE__ << endl;
		cerr << "   Inputs not loaded correctly." << endl;
		return EXIT_FAILURE;
	}
	SetVerbosityLevel(VerbosityLevel::VerboseError);
	// ------------------------------------------------------------------------
	// Load the datafiles
	PointCloud model;
	bool readStatus = ReadPointCloud(input_path + dataName[0], model);
	if (!readStatus)
	{
		cerr << __FILE_NAME__ << ":" << __func__ << ":" << __LINE__ << endl;
		cerr << "   Error in point cloud read." << endl;
	}
	// ------------------------------------------------------------------------
	// Apply noise
	applyNoise(model);

	// ------------------------------------------------------------------------
	// Transform model
	Vector3d rot, trans;
	charToVec(rotation, rot);
	charToVec(translation, trans);
	Matrix4d T;
	T = transformationMatrix(rot, trans);
	model.Transform(T);
	if (model.points_.size() == NULL)
	{
		cerr << __FILE_NAME__ << ":" << __func__ << ":" << __LINE__ << endl;
		cerr << "   Error when transforming model" << endl;
		return EXIT_FAILURE;
	}
	// ------------------------------------------------------------------------
	// Save the results
	bool status = true;
	status = WritePointCloud(string(output_path) + dataName[1], model);
	if (status)
	{
		cout << "Data generated:" << endl << "  ";
		cout << dataName[0] << " >> " << dataName[1] << endl;

		if ((rot.norm() + trans.norm()) >= 1e-6)
			cout << "  Transformation:\n" << T << endl;
		if ((getenv("NOISE_TYPE") != NULL) && (
			(string(getenv("NOISE_TYPE")).find("outliers") != string::npos) ||
			(string(getenv("NOISE_TYPE")).find("both") != string::npos))
			)
			cout << "  Outliers: " << outlier_amount << endl;
		if ((getenv("NOISE_TYPE") != NULL) && (
			(string(getenv("NOISE_TYPE")).find("gaussian") != string::npos) ||
			(string(getenv("NOISE_TYPE")).find("both") != string::npos))
			)
			cout << "  Gaussian: " << noise_strength << endl;
		cout << endl;
	}
	else
	{
		cerr << __FILE_NAME__ << ":" << __func__ << ":" << __LINE__ << endl;
		cerr << "   Error when writting pointcloud: " << dataName[1] << endl;
		return EXIT_FAILURE;
	}

	// ------------------------------------------------------------------------
	// Cleanup and delete variables

	return EXIT_SUCCESS;
}

// ============================================================================
// INCLUDES

#include <stdio.h>
#include <string>
#include <iostream>
#include <exception>

#include <Eigen/Dense>
#include <Open3D/Core/Core.h>
#include <Open3D/IO/IO.h>

#include "point_cloud_utility.h"
#include "utility_functions.h"
#include "fast_point_feature_histograms.h"
#include "fast_global_registration.h"


using namespace std;
using namespace Eigen;
using namespace open3d;

// ============================================================================
// MAIN FUNCTION

int main(int argc, char *argv[])
{
	// ------------------------------------------------------------------------
	// Handle input numbers and help.
	if (argc == 2 && (
		string(argv[1]).compare("-h") == 0 ||
		string(argv[1]).compare("--help") == 0)) {
		printf(
			"\n./Registration.exe S1 S2 [S3 S4 ...]\n"
			"This function accepts the following arguments,\n"
			"	S1,	name of the first surface.\n"
			"	S2,	name of the second surface.\n"
			"	S3,	[Optional] name of the third surface.\n"
			"If no arguments are passed the program will\n"
			"prompt the user for inputs.\n"
			"See README for additional information.\n"
		);
		return EXIT_SUCCESS;
	}
	// ------------------------------------------------------------------------
	// Handle Environment variables
	const char* output_path, *input_path, *output_name;
	bool export_corr = true;

	// Path variables
	if ((input_path = getenv("INPUT_PATH")) == NULL)
		input_path = "../Testing/data/";
	if ((output_path = getenv("OUTPUT_PATH")) == NULL)
		output_path = "../Testing/logs/debugging/";

	// Export functions
	if ((output_name = getenv("OUTPUT_NAME")) == NULL)
		output_name = "result";
	if (getenv("EXPORT_CORRESPONDENCES") == NULL)
		export_corr = true;

	// Tolerences
	if (getenv("TOL_NU") == NULL) _putenv("TOL_NU=1e-6");
	if (getenv("TOL_E" ) == NULL) _putenv("TOL_E=1e-6" );

	// Radius scaling
	if (getenv("MAX_R") == NULL) _putenv("MAX_R=0.050");
	if (getenv("MIN_R") == NULL) _putenv("MIN_R=0.001");
	if (getenv("STP_R") == NULL) _putenv("STP_R=1.100");

	// STD fraction
	if (getenv("ALPHA") == NULL) _putenv("ALPHA=1.5");

	// ------------------------------------------------------------------------
	// Read inputs and organize data names
	vector<string> dataName = readInputFiles(argc, argv, input_path);

	if (dataName.size() < 2)
	{
		cerr << "Inputs not loaded correctly." << endl;
		return EXIT_FAILURE;
	}

	// ------------------------------------------------------------------------
	// Load the datafiles
	size_t nSurfaces = dataName.size();
	vector<PointCloud> model(nSurfaces);
	cout << "Reading data from: " << endl;
	for (int i = 0; i < nSurfaces; i++)
	{
		cout << dataName[i] << endl;
		ReadPointCloud(dataName[i], model[i]);
	}

	// ------------------------------------------------------------------------
	// Compute normals
	for (int i = 0; i < nSurfaces; i++)
		EstimateNormals(model[i]);
	// ------------------------------------------------------------------------
	// Estimate Fast Point Feature Histograms and Correspondances.

	vector<Vector2i> K;
	K = computeCorrespondancePair(model[0], model[1]);

	if (export_corr)
	{
		PointCloud correspondence_0, correspondence_1;
		for (int i = 0; i < K.size(); i++)
		{
			correspondence_0.points_.push_back(model[0].points_[K[i](0)]);
			correspondence_1.points_.push_back(model[1].points_[K[i](1)]);
		}
		WritePointCloud(string(output_path) + string("Corr_0.ply"), correspondence_0);
		WritePointCloud(string(output_path) + string("Corr_1.ply"), correspondence_1);
	}


	// ------------------------------------------------------------------------
	// Compute surface registration
	Matrix4d T;
	T = fastGlobalRegistrationPair(K, model[0], model[1]);
	model[1].Transform(T);

	if (export_corr)
	{
		PointCloud correspondence_0, correspondence_1;
		for (int i = 0; i < K.size(); i++)
		{
			correspondence_0.points_.push_back(model[0].points_[K[i](0)]);
			correspondence_1.points_.push_back(model[1].points_[K[i](1)]);
		}
		WritePointCloud(string(output_path) + string("CorrT_0.ply"), correspondence_0);
		WritePointCloud(string(output_path) + string("CorrT_1.ply"), correspondence_1);
	}

	// ------------------------------------------------------------------------
	// Save the results
	cout << "Result complete, exporting surfaces:" << endl;
	string resultName;
	for (int i = 0; i < nSurfaces; i++) {
		resultName = string(output_path) + string(output_name) + string("_")
			+ to_string(i) + string(".ply");
		cout << endl << dataName[i] << " >> " << resultName << endl;
		WritePointCloud(resultName, model[i]);
	}

	// ------------------------------------------------------------------------
	// Cleanup and delete variables

	return EXIT_SUCCESS;
}


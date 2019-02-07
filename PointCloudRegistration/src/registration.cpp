// ============================================================================
// INCLUDES

#include <stdio.h>
#include <stdlib.h>
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

#if __cplusplus > 201402L
#define PUTENV putenv
#else
#define PUTENV _putenv
#endif

#define __FILE_NAME__  "registration"

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
	const char *output_path, *input_path, *output_name;
	bool export_corr = true;

	// Path variables
	if ((input_path = getenv("INPUT_PATH")) == NULL)
		input_path = "../Testing/data/";
	if ((output_path = getenv("OUTPUT_PATH")) == NULL)
		output_path = "../Testing/logs/debugging/";

	// Export functions
	if ((output_name = getenv("OUTPUT_NAME")) == NULL) {
		output_name = "result";
		PUTENV("OUTPUT_NAME=result");
	}
	if (getenv("EXPORT_CORRESPONDENCES") == NULL)
		PUTENV("EXPORT_CORRESPONDENCES=false");

	// Implementation versions
	if (getenv("FPFH_VERSION") == NULL)
		PUTENV("FPFH_VERSION=project");
	if (getenv("FGR_VERSION") == NULL)
		PUTENV("FGR_VERSION=project");

	// Tolerences
	if (getenv("TOL_NU") == NULL) PUTENV("TOL_NU=1e-6");
	if (getenv("TOL_E") == NULL) PUTENV("TOL_E=1e-6");

	// Radius scaling
	if (getenv("INI_R") == NULL) PUTENV("INI_R=0.0001");
	if (getenv("END_R") == NULL) PUTENV("END_R=0.0100");
	if (getenv("NUM_R") == NULL) PUTENV("NUM_R=100");

	// STD fraction
	if (getenv("ALPHA") == NULL) PUTENV("ALPHA=1.5");

	// FGR Settings
	if (getenv("FGR_MAXITER") == NULL)
		PUTENV("FGR_MAXITER=1e3");

	// ------------------------------------------------------------------------
	// Read inputs and organize data names
	vector<string> dataName = readInputFiles(argc, argv, input_path);
	if (dataName.size() < 2)
	{
		cerr << "Error in registration: " << endl;
		cerr << "   ./Registration ";
		for (int i = 1; i < argc; i++)
			cerr << argv[i] << " ";
		cerr << "\n   No pointclouds found." << endl;
		return EXIT_FAILURE;
	}
	cout << "surfaces loaded:" << endl;
	for (int i = 0; i < dataName.size(); i++)
		cout << "  " << i << ": " << dataName[i] << endl;
	cout << endl;
	SetVerbosityLevel(VerbosityLevel::VerboseError);
	// ------------------------------------------------------------------------
	// Load the datafiles
	size_t nSurfaces = dataName.size();
	vector<PointCloud> model(nSurfaces);
	for (int s = 0; s < nSurfaces; s++)
		ReadPointCloud(dataName[s], model[s]);

	for (int s = 0; s < nSurfaces; s++) {
		if (!model[s].HasNormals())
		{
			EstimateNormals(model[s]);
			model[s].NormalizeNormals();
		}
	}

	// ------------------------------------------------------------------------
	// Compute correspondences
	vector<vector<Vector2i>> K(nSurfaces-1);
	string fgr_version = string(getenv("FGR_VERSION"));
	if ( fgr_version.compare("project")==0 )
		K = computeCorrespondences(model);
	if (K.size() == 0) return EXIT_FAILURE;
	fastGlobalRegistration(model, K);

	// ------------------------------------------------------------------------
	// Save the results
	cout << endl << "Result complete, exporting surfaces:" << endl;
	string resultName;
	for (int i = 0; i < nSurfaces; i++) {
		resultName = string(output_path) + string(output_name) + string("_")
			+ to_string(i) + string(".ply");
		cout << "   " << resultName << " << " << dataName[i] << endl;
		WritePointCloud(resultName, model[i]);
	}

	// ------------------------------------------------------------------------
	// Cleanup and delete variables

	return EXIT_SUCCESS;
}


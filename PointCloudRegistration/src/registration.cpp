// ============================================================================
// INCLUDES

#include <stdio.h>
#include <iostream>
#include <string>

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
		string(argv[1]).compare("--help") == 0) ) {
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
	if ((input_path = getenv("INPUT_PATH")) == NULL)
		input_path = "../Testing/data/";
	if ((output_path = getenv("OUTPUT_PATH")) == NULL)
		output_path = "../Testing/data/";
	if ((output_name = getenv("OUTPUT_NAME")) == NULL)
		output_name = "result";

	// ------------------------------------------------------------------------
	// Read inputs and organize data names
	vector<string> dataName;
	
	// Read the input from terminal.
	if (argc >= 3)
	{
		for (int i = 0; i < argc - 1; i++)
		{
			int nErrors = 0;
			string input = string(argv[i + 1]);

			// Ensure file name have the correct extension
			if (input.find(".ply") != (input.size() - 4)) {
				cerr << "\nERROR in input " << i << ":";
				cerr << "   " << input << endl;
				cerr << "   Unknown file extension." << endl;
				nErrors++;
			}
			// Ensure the files exist
			else if (!is_file_exist(input_path + input)) {
				cerr << "\nERROR in input " << i << ":" << endl;
				cerr << "   " << input_path << input << endl;
				cerr << "   File not found." << endl;
				nErrors++;
			}
			if (nErrors != 0) return EXIT_FAILURE;
			else dataName.push_back(input_path + input);
		}
	}
	// Read the name base of the terminal.
	else if (argc == 2)
	{
		cerr << "Single input specifying base name not implemented yet." << endl;
		return EXIT_FAILURE;
	}
	// Prompt user for surfaces to register.
	else
	{
		string input;
		cout << "Please specify names of the desired surfaces." << endl;
		cout << "Quit: q, Completed inputs: done." << endl;
		cout << "Current folder: " << input_path << endl;
		cout << "Surface 0: ";
		cin >> input;
		while (input.compare("done") != 0 && input.compare("q") != 0)
		{
			int nErrors = 0;
			// Ensure file name have the correct extension
			if (input.find(".ply") != (input.size() - 4)) {
				cerr << "\nERROR in input:";
				cerr << "   " << input << endl;
				cerr << "   Unknown file extension." << endl;
				nErrors++;
			}
			// Ensure the files exist
			else if (!is_file_exist(input_path + input)) {
				cerr << "\nERROR in input:" << endl;
				cerr << "   " << input_path << input << endl;
				cerr << "   File not found." << endl;
				nErrors++;
			}
			if (nErrors == 0) dataName.push_back(input_path + input);
			cout << "Surface " << dataName.size() << ": ";
			cin >> input;
		}
		if (input.compare("q") == 0) return EXIT_FAILURE;
	}
	if (dataName.size() < 2)
	{
		cerr << "Inputs not loaded correctly." << endl;
		return EXIT_FAILURE;
	}
	
	// ------------------------------------------------------------------------
	// Load the datafiles
	size_t nSurfaces = dataName.size();
	vector<PointCloud> model(nSurfaces);
	for (int i = 0; i < nSurfaces; i++)
	{
		cout << "Reading data from: " << dataName[i] << endl;
		ReadPointCloud(dataName[i], model[i]);
		cout << endl;
	}
	
	// ------------------------------------------------------------------------
	// Compute normals
	for (int i = 0; i < nSurfaces; i++)
		EstimateNormals(model[i]);
	
	// ------------------------------------------------------------------------
	// Estimate Fast Point Feature Histograms and Correspondances.
	vector<Vector2i> K;
	K = computeCorrespondancePair(model[0], model[1]);

	// ------------------------------------------------------------------------
	// Compute surface registration
	Matrix4d T;
	T = fastGlobalRegistration(K, model[0], model[1]);
	model[1].Transform(T);

	// ------------------------------------------------------------------------
	// Save the results
	cout << "Result complete, exporting surfaces:" << endl;
	string resultName;
	for (int i = 0; i < nSurfaces; i++){
		resultName = string(output_path) + string(output_name) + string("_")
			+ to_string(i) + string(".ply");
		cout << endl << dataName[i] << " >> " << resultName << endl;
		WritePointCloud( resultName, model[i]);
	}

	// ------------------------------------------------------------------------
	// Cleanup and delete variables
	
	return EXIT_SUCCESS;
}

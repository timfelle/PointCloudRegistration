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


using namespace std;
using namespace Eigen;
using namespace open3d;

// ============================================================================
// MAIN FUNCTION

int main(int argc, char *argv[])
{
	// ------------------------------------------------------------------------
	// Handle input numbers and help.
	if ((argc > 1) && (string(argv[1]).compare("-h") == 0)) {
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
	const char* output_path, *input_path;
	if ((input_path = getenv("INPUT_PATH")) == NULL)
		input_path = "data/";
	if ((output_path = getenv("OUTPUT_PATH")) == NULL)
		output_path = "data/";

	// ------------------------------------------------------------------------
	// Read inputs and organize data names
	int nSurfaces = argc - 1;
	vector<string> dataName;
	int nErrors = 0;
	if (nSurfaces < 2)
	{
		string char_input;
		cout << "Please enter the name of additional surfaces. Type \"q\" to end inputs\n";
		while (true)
		{
			cout << "Surface " << nSurfaces << ": ";
			cin >> char_input;
			if ((char_input.compare("q") == 0) && (char_input.size() == 1))
				break;
			char_input = string(input_path) + char_input;

			// Ensure files have the correct 
			if (char_input.find(".ply") == string::npos) {
				cerr << "\nError in input " << ": " << char_input << endl;
				cerr << "   Incorrect file extension." << endl;
				nErrors++;
			}
			// Ensure the files exist
			else if (!is_file_exist(char_input)) {
				cerr << "\nError in input " << ": " << char_input << endl;
				cerr << "   File not found." << endl;
				nErrors++;
			}
			if (nErrors == 0) {
				dataName.push_back(char_input);
				nSurfaces++;
			}
		}
	}
	else {
		for (int i = 0; i < nSurfaces; i++) {

			// Read the input path and the name of the file.
			dataName.push_back(string(input_path) + string(argv[i + 1]));

			// Ensure files have the correct extension
			if (dataName[i].find(".ply") == string::npos) {
				cerr << "\nError in input " << i + 1 << ": " << dataName[i] << endl;
				cerr << "   Incorrect file extension." << endl;
				nErrors++;
			}
			// Ensure the files exist
			else if (!is_file_exist(dataName[i])) {
				cerr << "\nError in input " << i + 1 << ": " << dataName[i] << endl;
				cerr << "   File not found." << endl;
				nErrors++;
			}
		}
		if (nErrors > 0) return EXIT_FAILURE;
	}
	if (nSurfaces < 2) {
		cerr << "Not enough surfaces, atleast 2 are required" << endl;
		return EXIT_FAILURE;
	}
	else {
		cout << "Number of loaded surfaces: " << nSurfaces << endl << endl;
	}

	// ------------------------------------------------------------------------
	// Load the datafiles


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

	// ------------------------------------------------------------------------
	// Save the results
	cout << "Result complete, exporting surfaces:" << endl;
	vector<string> resultName;
	for (int i = 0; i < nSurfaces; i++){
		resultName.push_back(string(output_path) + string("result_") + to_string(i) + string(".ply") );
		cout << endl << dataName[i] << " >> " << resultName[i] << endl;
		WritePointCloud( resultName[i], model[i]);
	}

	// ------------------------------------------------------------------------
	// Cleanup and delete variables
	
	return EXIT_SUCCESS;
}

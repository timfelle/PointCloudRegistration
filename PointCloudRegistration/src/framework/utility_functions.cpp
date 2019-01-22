// ============================================================================
// INCLUDES
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <experimental/filesystem>

#include <Open3D/Core/Core.h>
#include <Eigen/Dense>

#include "utility_functions.h"

using namespace std;
using namespace Eigen;
namespace fs = std::experimental::filesystem;

// ============================================================================
// FILE MANIPULATION

bool is_file_exist(std::string fileName)
{
    return (bool)std::ifstream(fileName);
}

// ============================================================================
// VECTOR MANIPULATION

Vector4d vec_to_hom(Vector3d vec)
{
	Vector4d hom;
	hom << vec(0), vec(1), vec(2), 1.0;
	return hom;
}
Vector3d hom_to_vec(Vector4d hom)
{
	Vector3d vec;
	vec << hom(0) / hom(3), hom(1) / hom(3), hom(2) / hom(3);
	return vec;
}

void charToVec(const char *input, Eigen::Vector3d &vec)
{
	vector<double> v;
	size_t ind_before = 0;
	size_t ind_after = 0;
	string Input = string(input);
	while (true) {
		ind_after = Input.find(",",ind_before+1);
        v.push_back(atof(Input.substr(ind_before, ind_after-ind_before).c_str()));
		ind_before = ind_after+1;
		if (ind_after > Input.size())
			break;
    }
	vec(0) = v[0];
	vec(1) = v[1];
	vec(2) = v[2];
}


// Function used to convert vectors of rotation (pitch, roll, yaw) and transformation (x, y, z) 
// to a 4 by 4 transformation matrix.
Matrix4d transformationMatrix(Eigen::Vector3d rot, Eigen::Vector3d trans)
{
	Matrix4d T;
	Matrix3d Rx, Ry, Rz;
	Rx <<
		1.0, 0.0, 0.0,
		0.0, cos(rot(0)), -sin(rot(0)),
		0.0, sin(rot(0)), cos(rot(0));
	Ry <<
		cos(rot(1)), 0.0, sin(rot(1)),
		0.0, 1.0, 0.0,
		-sin(rot(1)), 0.0, cos(rot(1));
	Rz <<
		cos(rot(2)), -sin(rot(2)), 0.0,
		sin(rot(2)), cos(rot(2)), 0.0,
		0.0, 0.0, 1.0;

	Matrix3d R = (Rx * Ry) * Rz;
	T <<
		R(0, 0), R(0, 1), R(0, 2), trans(0),
		R(1, 0), R(1, 1), R(1, 2), trans(1),
		R(2, 0), R(2, 1), R(2, 2), trans(2),
		0.0, 0.0, 0.0, 1.0;

	return T;
}

bool checkFileName(std::string input)
{
	bool isValid = true;
	// Ensure file name have the correct extension
	if (input.find(".ply") != (input.size() - 4)) {
		cerr << "\nERROR in input:";
		cerr << "   " << input << endl;
		cerr << "   Unknown file extension." << endl;
		isValid = false;
	}
	// Ensure the files exist
	else if (!is_file_exist(input)) {
		cerr << "\nERROR in input:";
		cerr << "   " << input << endl;
		cerr << "   File not found." << endl;
		isValid = false;
	}
	return isValid;
}


vector<string> readInputFiles(int argc, char *argv[], const char *input_path)
{
	vector<string> dataName;
	// Read data names directly from input
	if (argc >= 3)
	{
		for (int i = 0; i < argc - 1; i++)
		{
			int nErrors = 0;
			string input = string(argv[i + 1]);

			if (!checkFileName(input_path + input))
			{
				vector<string> error;
				return error;
			}
			else 
				dataName.push_back(input_path + input);
		}
	}
	// Read all data from directory with basename
	else if (argc == 2)
	{
		string baseName = string(argv[1]);
		for (auto & iter : fs::directory_iterator(input_path))
		{
			string iterator = iter.path().string();
			int in = iterator.find_last_of("/\\");
			string fileName = iterator.substr(in + 1);
			if (fileName.find(baseName) != string::npos)
				dataName.push_back(input_path + fileName);
		}
		sort(dataName.begin(), dataName.end());
	}
	// Prompt user for datanames
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
			cout << argc << endl;
			if (checkFileName(input_path + input)) dataName.push_back(input_path + input);
			cout << "Surface " << dataName.size() << ": ";
			cin >> input;
		}
		if (input.compare("q") == 0)
		{
			vector<string> error;
			return error;
		}
	}

	// Return successful list of names
	return dataName;
}

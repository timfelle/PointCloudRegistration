// ============================================================================
// INCLUDES
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <Open3D/Core/Core.h>
#include <Eigen/Dense>

#include "utility_functions.h"

using namespace std;
using namespace Eigen;

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

void charToVec(const char *input, std::vector<double> &v)
{
	size_t ind_before = 0;
	size_t ind_after = 0;
	string Input = string(input);
	while (true) {
		ind_after = Input.find(",",ind_before+1);
        v.push_back(atof(Input.substr(ind_before, ind_after-ind_before-1).c_str()));
		ind_before = ind_after+1;
		if (ind_after > Input.size())
			break;
    }
}


// Function used to convert vectors of rotation (pitch, roll, yaw) and transformation (x, y, z) 
// to a 4 by 4 transformation matrix.
Matrix4d transformationMatrix(std::vector<double> rot, std::vector<double> trans)
{
	Matrix4d T;
	Matrix3d Rx, Ry, Rz;
	Rx <<
		1.0, 0.0, 0.0,
		0.0, cos(rot[0]), -sin(rot[0]),
		0.0, sin(rot[0]), cos(rot[0]);
	Ry <<
		cos(rot[1]), 0.0, sin(rot[1]),
		0.0, 1.0, 0.0,
		-sin(rot[1]), 0.0, cos(rot[1]);
	Rz <<
		cos(rot[2]), -sin(rot[2]), 0.0,
		sin(rot[2]), cos(rot[2]), 0.0,
		0.0, 0.0, 1.0;

	Matrix3d R = (Rx * Ry) * Rz;
	T <<
		R(0, 0), R(0, 1), R(0, 2), trans[0],
		R(1, 0), R(1, 1), R(1, 2), trans[1],
		R(2, 0), R(2, 1), R(2, 2), trans[2],
		0.0, 0.0, 0.0, 0.0;

	return T;
}
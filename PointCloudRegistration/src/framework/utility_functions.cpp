// ============================================================================
// INCLUDES
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <glm/glm.hpp>

#include "utility_functions.h"

using namespace std;
using namespace glm;

// ============================================================================
// FILE MANIPULATION

bool is_file_exist(std::string fileName)
{
    return (bool)std::ifstream(fileName);
}

// ============================================================================
// VECTOR MANIPULATION

glm::vec4 vec_to_hom(glm::vec3 vec)
{
	return glm::vec4(vec, 1);
}
glm::vec3 hom_to_vec(glm::vec4 hom)
{
	glm::vec3 vec = glm::vec3(hom);
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
void transformationMatrix(
	glm::mat4 &T, std::vector<double> rot, std::vector<double> trans)
{
	mat3 Rx = mat3( 
		1.0, 0.0, 0.0,					// Column 1
		0.0, cos(rot[0]),sin(rot[0]),	// Column 2
		0.0, -sin(rot[0]),cos(rot[0])	// Column 3
	);
	mat3 Ry = mat3(
		cos(rot[1]), 0.0, -sin(rot[1]),	// Column 1
		0.0, 1.0, 0.0,					// Column 2
		sin(rot[1]), 0.0, cos(rot[1])	// Column 3
	);
	mat3 Rz = mat3(
		cos(rot[2]), sin(rot[2]), 0.0,	// Column 1
		-sin(rot[2]), cos(rot[2]),0.0,	// Column 2
		0.0, 0.0, 1.0					// Column 3
	);

	mat3 R = (Rx * Ry) * Rz;
	T = mat4(R);
	T[3][0] = trans[0];
	T[3][1] = trans[1];
	T[3][2] = trans[2];
}
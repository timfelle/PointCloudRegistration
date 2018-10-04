// ============================================================================
// INCLUDES
#include <fstream>
#include <string>
#include <sstream>

#include "utility_functions.h"

// ============================================================================
// FILE MANIPULATION

bool is_file_exist(std::string fileName)
{
    return (bool)std::ifstream(fileName);
}

void charToVec(const char *input, std::vector<double> &v)
{
	size_t ind = 0;
	std::string Input = std::string(input);
    while (ind < Input.size()){
		ind = Input.find(",",ind + 1);
        v.push_back(std::atof(Input.substr(ind + 1).c_str()));
    }
}
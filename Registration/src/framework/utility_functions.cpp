// ============================================================================
// INCLUDES
#include <fstream>
#include <string>

#include "utility_functions.h"

// ============================================================================
// FILE MANIPULATION

bool is_file_exist(std::string fileName)
{
    return (bool)std::ifstream(fileName);
}

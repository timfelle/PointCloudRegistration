// ============================================================================
// INCLUDES
#include <fstream>
#include <string>

#include "utility_functions.h"

// ============================================================================
// FILE MANIPULATION

inline bool is_file_exist(std::string fileName)
{
    return (bool)std::ifstream(fileName);
}

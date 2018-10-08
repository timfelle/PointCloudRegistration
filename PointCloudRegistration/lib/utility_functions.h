#ifndef __UTILITY_FUNCTIONS__
#define	__UTILITY_FUNCTIONS__
// ============================================================================
// Includes
#include <string>
#include <vector>
#include <glm/glm.hpp>

// ============================================================================
// Function prototypes
bool is_file_exist(std::string fileName);

glm::vec4 vec_to_hom(glm::vec3 vec);
glm::vec3 hom_to_vec(glm::vec4 hom);
void charToVec(const char *input, std::vector<double> &v);
void transformationMatrix(glm::mat4 &T, std::vector<double> rot, std::vector<double> trans);

#endif	/* __UTILITY_FUNCTIONS__ */

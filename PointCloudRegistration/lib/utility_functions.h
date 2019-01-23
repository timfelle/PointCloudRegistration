#ifndef __UTILITY_FUNCTIONS__
#define	__UTILITY_FUNCTIONS__
// ============================================================================
// Includes
#include <string>
#include <vector>
#include <Open3D/Core/Core.h>
#include <Eigen/Dense>
// ============================================================================
// Function prototypes
bool is_file_exist(std::string fileName);

Eigen::Vector4d vec_to_hom(Eigen::Vector3d vec);
Eigen::Vector3d hom_to_vec(Eigen::Vector4d hom);
void charToVec(const char *input, Eigen::Vector3d &v);
Eigen::Matrix4d transformationMatrix(
	Eigen::Vector3d rot, Eigen::Vector3d trans);

bool checkFileName(std::string input);
std::vector<std::string> readInputFiles(
	int argc, char *argv[], const char *input_path);

#endif	/* __UTILITY_FUNCTIONS__ */

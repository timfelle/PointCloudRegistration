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

// Homogeneous vectors
Eigen::Vector4d vec_to_hom(Eigen::Vector3d vec);
Eigen::Vector3d hom_to_vec(Eigen::Vector4d hom);

Eigen::Matrix4d transformationMatrix(
	Eigen::Vector3d rot, Eigen::Vector3d trans
);

void charToVec(const char *input, Eigen::Vector3d &v);

std::vector<std::string> readInputFiles(
	int argc, char *argv[], const char *input_path
);
bool checkFileName(std::string input);

#endif	/* __UTILITY_FUNCTIONS__ */

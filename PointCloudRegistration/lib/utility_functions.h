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
void charToVec(const char *input, std::vector<double> &v);
Eigen::Matrix4d transformationMatrix(std::vector<double> rot, std::vector<double> trans);

#endif	/* __UTILITY_FUNCTIONS__ */

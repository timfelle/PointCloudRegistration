#ifndef __FAST_GLOBAL_REGISTRATION__
#define	__FAST_GLOBAL_REGISTRATION__
// ============================================================================
// Includes
#include <string>
#include <vector>
#include <Open3D/Core/Core.h>
#include <Eigen/Dense>
// ============================================================================
// Function prototypes
// Main function for computing the registration.
Eigen::Matrix4d fastGlobalRegistrationPair(
	std::vector<Eigen::Vector2i> K, open3d::PointCloud &model_0,
	open3d::PointCloud &model_1);

// Utility function
Eigen::Matrix4d Xi(Eigen::VectorXd xi);


#endif	/* __FAST_GLOBAL_REGISTRATION__ */
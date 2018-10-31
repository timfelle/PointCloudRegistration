#ifndef __FAST_POINT_FEATURE_HISTOGRAMS__
#define	__FAST_POINT_FEATURE_HISTOGRAMS__
// ============================================================================
// Includes
#include <string>
#include <vector>
#include <Open3D/Core/Core.h>
#include <Eigen/Dense>
// ============================================================================
// Function prototypes
// Main function for computing the registration.
Eigen::Matrix4d fastGlobalRegistration(
	std::vector<Eigen::Vector2i> K, open3d::PointCloud &model_0,
	open3d::PointCloud &model_1);


#endif	/* __FAST_POINT_FEATURE_HISTOGRAMS__ */
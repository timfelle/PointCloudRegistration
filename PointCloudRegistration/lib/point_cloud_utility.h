#ifndef __POINT_CLOUD_UTILITY__
#define	__POINT_CLOUD_UTILITY__
// ============================================================================
// Includes

#include <Open3D/Core/Core.h>		// Open3D inclusion

// ============================================================================
// Function prototypes

void applyNoise(open3d::PointCloud &model);

void export_correspondences(bool export_corr,
	open3d::PointCloud model_0, open3d::PointCloud model_1, 
	std::vector<Eigen::Vector2i> K);

#endif	/* __POINT_CLOUD_UTILITY__ */

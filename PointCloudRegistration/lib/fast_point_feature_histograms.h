#ifndef __FAST_POINT_FEATURE_HISTOGRAMS__
#define	__FAST_POINT_FEATURE_HISTOGRAMS__
// ============================================================================
// Includes
#include <string>
#include <vector>
#include <Core/Core.h>	// Open3D
// ============================================================================
// Function prototypes
std::vector<Eigen::Vector2i> computeCorrespondancePair(open3d::PointCloud model_0, open3d::PointCloud model_1);
std::vector<Eigen::Vector3f> computeFPFH(open3d::PointCloud model);

#endif	/* __FAST_POINT_FEATURE_HISTOGRAMS__ */

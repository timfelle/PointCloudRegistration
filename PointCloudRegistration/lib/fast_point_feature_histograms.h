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
std::vector<Eigen::Vector2i> computeCorrespondancePair(open3d::PointCloud &model_0, open3d::PointCloud &model_1);
void computeFPFH(open3d::PointCloud &model, std::vector<int> &P_0, std::vector<Eigen::VectorXd> &FPFH);

#endif	/* __FAST_POINT_FEATURE_HISTOGRAMS__ */

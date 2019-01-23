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

std::vector<std::vector<Eigen::Vector2i>> computeCorrespondences(
	std::vector<open3d::PointCloud> models
);

// Computation of Fast Point Feature Histograms
Eigen::MatrixXd computeFPFH(
	open3d::PointCloud &model, double radius, 
	open3d::KDTreeFlann &distTree
);


void computePersistentPoints(
	open3d::PointCloud &model, std::vector<int> &P_0, Eigen::MatrixXd &FPFH
);

// Correction functions
std::vector<Eigen::Vector2i> nearestNeighbour(
	std::vector<int> P_mod, std::vector<int> P_q, 
	Eigen::MatrixXd FPFH_mod, open3d::KDTreeFlann &KDTree_q
);
std::vector<Eigen::Vector2i> mutualNN(
	std::vector<Eigen::Vector2i > K_0, std::vector<Eigen::Vector2i> K_1
);
std::vector<Eigen::Vector2i> tupleTest(
	std::vector<Eigen::Vector2i> K_II, 
	open3d::PointCloud model_0, open3d::PointCloud model_1
);


#endif	/* __FAST_POINT_FEATURE_HISTOGRAMS__ */

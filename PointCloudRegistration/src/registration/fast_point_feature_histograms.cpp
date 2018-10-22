// ============================================================================
// INCLUDES

#include <iostream>
#include <Core/Core.h>		// Open3D inclusion

#include "fast_point_feature_histograms.h"


using namespace std;
using namespace Eigen;
using namespace open3d;

// ============================================================================
// CORRESPONDANCE PAIR
vector<Vector2i> computeCorrespondancePair(PointCloud model_0, PointCloud model_1)
{
	// Compute FPFH for the two surfaces
	vector<Vector3f> F_0 = computeFPFH(model_0);
	vector<Vector3f> F_1 = computeFPFH(model_1);

	// Set up correspondances
	vector<Vector2i> K_I, K_II, K_III;
	// K_I   = nearestNeighbour(F_0, F_1);
	// K_II  = mutualNearestNeighbour(K_I);
	// K_III = tupletest(K_II)

	return K_III;
}

// ============================================================================
// COMPUTE FPFH

vector<Vector3f> computeFPFH(PointCloud model)
{
	vector<Vector3f> F;




	return F;
}

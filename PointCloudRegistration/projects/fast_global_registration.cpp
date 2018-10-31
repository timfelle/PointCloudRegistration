// ============================================================================
// INCLUDES

#include <iostream>
#include <math.h>
#include <numeric>
#include <random>
#include <Open3D/Core/Core.h>
#include <Eigen/Dense>

#include "fast_global_registration.h"


using namespace std;
using namespace Eigen;
using namespace open3d;

// ============================================================================
// CORRESPONDANCE PAIR
Matrix4d fastGlobalRegistration(
	vector<Vector2i> K, PointCloud &model_0, PointCloud &model_1)
{
	Matrix4d T = Matrix4d::Ones();



	return T;
}
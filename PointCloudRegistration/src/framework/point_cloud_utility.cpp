// ============================================================================
// INCLUDES
#include <string>
#include <random>
#include <iostream>
#include <math.h>

#include <Open3D/Core/Core.h>
#include <Eigen/Dense>

#include "point_cloud_utility.h"
#include "utility_functions.h"

using namespace std;
using namespace Eigen;
using namespace open3d;

void applyNoise(PointCloud *model, string type, double strength)
{
	size_t nPoints = model->points_.size();
	Vector3d minBound = model->GetMinBound();
	Vector3d maxBound = model->GetMaxBound();
	
	double radius = 0.5*(maxBound - minBound).norm();
	
	// Strength is the percentage of points altered for the "outliers" version, and
	// the std for gaussian noise.
	if (type.compare("outliers") == 0)
	{
		default_random_engine gen;
		normal_distribution<double> randn(0.0,0.1*radius);
		uniform_int_distribution<int> randi(0, (int)nPoints);
		for (size_t i = 0; i < nPoints*strength; i++)
		{
			int index = randi(gen);
			model->points_[index][0] += randn(gen);
			model->points_[index][1] += randn(gen);
			model->points_[index][2] += randn(gen);
		}
	}
	// Gaussian noise with mean 0 and std 1% of bounding box radius 
	// multiplied by the user defined strength.
	else if (type.compare(string("gaussian")) == 0)
	{
		default_random_engine gen;
		normal_distribution<double> randn(0.0,0.01*radius*strength);
		for (size_t index = 0; index < nPoints; index++)
		{
			model->points_[index][0] += randn(gen);
			model->points_[index][1] += randn(gen);
			model->points_[index][2] += randn(gen);
		}
	}
	else if (type.compare(string("both")) == 0)
	{
		applyNoise(model, string("outliers"), strength);
		applyNoise(model, string("gaussian"), strength);
	}
}
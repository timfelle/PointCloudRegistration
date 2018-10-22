// ============================================================================
// INCLUDES
#include <string>
#include <random>
#include <iostream>
#include <math.h>

#include <Core/Core.h>		// Open3D inclusion

#include "point_cloud_utility.h"
#include "utility_functions.h"

using namespace std;
using namespace open3d;

void applyNoise(PointCloud *model, string type, double strength)
{
	int nPoints = model->points_.size();
	Eigen::Vector3d minBound = model->GetMinBound();
	Eigen::Vector3d maxBound = model->GetMaxBound();
	
	double radius = 0.5*(maxBound - minBound).norm();
	
	// Strength is the percentage of points altered for the "salt" version, and
	// the std for gaussian noise.
	if (type.compare("salt") == 0)
	{
		std::default_random_engine gen;
		std::normal_distribution<double> randn(0.0,0.1*radius);
		for (int i = 0; i < nPoints*strength; i++)
		{
			int index = rand() % ( nPoints + 1 );
			model->points_[index][0] += randn(gen);
			model->points_[index][1] += randn(gen);
			model->points_[index][2] += randn(gen);
		}
	}

	// Gaussian noise with mean 0 and std 1% of bounding box radius 
	// multiplied by the user defined strength.
	else if (type.compare(string("gaussian")) == 0)
	{
		std::default_random_engine gen;
		std::normal_distribution<double> randn(0.0,0.01*strength*radius);
		for (int index = 0; index < nPoints; index++)
		{
			model->points_[index][0] += randn(gen);
			model->points_[index][1] += randn(gen);
			model->points_[index][2] += randn(gen);
		}
	}
}
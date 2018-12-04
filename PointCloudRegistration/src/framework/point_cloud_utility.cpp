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

void applyNoise(PointCloud *model)
{
	// Read environment variables
	char *noise_type, *noise_strength, *outlier_amount;
	noise_type = getenv("NOISE_TYPE");
	outlier_amount = getenv("OUTLIER_AMOUNT");
	noise_strength = getenv("NOISE_STRENGTH");

	// Save environment variables
	string type		= string(noise_type);
	double amount	= atof(outlier_amount)/100.0;
	double strength = atof(noise_strength);

	// Read variables from point cloud
	size_t nPoints = model->points_.size();
	Vector3d minBound = model->GetMinBound();
	Vector3d maxBound = model->GetMaxBound();
	
	double radius = 0.5*(maxBound - minBound).norm();
	
	// Outlier amount is the percentage of point which should be altered
	if (type.compare("outliers") == 0 || type.compare("both") == 0)
	{
		default_random_engine gen;
		normal_distribution<double> randn(0.0,0.1*radius);
		uniform_int_distribution<int> randi(0, (int)nPoints);
		for (size_t i = 0; i < nPoints*amount; i++)
		{
			int index = randi(gen);
			model->points_[index][0] += randn(gen);
			model->points_[index][1] += randn(gen);
			model->points_[index][2] += randn(gen);
		}
	}

	// Gaussian noise with mean 0 and std * 1% of bounding box radius 
	// multiplied by the user defined strength.
	if (type.compare("gaussian") == 0 || type.compare("both") == 0)
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
	if ( type.compare("outliers") == 0 &&  type.compare("gaussian") == 0 &&
			type.compare("both") == 0)
			cout << "Type not found" << endl;
}
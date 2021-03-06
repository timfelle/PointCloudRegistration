// ============================================================================
// INCLUDES
#include <stdio.h>
#include <string>
#include <random>
#include <iostream>
#include <exception>
#include <math.h>

#include <Open3D/Core/Core.h>
#include <Eigen/Dense>
#include <Open3D/IO/IO.h>

#include "point_cloud_utility.h"
#include "utility_functions.h"

using namespace std;
using namespace Eigen;
using namespace open3d;

void applyNoise(PointCloud &model)
{
	// Read Noise type
	char *noise_type = getenv("NOISE_TYPE");
	string type = string(noise_type);

	// If no noise is required exit the function
	if (type.compare("none") == 0)
		return;

	// Read variables from point cloud
	size_t nPoints = model.points_.size();
	Vector3d minBound = model.GetMinBound();
	Vector3d maxBound = model.GetMaxBound();
	double radius = 0.5*(maxBound - minBound).norm();

	// Outlier amount is the percentage of point which should be altered
	if (type.compare("outliers") == 0 || type.compare("both") == 0)
	{

		char *outlier_amount = getenv("OUTLIER_AMOUNT");
		double amount = atof(outlier_amount) / 100.0;

		default_random_engine gen;
		normal_distribution<double> randn(0.0, 0.1*radius);
		uniform_int_distribution<int> randi(0, (int)nPoints - 1);
		for (size_t i = 0; i < nPoints*amount; i++)
		{
			int index = randi(gen);
			model.points_[index](0) += randn(gen);
			model.points_[index](1) += randn(gen);
			model.points_[index](2) += randn(gen);
		}
	}

	// Gaussian noise with mean 0 and std * 1% of bounding box radius 
	// multiplied by the user defined strength.
	if (type.compare("gaussian") == 0 || type.compare("both") == 0)
	{
		char *noise_strength = getenv("NOISE_STRENGTH");
		double strength = atof(noise_strength);

		default_random_engine gen;
		normal_distribution<double> randn(0.0, 0.01*radius*strength);
		for (size_t index = 0; index < nPoints; index++)
		{
			model.points_[index](0) += randn(gen);
			model.points_[index](1) += randn(gen);
			model.points_[index](2) += randn(gen);
		}
	}
	if (!(type.compare("outliers") == 0 || type.compare("gaussian") == 0 ||
		type.compare("both") == 0))
	{
		cerr << __func__ << ":" << __func__ << ":" << __LINE__ << endl;
		cerr << "   Noise type invalid: " << type << endl;
	}
	return;
}


void export_correspondences(bool export_corr, 
	PointCloud model_0, PointCloud model_1, vector<Vector2i> K)
{
	if (export_corr == false) return;

	char *output_name = getenv("OUTPUT_NAME");
	char *output_path = getenv("OUTPUT_PATH");

	PointCloud correspondence_0, correspondence_1;
	for (int i = 0; i < K.size(); i++)
	{
		correspondence_0.points_.push_back(model_0.points_[K[i](0)]);
		correspondence_1.points_.push_back(model_1.points_[K[i](1)]);
	}
	string corr_name = string(output_path) + string("corr_") + string(output_name);
	WritePointCloud(corr_name + string("_0")+ string(".ply"), correspondence_0);
	WritePointCloud(corr_name + string("_1")+ string(".ply"), correspondence_1);
}

// ============================================================================
// INCLUDES
#include <string>
#include <random>
#include <iostream>
#include <math.h>

#include <glm/glm.hpp>

#include "point_cloud_utility.h"
#include "utility_functions.h"

using namespace std;
using namespace glm;

// ============================================================================
// computePointCloudNormals
void computePointCloudNormals(PLYModel *model)
{
	int N = model->vertexCount;

	

}

void transformModel(PLYModel *model, mat3 rot, vec3 trans)
{

}
void applyNoise(PLYModel *model, string type, double strength)
{
	double radius = 0.5*sqrt(
		model->bvWidth*model->bvWidth + 
		model->bvDepth*model->bvDepth + 
		model->bvHeight*model->bvHeight);
	
	// Strength is the percentage of points altered for the "salt" version, and
	// the std for gaussian noise.
	if (type.compare("salt") == 0)
	{
		std::default_random_engine gen;
		std::normal_distribution<double> randn(0.0,0.1*radius);
		for (int i = 0; i < model->vertexCount*strength; i++)
		{
			int index = rand() % ( model->vertexCount + 1 );
			model->positions[index].x += randn(gen);
			model->positions[index].y += randn(gen);
			model->positions[index].z += randn(gen);
		}
	}

	// Gaussian noise with mean 0 and std 1% of bounding box radius 
	// multiplied by the user defined strength.
	else if (type.compare(string("gaussian")) == 0)
	{
		std::default_random_engine gen;
		std::normal_distribution<double> randn(0.0,0.01*strength*radius);
		for (int i = 0; i < model->vertexCount; i++)
		{
			model->positions[i].x += randn(gen);
			model->positions[i].y += randn(gen);
			model->positions[i].z += randn(gen);
		}
	}
}
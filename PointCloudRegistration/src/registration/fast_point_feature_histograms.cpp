// ============================================================================
// INCLUDES

#include <iostream>
#include <math.h>
#include <Open3D/Core/Core.h>
#include <Eigen/Dense>

#include "fast_point_feature_histograms.h"


using namespace std;
using namespace Eigen;
using namespace open3d;

// ============================================================================
// CORRESPONDANCE PAIR
vector<Vector2i> computeCorrespondancePair(PointCloud &model_0, PointCloud &model_1)
{
	// Compute FPFH for the two surfaces
	vector<int> P_0, P_1;
	vector<VectorXd> FPFH_0, FPFH_1;
	computeFPFH(model_0, P_0, FPFH_0);
	computeFPFH(model_1, P_1, FPFH_1);
	
	// Build the 2 search trees
	KDTreeFlann KDTree_0, KDTree_1;

	KDTree_0.SetFeature(FPFH_0);
	KDTree_1.SetGeometry(model_1);

	// Set up correspondances
	vector<Vector2i> K_I, K_II, K_III;
	// K_I   = nearestNeighbour(F_0, F_1);
	// K_II  = mutualNearestNeighbour(K_I);
	// K_III = tupletest(K_II)

	return K_III;
}

// ============================================================================
// COMPUTE FPFH
void computeFPFH(PointCloud &model, vector<int> &P, vector<VectorXd> &FPFH)
{
	// ********************************************************************* \\
	// Initialization of the different values used in the computations.
	double R = 0.5*(model.GetMaxBound() - model.GetMinBound()).norm();
	double tol_R = 0.25;					// Maximal proportion of R to use.
	double s1 = 0.0, s2 = 0.0, s3 = 0.0;	// Tolerances for feature cutoff
	double alpha = 2.0;						// Proportion of STD to mark persistent.

	// Initialize the persistent set as all points in the set.
	P = vector<int>(model.points_.size());
	for (int id = 0; id < P.size(); id++)
		P[id] = id;

	// Precompute the KDTree used for distance search.
	KDTreeFlann distTree;
	distTree.SetGeometry(model);

	// ********************************************************************* \\
	// For each radius determine the FPFH and persistent features.
	for (double r = 0.01*R; r < tol_R*R; r *= 2)
	{
		// Allocate space for needed values
		vector<VectorXd> SPFH(P.size());
		vector<vector<int>> Neighbours(P.size());

		// ================================================================= \\
		// Compute the simplified features for all points.
		for (int idx = 0; idx < P.size(); idx++)
		{
			int p_idx = P[idx];

			// Read the current point and the normal of the point.
			Vector3d p = model.points_[p_idx];
			Vector3d n = model.normals_[p_idx];

			// ============================================================= \\
			// Nighbours are the indices of the neighbours in the model.
			vector<int> neighbours;
			vector<double> distances;
			distTree.SearchRadius(p, r, neighbours, distances);

			Neighbours[idx] = neighbours;

			// ============================================================= \\
			// For each neighbour compute the local SPFH values
			VectorXd spfh(6);
			for (int k = 0; k < neighbours.size(); k++)
			{
				int pk_idx = neighbours[k];
				Vector3d p_k = model.points_[pk_idx];
				Vector3d n_k = model.normals_[pk_idx];

				// Determine the order of p and p_k
				Vector3d p_i, p_j, n_i, n_j;
				Vector3d line = p - p_k;
				double angle_p = acos(n.dot(line) / (n.norm()*line.norm()));
				double angle_pk = acos(n_k.dot(line) / (n_k.norm()*line.norm()));
				if (angle_p <= angle_pk)
				{
					p_i = p; p_j = p_k;
					n_i = n; n_j = n_k;
				}
				else {
					p_i = p_k; p_j = p;
					n_i = n_k; n_j = n;
				}


				// Define the Darboux frame
				Vector3d u = n_i;
				Vector3d v = (p_j - p_i); v.cross(u);
				Vector3d w = u; w.cross(v);

				// Compute features
				double f_1 = v.dot(n_j);
				double f_2 = (u.dot(p_j - p_i)) / ((p_j - p_i).norm());
				double f_3 = atan2(w.dot(n_j), u.dot(n_j));

				// Compute simplified histogram
				if (f_1 <  s1) spfh[0]++;
				if (f_1 >= s1) spfh[1]++;
				if (f_2 <  s2) spfh[2]++;
				if (f_2 >= s2) spfh[3]++;
				if (f_3 <  s3) spfh[4]++;
				if (f_3 >= s3) spfh[5]++;
			}

			SPFH[idx] = spfh;
		}

		// ================================================================= \\
		// Compute the FPFH for each point
		FPFH = vector<VectorXd>(P.size());
		for (int idx = 0; idx < FPFH.size(); idx++)
		{
			int p_idx = P[idx];
			Vector3d p = model.points_[p_idx];

			FPFH[idx] = VectorXd::Zero(6);
			double Kinv = 1.0 / Neighbours[idx].size();

			for (int k = 0; k < Neighbours[idx].size(); k++)
			{
				int pk_idx = Neighbours[idx][k];
				Vector3d pk = model.points_[pk_idx];

				FPFH[idx] +=  1.0 / (p - pk).norm() * SPFH[idx];
			}
			FPFH[idx] *= Kinv; 
			FPFH[idx] += SPFH[idx];
		}
		
		// ================================================================= \\
		// Compute the mean and standard deviation of the feature histograms.
		VectorXd mu = VectorXd::Zero(6), sigma = VectorXd::Zero(6);

		// Mean
		for (int id = 0; id < FPFH.size(); id++)
			mu += FPFH[id];
		mu /= 1.0*FPFH.size();

		// Standard Deviation
		for (int f = 0; f < 6; f++)
		{
			VectorXd p_f;
			for (int id = 0; id < P.size(); id++)
				p_f << model.points_[P[id]](f) - mu[f];
			sigma(f) = p_f.norm() / sqrt(FPFH.size() - 1);
		}

		// ================================================================= \\
		// Determine which points have persistent features.
		vector<int> P_new;
		vector<VectorXd> FPFH_new;
		for (int idx = 0; idx < P.size(); idx++)
		{
			int p_idx = P[idx];
			double dist = (FPFH[idx] - mu).norm();
			if (
				dist > alpha*sigma(0) &&
				dist > alpha*sigma(1) &&
				dist > alpha*sigma(2) &&
				dist > alpha*sigma(3) &&
				dist > alpha*sigma(4) &&
				dist > alpha*sigma(5)
				)
			{
				P_new.push_back(p_idx);
				FPFH_new.push_back(FPFH[idx]);
			}
		}

		// ================================================================= \\
		// Use only persistent features for next iteration.
		P = P_new;
		FPFH = FPFH_new;
	}
}

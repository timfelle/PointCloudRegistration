// ============================================================================
// INCLUDES

#include <iostream>
#include <math.h>
#include <numeric>
#include <random>
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
	MatrixXd FPFH_0, FPFH_1;
	computeFPFH(model_0, P_0, FPFH_0);
	computeFPFH(model_1, P_1, FPFH_1);
	
	// Build the 2 search trees
	KDTreeFlann KDTree_0(FPFH_0);
	KDTreeFlann KDTree_1(FPFH_1);

	//KDTree_0.SetMatrixData(FPFH_0);
	//KDTree_1.SetMatrixData(FPFH_1);

	// Set up correspondances
	vector<Vector2i> K_I_0, K_I_1, K_II, K_III;
	K_I_0 = nearestNeighbour(P_0, P_1, FPFH_0, KDTree_1);
	K_I_1 = nearestNeighbour(P_1, P_0, FPFH_1, KDTree_0);
	K_II  = mutualNN(K_I_0, K_I_1);
	K_III = tupleTest(K_II, model_0, model_1);

	return K_III;
}

// ============================================================================
// COMPUTE FPFH
void computeFPFH(PointCloud &model, vector<int> &P, MatrixXd &FPFH)
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
		MatrixXd SPFH(P.size(),6);
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

			SPFH.row(idx) = spfh/neighbours.size();
		}

		// ================================================================= \\
		// Compute the FPFH for each point
		FPFH = MatrixXd(P.size(),6);
		for (int idx = 0; idx < FPFH.size(); idx++)
		{
			int p_idx = P[idx];
			Vector3d p = model.points_[p_idx];

			VectorXd fpfh = VectorXd::Zero(6);
			double Kinv = 1.0 / Neighbours[idx].size();

			for (int k = 0; k < Neighbours[idx].size(); k++)
			{
				int pk_idx = Neighbours[idx][k];
				Vector3d pk = model.points_[pk_idx];

				fpfh +=  1.0 / (p - pk).norm() * SPFH.row(pk_idx);
			}
			fpfh *= Kinv; 
			FPFH.row(idx) = fpfh + SPFH.row(idx);
		}
		
		// ================================================================= \\
		// Compute the mean and standard deviation of the feature histograms.
		VectorXd mu = VectorXd::Zero(6), sigma = VectorXd::Zero(6);

		// Mean
		for (int id = 0; id < FPFH.size(); id++)
			mu += FPFH.row(id);
		mu /= 1.0*FPFH.size();

		// Standard Deviation
		for (int f = 0; f < 6; f++)
		{
			VectorXd p_f;
			for (int id = 0; id < P.size(); id++)
				p_f << model.points_[P[id]](f) - mu[f];
			sigma(f) = p_f.norm() / sqrt(FPFH.rows() - 1);
		}

		// ================================================================= \\
		// Determine which points have persistent features.
		vector<int> P_new;
		MatrixXd FPFH_new;
		for (int idx = 0; idx < P.size(); idx++)
		{
			int p_idx = P[idx];
			VectorXd dist = (FPFH.row(idx) - mu).cwiseAbs();
			if (
				dist(0) > alpha*sigma(0) &&
				dist(1) > alpha*sigma(1) &&
				dist(2) > alpha*sigma(2) &&
				dist(3) > alpha*sigma(3) &&
				dist(4) > alpha*sigma(4) &&
				dist(5) > alpha*sigma(5)
				)
			{
				P_new.push_back(p_idx);
				FPFH_new.conservativeResize(FPFH_new.size() + 1, NoChange);
				FPFH_new.row(FPFH_new.size()-1) =  FPFH.row(idx);
			}
		}

		// ================================================================= \\
		// Use only persistent features for next iteration.
		P = P_new;
		FPFH = FPFH_new;
	}
}

// ============================================================================
// LIST NEAREST NEIGHBOUR IN FPFH SPACE
vector<Vector2i> nearestNeighbour(vector<int> P_mod, vector<int> P_q,
	MatrixXd FPFH_mod, KDTreeFlann &KDTree_q)
{
	vector<Vector2i> K_near;


	for (int i = 0; i < P_mod.size(); i++)
	{
		vector<int> index;
		vector<double> dist;
		Vector2i k;
		//int knn = 1;
		KDTreeSearchParamKNN knn(1);
		KDTree_q.Search(FPFH_mod.row(i), knn, index, dist);

		k(0) = P_mod[i];
		k(1) = P_q[index[0]];

		K_near.push_back(k);
	}
	return K_near;
}

// ============================================================================
// COLLECT MUTUAL NEAREST NEIGHBOURS
vector<Vector2i> mutualNN(vector<Vector2i> K_0, vector<Vector2i> K_1)
{
	vector<Vector2i> K_mutual;

	for (int i = 0; i < K_0.size(); i++)
	{
		Vector2i k_0 = K_0[i];
		for (int j = 0; j < K_1.size(); j++)
		{
			Vector2i k_1 = K_1[j];

			if ((k_0(0) == k_1(1)) && (k_0(1) == k_1(0)))
				K_mutual.push_back(k_0);
		}
	}
	return K_mutual;
}
// ============================================================================
// RUN TUPLE TEST
vector<Vector2i> tupleTest(vector<Vector2i> K_II,PointCloud model_0, PointCloud model_1)
{
	// Initialize values
	vector<Vector2i> K_III;
	double tau = 0.9;
	double tau_inv = 1.0 / tau;

	// Fill index vector
	vector<int> I(K_II.size());
	iota(I.begin(), I.end(), 0);

	// Do a random shuffle of I
	random_device rd;
	mt19937 g(rd());
	shuffle(I.begin(), I.end(),g);

	// Run through all points
	for (size_t i = 0; i < K_II.size()-3; i += 3)
	{
		int idx = I[i];
		double r01, r02, r12;

		// Read the p and q points from the two models.
		Vector3d p_0 = model_0.points_[K_II[idx    ](0)];
		Vector3d p_1 = model_0.points_[K_II[idx + 1](0)];
		Vector3d p_2 = model_0.points_[K_II[idx + 2](0)];
		Vector3d q_0 = model_1.points_[K_II[idx    ](0)];
		Vector3d q_1 = model_1.points_[K_II[idx + 1](0)];
		Vector3d q_2 = model_1.points_[K_II[idx + 2](0)];

		// Compute ratios
		r01 = (p_0 - p_1).norm() / (q_0 - q_1).norm();
		r02 = (p_0 - p_2).norm() / (q_0 - q_2).norm();
		r12 = (p_1 - p_2).norm() / (q_1 - q_2).norm();

		// Save correspondences if ratios are valid
		if ((tau < r01 && r01 <= tau_inv) &&
			(tau < r02 && r02 <= tau_inv) &&
			(tau < r12 && r12 <= tau_inv))
		{
			K_III.push_back(K_II[idx    ]);
			K_III.push_back(K_II[idx + 1]);
			K_III.push_back(K_II[idx + 2]);
		}
	}

	return K_III;
}
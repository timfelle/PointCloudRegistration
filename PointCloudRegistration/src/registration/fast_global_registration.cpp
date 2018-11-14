// ============================================================================
// INCLUDES

#include <iostream>
#include <math.h>
#include <numeric>
#include <random>
#include <Open3D/Core/Core.h>
#include <Eigen/Dense>

#include "utility_functions.h"
#include "fast_global_registration.h"


using namespace std;
using namespace Eigen;
using namespace open3d;

// ============================================================================
// COMPUTE REGISTRATION
Matrix4d fastGlobalRegistration(
	vector<Vector2i> K, PointCloud &model_0, PointCloud &model_1)
{
	// Initialize values
	double tol_nu = 1e-8;			// Tolerance on nu
	double tol_e = 1e-3;			// Tolerance on e
	double D_0 = (model_0.GetMinBound() - model_0.GetMaxBound()).norm();
	double D_1 = (model_1.GetMinBound() - model_1.GetMaxBound()).norm();
	double D = max(D_0, D_1);

	size_t nK = K.size();

	Matrix4d T = Matrix4d::Identity();
	VectorXd xi = VectorXd::Zero(6);

	double nu = max(pow(D, 2.0), 1.0);
	int it_nu = 0;
	while ( nu > tol_nu * D )
	{
		VectorXd e = VectorXd::Zero(nK);
		MatrixXd Je = MatrixXd::Zero(nK, 6);
		double err = 0.0;
		for (size_t i = 0; i < nK; i++)
		{
			int p_idx = K[i](0);
			int q_idx = K[i](1);

			// Read p and q
			Vector4d p = vec_to_hom(model_0.points_[p_idx]);
			Vector4d q = vec_to_hom(model_1.points_[q_idx]);

			// Compute l_(p,q)
			double l_pq_sqrt = nu / (nu + pow((p - T * q).norm(), 2.0));
			double l_pq = pow(l_pq_sqrt, 2.0);
			
			// Compute M and V
			Vector4d M = T * q;
			Vector4d V = p - Xi(xi)*M;

			// Update e and J_e
			double V_norm = V.norm();
			e(i) = l_pq_sqrt * V_norm;

			Je(i, 0) = V(1)*M(2) - V(2)*M(1);
			Je(i, 1) = V(2)*M(0) - V(0)*M(2);
			Je(i, 2) = V(0)*M(1) - V(1)*M(0);
			Je(i, 3) = -V(0)*M(3);
			Je(i, 4) = -V(1)*M(3);
			Je(i, 5) = -V(2)*M(3);
			Je.row(i) *= l_pq_sqrt / V_norm;

			err += (p - M).norm();
		}

		if (err < tol_e * nK) break;

		// Update T and xi
		xi = (Je.transpose()*Je).ldlt().solve(-Je.transpose()*e);
		T = Xi(xi)*T;

		// Update nu every forth time
		it_nu++;
		if (it_nu == 4) {
			nu /= 2.0;
			it_nu = 0;
		}
	}

	return T;
}

MatrixXd Xi(VectorXd xi)
{
	MatrixXd X(4, 4);
	X << 1.0, -xi(2), xi(1), xi(3),
		xi(2), 1.0, -xi(0), xi(4),
		-xi(1), xi(0), 1.0, xi(5),
		0.0, 0.0, 0.0, 1.0;
	return X;
}
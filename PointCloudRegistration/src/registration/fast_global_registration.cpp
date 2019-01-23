// ============================================================================
// INCLUDES

#include <iostream>
#include <math.h>
#include <numeric>
#include <random>
#include <Open3D/Core/Core.h>
#include <Open3D/Core/Registration/FastGlobalRegistration.h>
#include <Eigen/Dense>
#include <unsupported/Eigen/MatrixFunctions>


#include "utility_functions.h"
#include "point_cloud_utility.h"
#include "fast_global_registration.h"


using namespace std;
using namespace Eigen;
using namespace open3d;


// ============================================================================
// COMPUTE REGISTRATION
void fastGlobalRegistration(
	vector<PointCloud> &models, vector<vector<Vector2i>> K)
{
	string corr_env = string(getenv("EXPORT_CORRESPONDENCES"));
	bool export_corr = corr_env.compare("true");


	Matrix4d T;
	const size_t nSurfaces = models.size();

	// Pairwise registration
	if (nSurfaces == 2)
	{
		export_correspondences(export_corr, models[0], models[1], K[0]);

		// Compute surface registration
		T = fastGlobalRegistrationPair(K[0], models[0], models[1]);

		models[1].Transform(T);
		export_correspondences(export_corr, models[0], models[1], K[0]);
		
		cout << "Estimated transformation" << endl << T << endl;
		return;
	}

	// Multi surface implementation (Serial Pairs at the moment)
	cout << "Surface:" << endl;
	for (int s = 0; s < nSurfaces - 1; s++)
	{
		cout << "   " << s << ", " << s + 1 << endl;

		// Compute surface registration
		T = fastGlobalRegistrationPair(K[s], models[s], models[s + 1]);

		models[s + 1].Transform(T);

	}

}


// ============================================================================
// COMPUTE PAIRWISE REGISTRATION
Matrix4d fastGlobalRegistrationPair(
	vector<Vector2i> &K, PointCloud &model_0, PointCloud &model_1)
{
	// If the FGR version is set to use the open3d implementation
	string FGR_ver = string(getenv("FGR_VERSION"));
	if (FGR_ver.compare("open3d") == 0)
	{
		FastGlobalRegistrationOption opts;
		opts.iteration_number_ = 1e3;
		//opts.division_factor_ = 1.1;
		//opts.decrease_mu_ = true;
		//opts.maximum_correspondence_distance_;
		//opts.maximum_tuple_count_
		//opts.use_absolute_scale_

		Feature feature_0 = *ComputeFPFHFeature(model_0);
		Feature feature_1 = *ComputeFPFHFeature(model_1);
		RegistrationResult result = FastGlobalRegistration(
			model_1, model_0, feature_1, feature_0, opts);
		K = result.correspondence_set_;
		return result.transformation_;
	}

	// Initialize values
	double tol_nu = atof(getenv("TOL_NU"));			// Tolerance on nu
	double tol_e = atof(getenv("TOL_E"));			// Tolerance on e

	double D_0 = (model_0.GetMinBound() - model_0.GetMaxBound()).norm();
	double D_1 = (model_1.GetMinBound() - model_1.GetMaxBound()).norm();
	double D = max(D_0, D_1);

	size_t nK = K.size();

	Matrix4d T = Matrix4d::Identity();
	VectorXd xi = VectorXd::Zero(6);

	double nu = max(pow(D, 2.0), 1.0);
	int it_nu = 0;
	double err = 0.0;
	while (nu > tol_nu * D)
	{
		VectorXd e = VectorXd::Zero(4 * nK);
		MatrixXd Je = MatrixXd::Zero(4 * nK, 6);

		err = 0.0;
		for (size_t i = 0; i < nK; i++)
		{
			int p_idx = K[i](0);
			int q_idx = K[i](1);

			// Read p and q
			Vector4d p = vec_to_hom(model_0.points_[p_idx]);
			Vector4d q = vec_to_hom(model_1.points_[q_idx]);

			// Compute l_(p,q)
			double l_pq_sqrt = nu / (nu + pow((p - T * q).norm(), 2.0));

			// Compute M and V
			Vector4d M = T * q;

			// Update e and J_e
			e(4 * i + 0) = l_pq_sqrt * (p(0) - M(0));
			e(4 * i + 1) = l_pq_sqrt * (p(1) - M(1));
			e(4 * i + 2) = l_pq_sqrt * (p(2) - M(2));
			e(4 * i + 3) = l_pq_sqrt * (p(3) - M(3));

			MatrixXd J(4, 6);
			J << 0, -M(2), M(1), -M(3), 0, 0
				, M(2), 0, -M(0), 0, -M(3), 0
				, -M(1), M(0), 0, 0, 0, -M(3)
				, 0, 0, 0, 0, 0, 0;

			Je.row(4 * i + 0) = l_pq_sqrt * J.row(0);
			Je.row(4 * i + 1) = l_pq_sqrt * J.row(1);
			Je.row(4 * i + 2) = l_pq_sqrt * J.row(2);
			Je.row(4 * i + 3) = l_pq_sqrt * J.row(3);

			err += (p - M).norm() / nK;
		}
		if (err < tol_e) break;

		// Update T and xi
		xi = (Je.transpose()*Je).ldlt().solve(-Je.transpose()*e);

		T = Xi(xi)*T;

		// Update nu every forth time
		it_nu++;
		if (it_nu == 4) {
			nu *= 0.5;
			it_nu = 0;
		}
	}
	return T;
}

Matrix4d Xi(VectorXd xi)
{
	Matrix4d X(4, 4);
	X << 0.0, -xi(2), xi(1), xi(3),
		xi(2), 0.0, -xi(0), xi(4),
		-xi(1), xi(0), 0.0, xi(5),
		0.0, 0.0, 0.0, 0.0;
	return X.exp();
}
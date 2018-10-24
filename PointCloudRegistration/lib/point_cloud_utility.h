#ifndef __POINT_CLOUD_UTILITY__
#define	__POINT_CLOUD_UTILITY__
// ============================================================================
// Includes

#include <Open3D/Core/Core.h>		// Open3D inclusion

// ============================================================================
// Function prototypes

void applyNoise(open3d::PointCloud *model, std::string type, double strength);

#endif	/* __POINT_CLOUD_UTILITY__ */

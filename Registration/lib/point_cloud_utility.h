#ifndef __POINT_CLOUD_UTILITY__
#define	__POINT_CLOUD_UTILITY__
// ============================================================================
// Includes

#include <glm/glm.hpp>
#include <vector>

// ============================================================================
// Structure definitions
struct PLYModel {
    std::vector<glm::vec3> positions;
    std::vector<glm::vec3> normals;
    std::vector<glm::vec3> colors;
	std::vector<glm::ivec3> faces;

    int vertexCount; 					//number of vertices
    float bvWidth, bvHeight, bvDepth; 	//bounding volume dimensions
    float bvAspectRatio; 				//bounding volume aspect ratio
	int faceCount; 						//number of faces; if reading meshes
	bool isMesh; 						// To tell if this is a mesh or not
	bool ifColor,ifNormal;

    glm::vec3 min, max, center;

    PLYModel();
	//To indicate if normal, color informations are present in the file respectively
    PLYModel(const char *filename, bool =1,bool =1); 
	// To indicate if normal, color informations are to be written in the file respectively
	void PLYWrite(const char *filename, bool =1,bool =1);
	void FreeMemory();
};

struct Material {
    glm::vec4 Ka;
    glm::vec4 Kd;
    glm::vec4 Ks;
    float shininess;
};

struct Light {
    glm::vec4 La;
    glm::vec4 Ld;
    glm::vec4 Ls;
    glm::vec4 position;
};

// ============================================================================
// Function prototypes
void computePointCloudNormals(PLYModel *model);

void transformModel(PLYModel *model, glm::mat3 rot, glm::vec3 trans);
void applyNoise(PLYModel *model, std::string type, double strength);

#endif	/* __POINT_CLOUD_UTILITY__ */

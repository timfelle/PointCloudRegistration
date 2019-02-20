# =============================================================================
# WRITE MY DESCRIPTION

# =============================================================================
# Import definitions

import sys
import registration

import pptk
from plyfile import PlyData
from numpy import sqrt
import numpy as np


# =============================================================================

class display:
	'''Display of various types'''
	def __init__(self): pass

	def pointcloud(self,FileName):

		if FileName[-4:] == '.ply':
			model = PlyData.read(FileName)
		else : 
			print('Error in: ' + __name__ + '.pointcloud\n' + 
				'   Unsupported file type: .' + FileName.rpartition('.')[-1],
				file=sys.stderr)
			exit()

		XYZ = np.array([
			model.elements[0].data['x'],
			model.elements[0].data['y'],
			model.elements[0].data['z']]
		).transpose()


		N = self._compute_normals(model)

		Idx = ~np.isnan(N)

		XYZ = XYZ[Idx]
		XYZ = XYZ.reshape((int(len(XYZ)/3),3))
		N = N[Idx]
		N = N.reshape((int(len(N)/3),3))

		# Compute the shading
		L1 = [1,1,0]
		L3 = [0,0,1]
		I = self._compute_shading([L1,L3],N)
		
		# Set up colours
		C = np.array([I,I,I]).transpose()

		bbox = np.array([
			[ min(XYZ[0,:]) , max(XYZ[0,:])],
			[ min(XYZ[1,:]) , max(XYZ[1,:])],
			[ min(XYZ[2,:]) , max(XYZ[2,:])]]).transpose()
		bbox_r =  np.linalg.norm(
			bbox[1,:] - bbox[0,:]
			)

		plt = pptk.viewer(XYZ,C)
		plt.set( 
			lookat 			= [np.mean(XYZ[:,0]), np.mean(XYZ[:,1]),np.mean(XYZ[:,2])],
			point_size		= bbox_r*0.0025,
			bg_color		= [1,1,1,1],
			bg_color_top 	= [0,0,0,1],
			bg_color_bottom = [0,0,0,1],
			show_axis 		= False,
			show_info		= False,
			show_grid		= False,
			r				= bbox_r,
			phi				= 0.2,
			theta			= 0.8,
			)

		plt.capture('hell.png')
		plt.wait()
		plt.close()




	# -------------------------------------------------------------------------

	def _compute_normals(self,model):
		XYZ = np.array([
			model.elements[0].data['x'],
			model.elements[0].data['y'],
			model.elements[0].data['z']]
		).transpose()
		N = pptk.estimate_normals(XYZ.astype('float64'),k=30,r=0.005)
		print( N.shape )
		return N

	def _compute_shading(self,
			L,N, 				# Light and normals of the surface
			ambient = 0.1,		# Ambient light
			highlight = 0.1		# Highlight cut-off
		):

		I = np.zeros(N.shape[0])

		for l in L:
			l /= ( sqrt(l[0]**2 + l[1]**2 + l[2]**2) )
			i = N[:,0]*l[0] + N[:,1]*l[1] + N[:,2]*l[2]
			I += i/len(L)

		return abs(I)*(1.0 - ambient - highlight) + ambient

# # EOF # #
# =============================================================================
#!/bin/sh

# Find all tests if specified
if [ "$1" = "all" ] ; then
	for test in `ls shell/*`;
	do 
		t_name=`basename -- "$test"`
		tests+="${t_name%.*} "
	done
	./figure_remake.sh $tests
	exit
fi

for test in $@ ;
do
	DAT="figures/$test/data"
	FIG="figures/$test"

	rm -f 	$FIG/*.png   $FIG/*.eps   $FIG/*.pdf \
			$FIG/*/*.png $FIG/*/*.pdf $FIG/*/*.eps
	case "$test" in
		generateData)
			FIGS="'bunnyClean','bunnyGaussian','bunnyNoise','bunnyOutliers',"
			FIGS+="'bunnyTransform'"
			matlab -wait -nodesktop -nosplash -r "
				addpath('matlab');
				displayRegistration({$FIGS},'$DAT','$FIG');
				exit;" 
		;;
		noiseTest)
			FIGS="'bunny','resultClean','resultGauss1','resultGauss2',"
			FIGS+="'resultOut1','resultOut2','resultOut3'"
			matlab -wait -nodesktop -nosplash -r "
				addpath('matlab');
				displayRegistration({$FIGS},'$DAT','$FIG');
				exit;" 
		;;
		versionCompare)
			FIGS="'fgr_open3d','fpfh_open3d','local'"
			matlab -wait -nodesktop -nosplash -r "
				addpath('matlab');
				displayRegistration({$FIGS},'$DAT','$FIG');
				exit;" 
		;;
		foxTest)
			FIGS="'local','open3d'"
			VER="left right upright upsidedown"
			for v in $VER ;
			do
				matlab -wait -nodesktop -nosplash -r "
					addpath('matlab');
					displayRegistration({$FIGS},'$DAT/$v','$FIG/$v');
					exit;" 
			done
		;;
		sealTest)
			FIGS="'pointcloud','local','open3d'"
			VER="left right upright"
			for v in $VER ;
			do
				matlab -wait -nodesktop -nosplash -r "
					addpath('matlab');
					displayRegistration({$FIGS},'$DAT/$v','$FIG/$v');
					exit;" 
			done
		;;
	esac
done
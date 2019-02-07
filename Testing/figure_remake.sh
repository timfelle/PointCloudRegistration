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
MFLAGS="-wait -nodesktop -nosplash"
echo $@
for test in $@ ;
do
	echo -n "$test "
	DAT="figures/$test/data"
	FIG="figures/$test"

	rm -f 	$FIG/*.png   $FIG/*.eps   $FIG/*.pdf \
			$FIG/*/*.png $FIG/*/*.pdf $FIG/*/*.eps
	case "$test" in
		armadilloTest)
			FIGS="'armadillo','result'"
			matlab $MFLAGS -r "
				addpath('matlab');
				displayRegistration({$FIGS},'$DAT','$FIG');
				exit;" 
		;;
		giraffeTest)
			FIGS="'giraffe','result'"
			matlab $MFLAGS -r "
				addpath('matlab');
				displayRegistration({$FIGS},'$DAT','$FIG',[],50);
				exit;" 
		;;
		bikeTest)
			FIGS="'bike','result'"
			matlab $MFLAGS -r "
				addpath('matlab');
				displayRegistration({$FIGS},'$DAT','$FIG');
				exit;" 
		;;
		generateData)
			FIGS="'bunnyClean','bunnyGaussian','bunnyNoise','bunnyOutliers',"
			FIGS+="'bunnyTransform'"
			matlab $MFLAGS -r "
				addpath('matlab');
				displayRegistration({$FIGS},'$DAT','$FIG',[],20);
				exit;" 
		;;
		noiseTest)
			FIGS="'bunny','resultClean','resultGauss1','resultGauss2',"
			FIGS+="'resultOut1','resultOut2','resultOut3'"
			matlab $MFLAGS -r "
				addpath('matlab');
				displayRegistration({$FIGS},'$DAT','$FIG',[],20);
				exit;" 
		;;
		gaussianTest)
			FIGS="'bun10','gauss10','bun15','gauss15'"
			matlab $MFLAGS -r "
				addpath('matlab');
				displayCorrespondences({$FIGS},'$DAT','$FIG');
				exit;"
		;;	
		versionCompare)
			FIGS="'fgr_open3d','fpfh_open3d','local'"
			matlab $MFLAGS -r "
				addpath('matlab');
				displayRegistration({$FIGS},'$DAT','$FIG',[],20);
				exit;" 
		;;
		foxTest)
			FIGS="'pointcloud','local','open3d'"
			VER="left right upright upsidedown"
			for v in $VER ;
			do
				matlab $MFLAGS -r "
					addpath('matlab');
					displayRegistration({$FIGS},'$DAT/$v','$FIG/$v',true,10);
					exit;" 
			done
		;;
		sealTest)
			FIGS="'local','open3d'"
			VER="left right upright"
			for v in $VER ;
			do
				matlab $MFLAGS -r "
					addpath('matlab');
					displayRegistration({$FIGS},'$DAT/$v','$FIG/$v',true,10);
					exit;" 
			done
		;;
	esac
done
echo " "

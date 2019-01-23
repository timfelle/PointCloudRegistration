function animateCorrespondences(inputName,dataPath,exportLocation)
%ANIMATECORRESPONDENCES
%  This function creates a animation showing the initial and final
%  poses for a set of surface correspondences algned with a 
%  registration. The animation orbits around the two models over 
%  15 seconds.
%  __________________________________________________________________
%  ANIMATECORRESPONDENCES()
%       Runs the animation for the partial bunny both as initial and 
%		final pose.
%       '../data/' and exports the result in the folder 
%       '../logs/matlab'.
%
%  ANIMATECORRESPONDENCES(name)
%		Displays the correspondences located in the file 'name_corr*.ply'.
%       Import and export path is as above. Figures will be exported with
%       the filename "name" as well.
%
%  ANIMATECORRESPONDENCES(name, dataPath)
%       Locates the models in the folder specified by 'dataPath'.
%
%  ANIMATECORRESPONDENCES(name, dataPath, exportLocation)
%       Exports the animation at location specified by 
%		'exportLocation'.
%
%  See also EXPORTFIGURES.

%% Handle input
if ~exist('inputName','var') || isempty(inputName)
    inputName = 'Corr';
end
if ~exist('dataPath','var') || isempty(dataPath)
    dataPath = '../logs/debugging/';
end
if ~exist('exportLocation','var') || isempty(dataPath)
    exportLocation = '../logs/matlab';
end
dataName = findData(dataPath,inputName);
if isempty(dataName) 
    error('File %s not found.',inputName); 
end

%% Generate the correspondence plots
F = displayCorrespondences(inputName,dataPath,exportLocation,nargin~=0);

% Find the axes in question
A1 = findobj('Tag','A1');
A2 = findobj('Tag','A2');
axis(A1,'vis3d','off');
axis(A2,'vis3d','off');
set([A1,A2],'Projection','perspective')

F.WindowStyle = 'normal';
F.Position = [50,50,1500,700];
v = VideoWriter([exportLocation,'/',F.Name],'Motion JPEG AVI');

% Settings for the video
v.Quality = 95;
v.FrameRate = 60;
Time = 10;


Frames = Time*v.FrameRate;
angle = 360/Frames;

open(v);
for i = 1 : Frames
    camorbit(A1,angle,0);
    camorbit(A2,angle,0);
    frame = getframe(F);
    writeVideo(v,frame);
end
close(v);
F.WindowStyle = 'docked';
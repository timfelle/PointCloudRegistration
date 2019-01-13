function animateCorrespondences(inputName,dataPath,exportLocation)
%DISPLAYMODEL
%  This function displays a .ply point cloud as a 3d scatter.
%  __________________________________________________________________
%  DISPLAYMODEL()
%       Displays the bunnyPartial1.ply file located on the path
%       '../data/' and exports the result in the folder 
%       '../logs/matlab'.
%
%  DISPLAYMODEL(name)
%       Displays the model located in the file 'name.ply'.
%       Import and export path is as above.
%
%  DISPLAYMODEL(name, dataPath)
%       Locates the model in the folder specified by 'dataPath'.
%
%  DISPLAYMODEL(name, dataPath, exportLocation)
%       Exports the model at location specified by 'exportLocation'.
%
%  See also EXPORTFIGURES.

opengl software

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
    return;
end

%% Generate the correspondence plots
F = displayCorrespondences(inputName,dataPath,exportLocation,nargin~=0);

% Find the axes in question
A1 = findobj('Tag','A1');
A2 = findobj('Tag','A2');
axis(A1,'vis3d','off');
axis(A2,'vis3d','off');

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
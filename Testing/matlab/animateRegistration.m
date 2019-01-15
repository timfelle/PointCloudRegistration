function animateRegistration(preName,postName,dataPath,exportLocation)
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

%% Handle input
if ~exist('preName','var') || isempty(preName)
    preName = 'bunnyPartial';
end
if ~exist('postName','var') || isempty(postName)
    postName = 'bunnyPartial';
end
if ~exist('dataPath','var') || isempty(dataPath)
    dataPath = '../data/';
end
if ~exist('exportLocation','var') || isempty(dataPath)
    exportLocation = '../logs/matlab';
end
dataNamePre = findData(dataPath,preName);
dataNamePos = findData(dataPath,postName);
if isempty(dataNamePre)
    error('File %s not found.',dataNamePre);
end
if isempty(dataNamePos)
    error('File %s not found.',dataNamePos);
end

%% Generate the correspondence plots
if (size(dataNamePos,2) == 2)
	Color = flipud(colormap(gray(3)));
else
	Color = flipud(colormap(white(max(size(dataNamePos,2),size(dataNamePre,2)))));
end
F = CreateFigure('aniReg');

A1 = subplot(121);
hold on
for i=1:length(dataNamePre)
    dispReg(dataNamePre{i},dataPath,Color(i,:))
end
view([30,10])
hold off

A2 = subplot(122);
hold on
for i=1:length(dataNamePos)
    dispReg(dataNamePos{i},dataPath,Color(i,:))
end
view([30,10])
hold off

% Find the axes in question
axis(A1,'vis3d','off');
axis(A2,'vis3d','off');
cam1 = campos(A1);
cam2 = campos(A2);
campos(A1,cam1 + [0.0,0.6,0.1]);
campos(A2,cam2 + [0.0,0.6,0.1]);
set([A1,A2],'Projection','perspective')

F.WindowStyle = 'normal';
drawnow;
F.Position = [50,50,1500,1000];
v = VideoWriter([exportLocation,'/',F.Name],'Motion JPEG AVI');

% Settings for the video
v.Quality = 99;
v.FrameRate = 60;
Time = 12;


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
end

function dispReg(name,dataPath,Color)
data = name ;
if ~exist([dataPath,data],'file')
    return;
end

%% Load the data
model = pcread([dataPath,data]);
normal = pcnormals(model);

L = [0,1,1];
ambient = 0.1;
L = L./norm(L);
I = normal(:,1).*L(1) + normal(:,2).*L(2) + normal(:,3).*L(3);
I = abs(I)*(1.0-ambient) + ambient;

A = scatter3(model.Location(:,1),model.Location(:,2),model.Location(:,3));
A.CData = I*Color;
A.Marker = 'O';
A.MarkerEdgeColor = 'flat';
A.MarkerFaceColor = 'flat';

end
function animateRegistration(Name,dataPath,exportLocation)
%ANIMATEREGISTRATION
%  This function creates a animation showing the initial and final
%  poses for a set of surfaces algned with a registration. The 
%  animation orbits around the two models over 15 seconds.
%  __________________________________________________________________
%  ANIMATEREGISTRATION()
%       Runs the animation for the partial bunny both as initial and 
%		final pose.
%       '../data/' and exports the result in the folder 
%       '../logs/matlab'.
%
%  ANIMATEREGISTRATION(nameIni,nameEnd)
%       Read the initial and final poses from the file names specified.
%       Import and export path is as above.
%
%  ANIMATEREGISTRATION(name, dataPath)
%       Locates the models in the folder specified by 'dataPath'.
%
%  ANIMATEREGISTRATION(name, dataPath, exportLocation)
%       Exports the animation at location specified by 
%		'exportLocation'.
%
%  See also EXPORTFIGURES.

%% Handle input
if ~exist('Name','var') || isempty(Name)
    Name = 'bunnyPartial';
end
if ~exist('dataPath','var') || isempty(dataPath)
    dataPath = '../data/';
end
if ~exist('exportLocation','var') || isempty(dataPath)
    exportLocation = '../logs/matlab';
end

if ~strcmp(dataPath(end),'/')
	dataPath = [dataPath,'/'];
end
dataName = findData(dataPath,Name);
if isempty(dataName)
    error('File %s not found.',dataName);
end

%% Generate the correspondence plots
F = CreateFigure('aniReg');

if (size(dataName,2) == 2)
	Color = flipud(colormap(gray(3)));
else
	Color = colormap(white(max(size(dataName,2),size(dataName,2))));
end

for i=1:length(dataName)
    if i ~= 1
        hold on
    end
    dispReg(dataName{i},dataPath,Color(i,:))
end
view([30,10])
hold off
A = gca;

% Find the axes in question
axis(A,'vis3d','off');
cam1 = campos(A);
campos(A,cam1 + [0.0,0.6,0.1]);
set(A,'Projection','perspective')

F.WindowStyle = 'normal';
F.Color = [1,1,1];
F.Position = [150,150,1000,1000];
v = VideoWriter([exportLocation,'/',F.Name],'Uncompressed AVI');

% Settings for the video
v.FrameRate = 30;
Time = 15;


Frames = Time*v.FrameRate;
angle = 360/Frames;
open(v);
for i = 1 : Frames
    camorbit(A,angle,0);
    
    drawnow;
    frame = getframe(F);
    writeVideo(v,frame);
end
close(v)
close(F)
end

function dispReg(name,dataPath,Color)
data = name ;
if ~exist([dataPath,data],'file')
    return;
end

%% Load the data
model = pcread([dataPath,data]);
if model.Count > 50000
	f = min(50000/model.Count,1);
	model = pcdownsample(model,'random',f);
end
model = pcdenoise(model,'NumNeighbors',8,'Threshold',0.05);
normal = pcnormals(model, min(floor(0.005*model.Count),20));

L1 = [0,1,1];
L2 = [1,0,0];
ambient = 0.1;
highlight = 0.1;
L1 = L1./norm(L1);
L2 = L2./norm(L2);
I1 = normal(:,1).*L1(1) + normal(:,2).*L1(2) + normal(:,3).*L1(3);
I2 = normal(:,1).*L2(1) + normal(:,2).*L2(2) + normal(:,3).*L2(3);

I = abs((I1 + I2)./2).*(1.0-ambient-highlight) + ambient;

A = scatter3(model.Location(:,1),model.Location(:,2),model.Location(:,3),5);
A.CData = I*Color;
A.Marker = 'O';
A.MarkerEdgeColor = 'flat';
A.MarkerFaceColor = 'flat';

end
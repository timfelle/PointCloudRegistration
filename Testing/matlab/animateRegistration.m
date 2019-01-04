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
    preName = 'bunny';
end
if ~exist('postName','var') || isempty(postName)
    postName = 'resultClean';
end
if ~exist('dataPath','var') || isempty(dataPath)
    dataPath = '../logs/debugging/';
end
if ~exist('exportLocation','var') || isempty(dataPath)
    exportLocation = '../logs/matlab';
end
dataNamePre = findData(dataPath,preName);
dataNamePos = findData(dataPath,postName);
if isempty(dataNamePre) || isempty(dataNamePos)
    return;
end

%% Generate the correspondence plots
Color = colormap(jet(size(dataNamePre,2)));
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

F.WindowStyle = 'normal';
F.Position = [50,50,1500,700];
v = VideoWriter([exportLocation,'/',F.Name],'Motion JPEG AVI');

% Settings for the video
v.Quality = 95;
v.FrameRate = 60;
Time = 15;


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

X = double(model.Location(:,1));
Y = double(model.Location(:,2));
Z = double(model.Location(:,3));
A = scatter3(X,Y,Z,20 + randi(100));
A.MarkerFaceColor = Color;
A.MarkerEdgeColor = Color*0.2;
A.LineWidth = 0.1;

end
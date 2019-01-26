function animateScanning(Name,dataPath,exportLocation)
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
%1
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
dataName = findData(dataPath,Name);
if isempty(dataName)
    error('File %s not found.',dataName);
end

%% Generate the correspondence plots
if (size(dataName,2) == 2)
    Color = flipud(colormap(gray(3)));
else
    Color = flipud(colormap(white(max(size(dataName,2),size(dataName,2)))));
end

F = zeros(length(dataName),1);
A = zeros(length(dataName),1);
close all
for i=1:length(dataName)
    F(i) = figure(i);
    A(i) = axes();
    axis tight
    set(A(i),'DataAspectRatio',[1,1,1]);
    axis vis3d
    hold on
    dispReg(dataName{i},dataPath,Color(i,:))
    hold off
    axis off
    view([90,20])
    
end

set(A,'Projection','perspective')
set(A,'XLim',get(A(1),'XLim'),'YLim',get(A(1),'YLim'),'ZLim',get(A(1),'ZLim'));
set(A,'CameraPosition',get(A(1),'CameraPosition'));
% Find the axes in question

set(F,'WindowStyle','normal');
drawnow;
set(F,'Position',[50,50,1000,1000]);
v = VideoWriter([exportLocation,'/','aniScan'],'Motion JPEG AVI');

% Settings for the video
v.Quality = 99;
v.FrameRate = 5;
Time = 12;


Frames = Time*v.FrameRate;
framePerModel = Frames/length(dataName);
open(v);

id_old = 1;
for i = 0 : Frames-1
    
    id = floor(i/framePerModel)+1;
    
    frame = getframe(F(id));
    writeVideo(v,frame);
    if id~=id_old
        close(id_old)
    end
    id_old = id;
end
close(v);
close(F);
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
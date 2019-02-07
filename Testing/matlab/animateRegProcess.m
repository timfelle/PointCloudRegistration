function animateRegProcess(Name,dataPath,exportLocation)
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
    Name = {'bunny.ply','bunnyPartial'};
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
%% Generate the correspondence plots

F = CreateFigure('AnimationRegistrationProcess');
F.WindowStyle = 'normal';
F.Position = [50,50,1000,1000];
F.Color = [1,1,1];
A = gca;
axis tight
set(A,'DataAspectRatio',[1,1,1]);
axis vis3d
set(A,'Projection','perspective')
% Find the axes in question
v = VideoWriter([exportLocation,'/','aniRegProc'],'Uncompressed AVI');

% Settings for the video
v.FrameRate = 20;
Time = 1.5*size(Name,2);


Frames = Time*v.FrameRate;
framePerModel = Frames/length(Name);
open(v);
count = -1;
id_old = 0;

for i = 0 : Frames-1
    id = floor(i/framePerModel)+1;
    
    if id ~= id_old
        id_old = id;
        count = 1;
    else
        count = count + 1;
    end
    
    per1 = count/(v.FrameRate*0.25);
    per2 = 1 - (count)/(v.FrameRate*0.25);
    
    if per1 <= 1.0
        dispReg(Name{id},dataPath,[1,1,1],per1);
    end
    if per2 > 0.0 && id > 1
        dispReg(Name{id-1},dataPath,[1,1,1],per2);
    end
    hold off
    
    if i == 0
        view([130,20])
        Lim(1,:) = A.XLim;
        Lim(2,:) = A.YLim;
        Lim(3,:) = A.ZLim;
        Cam = A.CameraPosition;
    end
    A.XLim = Lim(1,:);
    A.YLim = Lim(2,:);
    A.ZLim = Lim(3,:);
    
    A.CameraPosition = Cam;
    
    drawnow;
    frame = getframe(F);
    writeVideo(v,frame);
    if i == 0
        ExportFigures(F,exportLocation);
    end
end

close(v);
close(F);
end

function dispReg(name,dataPath,Color,per)
data = findData(dataPath,name);

for i = 1:size(data,2)
    if i == 2
        hold on
        Color = Color*0.5;
    end
    %% Load the data
	model = pcread([dataPath,data{i}]);
	if model.Count > 50000
		f = min(50000/model.Count,1);
		model = pcdownsample(model,'random',f);
	end
	
    if per < 1
        model = pcdownsample(model,'random',per);
    end
    normal = pcnormals(model, min(floor(0.005*model.Count),40));
    
    
    L = [0,1,1];
    ambient = 0.1;
    L = L./norm(L);
    I = normal(:,1).*L(1) + normal(:,2).*L(2) + normal(:,3).*L(3);
    I = abs(I)*(1.0-ambient) + ambient;
    
    S = scatter3(model.Location(:,1),model.Location(:,2),model.Location(:,3),5);
    S.CData = I*Color;
    S.Marker = 'O';
    S.MarkerEdgeColor = 'flat';
    S.MarkerFaceColor = 'flat';
    
    axis off
    
end
end
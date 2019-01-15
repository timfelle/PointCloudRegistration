function F = displayCorrespondences(inputName,dataPath,exportLocation,export)
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
if ~exist('inputName','var') || isempty(inputName)
    inputName = 'Corr';
end
if ~exist('dataPath','var') || isempty(dataPath)
    dataPath = '../logs/debugging/';
end
if ~exist('exportLocation','var') || isempty(exportLocation)
    exportLocation = '../logs/matlab';
end
if ~exist('export','var') || isempty(export)
    export = false;
end 
dataName = findData(dataPath,inputName);
if isempty(dataName) 
    error('File %s not found.',inputName);
end
F = CreateFigure(inputName);

Color = colormap(jet(size(dataName,2)));
Corr = {};
CorrT = {};
for i=1:length(dataName)
    if (strcmp(dataName{i}(length(inputName)+1),'T') == false)
        Corr{end+1} = dataName{i};
    else
        CorrT{end+1} = dataName{i};
    end
end

A1 = subplot(121);
A1.Tag = 'A1';
hold on
   dispPC(Corr{1},dataPath,Color(1,:))
   dispPC(Corr{2},dataPath,Color(2,:))
   dispLi(Corr{1},Corr{2},dataPath)
hold off
view([30,10])
axis vis3d
grid on

A2 = subplot(122);
A2.Tag = 'A2';
hold on
    dispPC(CorrT{1},dataPath,Color(1,:))
    dispPC(CorrT{2},dataPath,Color(2,:))
    dispLi(CorrT{1},CorrT{2},dataPath)
hold off
view([30,10])
axis vis3d
grid on
T = suptitle('Before registration and after registration');
T.FontSize = 15;
T.FontWeight = 'bold';
set([A1,A2],'Projection','perspective')

if export
		if ~isunix
        	ExportFigures(F,exportLocation,'asp',1)
		else
			ExportFigures(F,exportLocation,'asp',1,'ext','png','dpi',600)
		end
end
end

function dispPC(name,dataPath,Color)
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

A = pcshow(model,'MarkerSize',36);
A = A.Children(1);
A.CData = I*Color;
A.Marker = 'O';
A.MarkerEdgeColor = 'flat';
A.MarkerFaceColor = 'flat';

end

function dispLi(name_0, name_1,dataPath)
data_0 = name_0 ;
data_1 = name_1 ;
if ~exist([dataPath,data_0],'file')
    return;
end
if ~exist([dataPath,data_1],'file')
    return;
end

%% Load the data
model_0 = pcread([dataPath,data_0]);
model_1 = pcread([dataPath,data_1]);

X_0 = double(model_0.Location(:,1));
Y_0 = double(model_0.Location(:,2));
Z_0 = double(model_0.Location(:,3));

X_1 = double(model_1.Location(:,1));
Y_1 = double(model_1.Location(:,2));
Z_1 = double(model_1.Location(:,3));
for i = 1:length(X_0)
    A = plot3([X_0(i),X_1(i)],...
        [Y_0(i),Y_1(i)],...
        [Z_0(i),Z_1(i)],...
        'r');
end
A.LineWidth = 0.1;


end
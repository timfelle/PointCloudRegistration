function displayModel(inputName,dataPath,exportLocation)
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
    inputName = 'bunnyPartial1';
end
if ~exist('dataPath','var') || isempty(dataPath)
    dataPath = '../data/';
end
if ~exist('exportLocation','var') || isempty(dataPath)
    exportLocation = '../logs/matlab';
end

if iscell(inputName)
    for i=1:length(inputName)
        dispMod(inputName{i},dataPath,exportLocation)
    end
else
    dispMod(inputName,dataPath,exportLocation)
end
end

function dispMod(name,dataPath,exportLocation)
data = [ dataPath, name, '.ply' ];
if ~exist(data,'file')
    return;
end

%% Load the data
F = CreateFigure(name);
Color = [0.3,0.5,0.9];

model = pcread(data);
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

hold off
axis vis3d
axis off
view([0,90])
cam = campos;
campos(cam - [0,0,0.4])

ExportFigures(F,exportLocation,'asp',1)
end
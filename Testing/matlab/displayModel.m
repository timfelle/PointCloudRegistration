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
data = [ name, '.ply' ];
if ~exist(data,'file')
    return;
end

%% Load the data
F = CreateFigure(name);
model = pcread([dataPath,data]);

X = double(model.Location(:,1));
Y = double(model.Location(:,2));
Z = double(model.Location(:,3));

A = scatter3(X,Y,Z);
axis equal
axis off

Color = [0.3,0.5,0.9];

A.MarkerFaceColor = Color;
A.MarkerEdgeColor = Color*0.2;
A.LineWidth = 0.1;
view([0,90])

ExportFigures(F,exportLocation,'asp',1)
end
function renderModel(inputName,dataPath,exportLocation)
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
if ~exist('exportLocation','var') || isempty(exportLocation)
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
    disp(data);
    disp('File not found');
    return;
end

%% Load the data
F = CreateFigure(name);
model = pcread(data);
Color = colormap(jet(2));
Color = Color(1,:);

X = double(model.Location(:,1));
Y = double(model.Location(:,2));
Z = double(model.Location(:,3));
s = 0.01*abs( max([X;Y;Z]) - min([X;Y;Z]));
hold on
Q = 10;
subsample = 0.5;
I = randperm( length(X), floor(length(X)*subsample))';
light('Position',[-0.4 0.2 0.9],'Style','infinite');
AX = gca;
for i = 1:size(I,1)
	idx = I(i);
    [x,y,z] = sphere(Q);
    A= surf(AX,s*x+X(idx),s*y+Y(idx),s*z+Z(idx));
    A.FaceColor = Color;
    
    A.SpecularStrength =0.0;
    A.AmbientStrength  =0.0;
    A.LineStyle='none';
end
lighting gouraud
hold off
axis vis3d
axis off
ExportFigures(F,exportLocation,'asp',1,'ext','png','dpi',1000)
close(F);
end

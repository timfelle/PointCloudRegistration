function renderRegistration(inputName,dataPath,exportLocation)
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
    inputName = 'bunnyPartial';
end
if ~exist('dataPath','var') || isempty(dataPath)
    dataPath = '../data/';
end
if ~exist('exportLocation','var') || isempty(dataPath)
    exportLocation = '../logs/matlab';
end
dataName = findData(dataPath,inputName);

F = CreateFigure(inputName);

Color = colormap(jet(size(dataName,2)));
drawnow;
hold on
for i=1:length(dataName)
    dispReg(dataName{i},dataPath,Color(i,:))
end

hold off
axis vis3d
axis off
view([0,90])

ExportFigures(F,exportLocation,'asp',1)
close(F);
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
end
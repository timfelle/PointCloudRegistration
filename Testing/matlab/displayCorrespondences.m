function displayCorrespondences(inputName,dataPath,exportLocation)
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
if ~exist('exportLocation','var') || isempty(dataPath)
    exportLocation = '../logs/matlab';
end
dataName = findData(dataPath,inputName);
if isempty(dataName) 
    return;
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

subplot(121);
hold on
   dispPC(Corr{1},dataPath,Color(1,:))
   dispPC(Corr{2},dataPath,Color(2,:))
   dispLi(Corr{1},Corr{2},dataPath)
hold off
view([30,10])
grid on

subplot(122);
hold on
    dispPC(CorrT{1},dataPath,Color(1,:))
    dispPC(CorrT{2},dataPath,Color(2,:))
    dispLi(CorrT{1},CorrT{2},dataPath)
hold off
view([30,10])
grid on

if nargin ~= 0
    ExportFigures(F,exportLocation,'asp',2)
end
end

function dispPC(name,dataPath,Color)
data = name ;
if ~exist([dataPath,data],'file')
    return;
end

%% Load the data
model = pcread([dataPath,data]);

X = double(model.Location(:,1));
Y = double(model.Location(:,2));
Z = double(model.Location(:,3));
A = scatter3(X,Y,Z);
A.MarkerFaceColor = Color;
A.MarkerEdgeColor = Color*0.2;
A.LineWidth = 0.1;

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
function displayRegistration(inputName,dataPath,exportLocation)
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
for input=1:length(inputName)
	dataName = findData(dataPath,inputName{input});

	F = CreateFigure(inputName{input});

	Color = colormap(jet(size(dataName,2)));

	hold on
	for i=1:length(dataName)
	    dispReg(dataName{i},dataPath,Color(i,:))
	end

	hold off
	axis vis3d
	axis off
	view([0,90])

	ExportFigures(F,exportLocation,'asp',1)
	close(F)
end
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
A = scatter3(X,Y,Z);
A.MarkerFaceColor = Color;
A.MarkerEdgeColor = Color*0.2;
A.LineWidth = 0.1;

end
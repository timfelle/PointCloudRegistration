function displayRegistration(inputName,dataPath,exportLocation,denoise)
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
if ~exist('exportLocation','var') || isempty(exportLocation)
    exportLocation = '../logs/matlab';
end
if ~exist('denoise','var') || isempty('denoise')
    denoise = false;
end
if ischar(inputName)
    inputName = {inputName};
end

for input=1:length(inputName)
	dataName = findData(dataPath,inputName{input});

	F = CreateFigure(inputName{input});

	if (size(dataName,2) <= 3)
		Color = flipud(colormap(gray(3)));
	else
		Color = flipud(colormap(white(size(dataName,2))));
	end

	hold on
	for i=1:length(dataName)
	    dispReg(dataName{i},dataPath,Color(i,:),denoise)
	end

	hold off
	set(gca,'PlotBoxAspectRatio',[1,1,1],'DataAspectRatio',[1,1,1]);
    axis vis3d
	axis off
    view([90,20])

    if nargin ~= 0
		if ~isunix
        	ExportFigures(F,exportLocation,'asp',1)
		else
			ExportFigures(F,exportLocation,'asp',1,'ext','png','dpi',600)
		end
        close(F)
    end
end
end

function dispReg(name,dataPath,Color,denoise)
data = name ;
if ~exist([dataPath,data],'file')
	error('File %s not found.',data); 
end

%% Load the data
model = pcread([dataPath,data]);
if denoise == true
    model = pcdenoise(model);
end
normal = pcnormals(model,40);

L1 = [0,1,1];
L2 = [1,0,0];
ambient = 0.1;
highlight = 0.1;
L1 = L1./norm(L1);
L2 = L2./norm(L2);
I1 = normal(:,1).*L1(1) + normal(:,2).*L1(2) + normal(:,3).*L1(3);
I2 = normal(:,1).*L2(1) + normal(:,2).*L2(2) + normal(:,3).*L2(3);

I = abs((I1 + I2)./2).*(1.0-ambient-highlight) + ambient;

scatter3(...
    model.Location(:,1), model.Location(:,2), model.Location(:,3),...
    [],I*Color,'filled','O');

set(gca,'Projection', 'perspective');
end
function displayRegistration(inputName,dataPath,exportLocation,denoise,S)
%DISPLAYREGISTRATION
%  This function displays the registration of point clouds as a shaded 
%  3d scatter. If less 3 or less pointclouds are found, shading will be
%  done in different shades of gray.
%  __________________________________________________________________
%  DISPLAYREGISTRATION()
%       Displays the bunnyPartial files located on the path
%       '../data/' and exports the result in the folder 
%       '../logs/matlab'.
%
%  DISPLAYREGISTRATION(name)
%       Display the models located in the file 'name*.ply'.
%       Import and export path is as above. Exported figures are using the
%       "name" given in the input. 
%       Can be a cell of several names.
%
%  DISPLAYREGISTRATION(name, dataPath)
%       Locates the model in the folder specified by 'dataPath'.
%
%  DISPLAYREGISTRATION(name, dataPath, exportLocation)
%       Exports the model at location specified by 'exportLocation'.
%
%  DISPLAYREGISTRATION(name, dataPath, exportLocation,denoise)
%       Set a flag if the pointcloud should be run through a denoising.
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
    exportLocation = [];
end
if ~exist('denoise','var') || isempty(denoise)
    denoise = false;
end
if ~exist('S','var') || isempty(S)
    S = 40;
end


if ischar(inputName)
    inputName = {inputName};
end
if ~strcmp(dataPath(end),'/')
	dataPath = [dataPath,'/'];
end
if ~exist(dataPath,'dir')
    error('Directory not found')
end


for input=1:length(inputName)
	dataName = findData(dataPath,inputName{input});
	
	F = CreateFigure(inputName{input});
	A = axes();
	axis tight
	set(A,'DataAspectRatio',[1,1,1]);
    
	if (length(dataName) < 3)
		Color = flipud(colormap(gray(3)));
	else
		Color = flipud(colormap(white(length(dataName))));
	end

	hold on
	for i=1:length(dataName)
	    dispReg(dataName{i},dataPath,Color(i,:),denoise,S)
	end

	hold off
	axis off
    view([90,20])

	if isempty(A.Children)
		error('Plots are empty, displayRegistration(%s)',inputName{input});
	end
	if ~isempty(exportLocation)
		if ~isunix
        	ExportFigures(F,exportLocation,'asp',1)
		else
			ExportFigures(F,exportLocation,'asp',1,'ext','png','dpi',600)
		end
        close(F)
	end
end
end

function dispReg(name,dataPath,Color,denoise,S)
data = name ;
if ~exist([dataPath,data],'file')
	error('File %s not found.',data); 
end

%% Load the data
model = pcread([dataPath,data]);
if model.Count > 50000
	f = min(10000/model.Count,1);
	model = pcdownsample(model,'random',f);
end
if denoise == true
    model = pcdenoise(model,'NumNeighbors',10);
end
normal = pcnormals(model, min(floor(0.005*model.Count),40));


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
    S,I*Color,'filled','O');

set(gca,'Projection', 'perspective');
end
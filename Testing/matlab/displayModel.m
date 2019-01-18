function displayModel(inputName,dataPath,exportLocation,denoise)
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
    inputName = 'bunny';
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

if ~strcmp(dataPath(end),'/')
	dataPath = [dataPath,'/'];
end

for input=1:length(inputName)
    dataName = [inputName{input}];
    if length(dataName ) < 4 || ~strcmp(dataName(end-3:end),'.ply')
        dataName = [dataName,'.ply']; %#ok<AGROW>
    end
    
    if ~exist([dataPath,dataName],'file')
        error('File %s not found.',dataName);
    end
	F = CreateFigure(inputName{input});
	A = axes();
	axis tight
	set(A,'DataAspectRatio',[1,1,1]);
    axis vis3d

	Color = [0.9,0.9,0.9];
    hold on
    	dispMod(dataName,dataPath,Color,denoise);
	hold off
	
	axis off
	view([90,20])
	
	if isempty(A.Children)
		error('No Plots generated');
	end
    if nargin == 3
		if ~isunix
        	ExportFigures(F,exportLocation,'asp',1)
		else
			ExportFigures(F,exportLocation,'asp',1,'ext','png','dpi',400)
		end
        close(F)
    end
end
end

function dispMod(dataName,dataPath,Color,denoise)

%% Load the data
model = pcread([dataPath,dataName]);
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
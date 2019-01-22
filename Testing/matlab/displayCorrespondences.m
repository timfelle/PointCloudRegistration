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
if ~exist('exportLocation','var') || isempty(exportLocation)
    exportLocation = '../logs/matlab';
end
if dataPath(end) ~= '/'
    dataPath = [dataPath,'/'];
end

F = CreateFigure(inputName);
A = zeros(length(inputName),1);
for i = 1:length(inputName)
    dataName = findData(dataPath,inputName{i});
    if isempty(dataName)
        error('File %s not found.',inputName{i});
    end
    figure(F{i});
    A(i) = axes();
	
	axis tight
    
    Corr_pre  = { dataName{ contains(dataName,'pre') }};
    if length(Corr_pre) < 2
        error('Not enough datasets found');
    end
    
    Color = colormap(gray(length(Corr_pre)+1));
    hold on
    dispPC(Corr_pre{1},dataPath,Color(2,:))
    dispPC(Corr_pre{2},dataPath,Color(1,:))
    hold off
	grid on
    view([120,20])
end
set(A,'Projection','perspective');
set(A,'XLim',get(A(1),'XLim'),'YLim',get(A(1),'YLim'),'ZLim',get(A(1),'ZLim'));

if ~isunix
		ExportFigures([F{:}],exportLocation,'asp',1);
	else
		ExportFigures([F{:}],exportLocation,'asp',1,'ext','png','dpi',600);
	end
end

function dispPC(name,dataPath,Color)
data = name ;
%% Load the data
model = pcread([dataPath,data]);
normal = pcnormals(model,40);

L1 = [0,1,1];
L2 = [1,0,0];
ambient = 0.1;
highlight = 0.0;
L1 = L1./norm(L1);
L2 = L2./norm(L2);
I1 = normal(:,1).*L1(1) + normal(:,2).*L1(2) + normal(:,3).*L1(3);
I2 = normal(:,1).*L2(1) + normal(:,2).*L2(2) + normal(:,3).*L2(3);

I = 1;%abs((I1 + I2)./2).*(1.0-ambient-highlight) + ambient;

scatter3(...
    model.Location(:,1), model.Location(:,2), model.Location(:,3),...
    100,I*Color,'filled','O');

set(gca,'Projection', 'perspective');
end
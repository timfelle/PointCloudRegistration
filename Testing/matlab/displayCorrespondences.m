function displayCorrespondences(inputName,dataPath,exportLocation,drawLines)
%DISPLAYCORRESPONDENCES
%  Visualise and exports a set of correspondences.
%  __________________________________________________________________
%  DISPLAYCORRESPONDENCES()
%       Display the bun10 correspondence sets located in 
%       '../data/' and exports the result in the folder
%       '../logs/matlab'.
%
%  DISPLAYCORRESPONDENCES(name)
%       Display the correspondences located in the file 'name_corr*.ply'.
%       Import and export path is as above. Figures will be exported with
%       the filename "name" as well.
%
%  DISPLAYCORRESPONDENCES(name, dataPath)
%       Locates the model in the folder specified by 'dataPath'.
%
%  DISPLAYCORRESPONDENCES(name, dataPath, exportLocation)
%       Exports the model at location specified by 'exportLocation'.
%
%  DISPLAYCORRESPONDENCES(name, dataPath, exportLocation, drawLines)
%       Sets flag if connecting lines should be drawn or not.
%
%  See also EXPORTFIGURES.

%% Handle input
if ~exist('inputName','var') || isempty(inputName)
    inputName = {'bun10'};
end
if ~exist('dataPath','var') || isempty(dataPath)
    dataPath = '../data/';
end
if ~exist('exportLocation','var') || isempty(exportLocation)
    exportLocation = '../logs/matlab';
end
if ~exist('drawLines','var') || isempty(drawLines)
    drawLines = false;
end

if ~iscell(inputName)
    inputName = {inputName};
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
	for d = 1:length(dataName)
		dataName{d} = ['corr_', dataName{d}];
	end
    figure(F(i));
    A(i) = axes();
	
	axis tight
    
    if length(dataName) < 2
        error('Not enough datasets found');
    end
    
    Color = colormap(gray(length(dataName)+1));
    hold on
    dispPC(dataName{1},dataPath,Color(2,:))
    dispPC(dataName{2},dataPath,Color(1,:))
	if drawLines
		F(i).Name = [F(i).Name, 'Lines'];
        drawLine(dataName{1},dataName{2},dataPath)
    end
    hold off
	grid on
    view([120,20])
end
set(A,'Projection','perspective');
set(A,'XLim',get(A(1),'XLim'),'YLim',get(A(1),'YLim'),'ZLim',get(A(1),'ZLim'));

if ~isunix
		ExportFigures(F,exportLocation,'asp',1);
	else
		ExportFigures(F,exportLocation,'asp',1,'ext','png','dpi',600);
	end
end

function dispPC(name,dataPath,Color)
data = name ;
%% Load the data
model = pcread([dataPath,data]);

scatter3(...
    model.Location(:,1), model.Location(:,2), model.Location(:,3),...
    100,Color,'filled','O');

set(gca,'Projection', 'perspective');
end

function drawLine(name1,name2,dataPath)
model1 = pcread([dataPath,name1]);
model2 = pcread([dataPath,name2]);

for i = 1:size(model1.Location,1)
    x1 = model1.Location(i,:);
    x2 = model2.Location(i,:);
    plot3( [x1(1),x2(1)] , ...
        [x1(2),x2(2)] , ...
        [x1(3),x2(3)] , 'r-')
end

end
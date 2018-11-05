function displayRegistration(baseName,dir)

%% Handle input
if ~exist('baseName','var') || isempty(baseName)
    baseName = 'modifiedtestSurface';
end
if ~exist('dir','var') || isempty(dir)
    dir = '../data/';
end

dataList = findData(dir,baseName);

%% Load the data
clf
hold on
for i = 1:length(dataList)
    model = pcread([dir,dataList{i}]);
    A = scatter3(model.Location(:,1),model.Location(:,2),model.Location(:,3) );
    A.MarkerFaceColor = [0.5,0.5,0.5].*0;
end
axis equal
view([50,50])
hold off

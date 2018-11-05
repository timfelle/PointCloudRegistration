function DataFiles = findData(datPath,DataName)

List = dir(datPath);
L = {List.name};
DataFiles = L(strncmp(L,DataName,length(DataName)));
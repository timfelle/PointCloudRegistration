function DataFiles = findData(datPath,datName)
%FINDDATA(datPath,datName)
%  This function is designed to find all occurences of the base name
%  defined by datName in the folder datPath.
%
%  See also DIR.

List = dir(datPath);
L = {List.name};
DataFiles = L(strncmp(L,datName,length(datName)));
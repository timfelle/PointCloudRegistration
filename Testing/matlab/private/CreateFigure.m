function F = CreateFigure(Name)
%CREATEFIGURE
%  This function is used to create figures with specified names. If the
%  figures already exists it will be cleared and swaped to.
%  __________________________________________________________________
%  CREATEFIGURE()
%       Creates a single unnamed figure and switches to it.
%
%  CREATEFIGURE(Name)
%       If Name is a string the function will create a single figure with
%       the specified name.
%
%  CREATEFIGURE(Names)
%       If Names is a cell array of strings the function will create N
%       figures with the names specified in Names.
%
%  F = CREATEFIGURE(...)
%       F is a cell array containing all figures created by the function.
%
%  See also FIGURE.


if nargin == 0
    Name = {''};
end
if ~iscell(Name)
    Name = {Name};
end
F = cell(length(Name),1);
for i = 1:length(Name)
    F{i} = findobj('Name',Name{i});
    if isempty(F{i})
        F{i} = figure();
        F{i}.Name = Name{i};
    else
        clf(F{i});
        figure(F{i});
    end
end

if length(F) == 1
    F = F{:};
end
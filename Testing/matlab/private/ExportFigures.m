function ExportFigures(FigureList,ExportLocation,varargin)
%EXPORTFIGURES
%  This function is an automation of exporting figures.
%  __________________________________________________________________
%  EXPORTFIGURES()
%       Exports all figures currently in the Graphical Root in 
%       .eps format to the standard location ./Figures/
%
%  EXPORTFIGURES(FigureList)
%       Exports all figures in the specified list in 
%       .eps format to the standard location: ./Figures/
%       The list should be a list of figure variables.
%
%  EXPORTFIGURES(FigureList,ExportLocation)
%       Exports all figures in the specified list in 
%       .eps format to the specified location ExportLocation
%       The list should be a list of figure variables.
%       The location should be described in a string.
%
%  EXPORTFIGURES(...,'dpi',Integer)
%       Additionally sets the dpi for the exported image.
%
%  EXPORTFIGURES(...,'ext',String)
%       Additionally defines the extension for the output image.
%       Common extension is 'png', 'jpeg', 'pdf' and 'epsc'. 
%       See <a 
%       href="matlab: doc print"
%       >print documentation</a> for the full list.
%
%  EXPORTFIGURES(...,'asp',double)
%       Defines the aspect ratio for the exported figure window.
%
%  See also GROOT, PRINT.

%% Handeling inputs
if (nargin == 0)
    FigureList = get(groot,'Children');
    ExportLocation = './Figures/';
end
if (nargin > 0 && isempty(FigureList))
    FigureList = get(groot,'Children');
end
if (nargin > 1 && ~exist(ExportLocation,'dir'))
    fprintf('\nDirectory not found, created at: %s\n',ExportLocation)
end
if ~strcmp(ExportLocation(end),'/')
    ExportLocation = [ExportLocation,'/'];
end
if nargin > 2
    i=1;
    disp(' ')
    disp('Exporting with userdefined settings:')
    while i < length(varargin)
        if strcmpi(varargin{i},'dpi')
            dpi = ['-r',int2str(varargin{i+1})];
            fprintf(' - DPI: %d\n',varargin{i+1})
            i=i+2;
        elseif strcmpi(varargin{i},'ext')
            ext = varargin{i+1};
            fprintf(' - EXT: %s\n',ext)
            i=i+2;
        elseif strcmpi(varargin{i},'asp')
            asp = varargin{i+1};
            fprintf(' - ASPECT: %5.2f\n',asp)
            i=i+2;
        else
            fprintf('Unknown option: %s\n',varargin{i});
            i=i+2;
        end
    end
end

%% Ensure existence of variables
if isempty(FigureList)
    return
end
if ~exist(ExportLocation,'dir')
    mkdir(ExportLocation)
end
if ~exist('dpi','var')
    dpi = '-r100';
end
if ~exist('ext','var')
    ext = 'epsc';
end


%% Exporting the figures
fprintf('Exported Figures: (Location: %s)\n',ExportLocation)
for i=1:length(FigureList)
    % Handle Name
    if isempty(FigureList(i).Name)
        FigureList(i).Name = sprintf('Figure%d',FigureList(i).Number);
    end
    % Handle docking
    Dock = false;
    if strcmp(FigureList(i).WindowStyle,'docked')
        Dock = true;
        FigureList(i).WindowStyle = 'normal';
        if ~exist('asp','var')
            asp = 1.5;
        end
        drawnow;
    end
    
    if exist('asp','var')
        FigureList(i).Position = [300,100,asp*600,600];
    end

    fprintf(' - %s.%s\n',FigureList(i).Name,ext);
    print(FigureList(i),['-d',ext],...
        [ExportLocation,FigureList(i).Name],dpi);
    
    if Dock
        FigureList(i).WindowStyle = 'docked';
    end
end
end

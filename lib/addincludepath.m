includePath = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'include');
addpath(includePath);

%% find subdirectories in lib 
subdirs = listdir(includePath);

for iSubdir = 1:length(subdirs)
    addpath(subdirs{iSubdir});
end

%% add the path of netcdf toolbox
if ~ exist('netcdf.m', 'file')
    disp('netcdf toolbox is not installed in your system. Attached netcdf toolbox will be added.');
    addpath(fullfile(includePath, 'netcdf_toolbox', 'netcdf'));
    addpath(fullfile(includePath, 'netcdf_toolbox', 'netcdf', 'nctype'));
    addpath(fullfile(includePath, 'netcdf_toolbox', 'netcdf', 'ncutility'));
end

%% add the path of mexcdf 
if ~ exist('nc_byte.m', 'file')
    disp('mexcdf toolbox is not installed in your system. Attached mexcdf toolbox will be added.');
    addpath(fullfile(includePath, 'mexcdf', 'mexnc'));
    addpath(fullfile(includePath, 'mexcdf', 'snctools'));
end

disp('Finish adding include path');
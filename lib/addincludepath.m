% add all the subdirectories in the folder of '../include/'
% History:
%   2019-08-14 Add the comments by Zhenping Yin

includePath = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'include');
addpath(genpath(includePath));

%% add the path of netcdf toolbox
if exist('netcdf.m', 'file') ~= 2
    disp('netcdf toolbox is not installed in your system. Attached netcdf toolbox will be added.');
    addpath(fullfile(includePath, 'netcdf_toolbox', 'netcdf'));
    addpath(fullfile(includePath, 'netcdf_toolbox', 'netcdf', 'nctype'));
    addpath(fullfile(includePath, 'netcdf_toolbox', 'netcdf', 'ncutility'));
end

%% add the path of mexcdf 
if exist('nc_byte.m', 'file') ~= 2
    disp('mexcdf toolbox is not installed in your system. Attached mexcdf toolbox will be added.');
    addpath(fullfile(includePath, 'mexcdf', 'mexnc'));
    addpath(fullfile(includePath, 'mexcdf', 'snctools'));
end

%% add the SQLite JDBC driver to the search path
% details can be found under
% https://ww2.mathworks.cn/help/database/ug/sqlite-jdbc-linux.html
dbFile = 'test.db';
conn = database(dbFile, '', '', 'org:sqlite:JDBC', sprintf('jdbc:sqlite:%s', dbFile));

if strcmpi(conn.Message, 'Unable to find JDBC driver.')
    disp('Add SQLite JDBC to your search path.');

    pathJDBC = fullfile(includePath, 'sqlite-jdbc-3.30.1.jar');
    javaclasspathFilepath = fullfile(prefdir, 'javaclasspath.txt');

    fid = fopen(javaclasspathFilepath, 'a');
    fprintf(fid, '%s\n', pathJDBC);

    fclose(fid);

    disp('MATLAB needs to be **RESTARTED** to activate the settings');
    pause(5);
end

disp('Finish adding include path');
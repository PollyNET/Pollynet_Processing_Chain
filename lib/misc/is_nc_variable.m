function [flag] = is_nc_variable(ncFile, varName)
% IS_NC_VARIABLE test the ncFile whether contains the variable with name of varName.
%
% USAGE:
%    [flag] = is_nc_variable(ncFile, varName)
%
% INPUTS:
%    ncFile: char
%        the path for the input netcdf file.
%    varName: char
%        the variable name you want to search.
%
% OUTPUTS:
%    flag: logical
%        if flag is true, it means the varName was contained in the ncFile.
%        Vice versa.
%
% HISTORY:
%    - 2021-06-13: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

flag = false;

if exist(ncFile, 'file') ~= 2
    warning('Warning in ''is_nc_variable'': input file does not exsit.\n%s', ...
            ncFile);
    return
end

%% determine the file type
[~, ~, ext] = fileparts(ncFile);
if ~ strcmp(ext, '.nc')
    warning(['Warning in ''is_nc_variable'': ' ...
             'input file is not the type of netcdf.\n%s'], ncFile);
    return
end

%% get and search the varName in the ncFile
fileInfo = ncinfo(ncFile);
for iVar = 1:length(fileInfo.Variables)
    if strcmp(fileInfo.Variables(iVar).Name, varName)
        % if found the varName, then return 'true'
        flag = true;
        break;
    end
end

end
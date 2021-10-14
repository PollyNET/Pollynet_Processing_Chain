function [parentFolder] = parentFolder(folder, level)
% PARENTFOLDER return parent folder.
%
% USAGE:
%    [parentFolder] = parentFolder(folder, level)
%
% INPUTS:
%    folder: char
%        folder name.
%    level: integer
%        parent level. 
%        e.g., 1 stands for the direct parent of the folder. 
%              2 stands for second parent of the folder.
%
% OUTPUTS:
%    parentFolder: char
%        parent folder.
%
% HISTORY:
%    - 2018-08-22. First edition by Zhenping
%    - 2018-08-28. Support for unix platform
%
% .. Authors: - zhenping@tropos.de

if ~ exist('level', 'var')
    level = 1;
end

parts = strsplit(folder, filesep);

if level >= length(parts)
    error('level is out of range.');
end

if ispc
    parentFolder = fullfile(parts{1:(end - level)});
elseif isunix
    parentFolder = fullfile(filesep, parts{1:(end - level)});
else
    error('MATLAB:unsupportedPlatform', ...
          'Your platform is not Windows, Linux or UNIX');
end

end

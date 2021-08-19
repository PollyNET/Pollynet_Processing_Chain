function [thisDir] = basedir(pathStr)
% BASEDIR retrieve the base directory for the input path Str.
%     'C:\Users\zhenping'  --->  'zhenping'
%
% USAGE:
%    [thisDir] = basedir(pathStr)
%
% INPUTS:
%    pathStr: char
%        full path name.
%
% OUTPUTS:
%    thisDir: char
%        base directory
%
% HISTORY:
%    - 2021-06-21: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

if ~ ischar(pathStr)
    error('Invalid input.');
end

[~, thisDir, ~] = fileparts(pathStr);

end
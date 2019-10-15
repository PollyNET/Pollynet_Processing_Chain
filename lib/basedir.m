function [thisDir] = basedir(pathStr)
%basedir retrieve the base directory for the input path Str.
%        'C:\Users\zhenping'  --->  'zhenping'
%   Example:
%       [thisDir] = basedir(pathStr)
%   Inputs:
%       pathStr: char
%           full path name.
%   Outputs:
%       thisDir: char
%           base directory
%   History:
%       2019-10-15. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if ~ ischar(pathStr)
    error('Invalid input.');
end

[~, thisDir, ~] = fileparts(pathStr);

end
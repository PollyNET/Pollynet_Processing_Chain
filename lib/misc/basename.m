function [basename] = basename(fileFullpath)
% BASENAME cut the basename from the file fullpath. 
%
% USAGE:
%    [basename] = basename(fileFullpath)
%
% INPUTS:
%    fileFullpath: char
%        fullpath.
% OUTPUTS:
%    basename: char
%        basename of the file
%
% HISTORY:
%    2018-08-22. First edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

if ~ ischar(fileFullpath)
    error('Input filename should be a char array');
end

parts = strsplit(fileFullpath, filesep);
basename = parts{end};

end
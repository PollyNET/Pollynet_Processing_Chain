function [basename] = basename(fileFullpath)
%basename retrieve the basename from the file fullpath. 
%	Example:
%		[basename] = basename(fileFullpath)
%	Inputs:
%		fileFullpath: char
%			fullpath.
%	Outputs:
%		basename: char
%			basename of the file
%	History:
%		2018-08-22. First edition by Zhenping
%	Contact:
%		zhenping@tropos.de

if ~ ischar(fileFullpath)
	error('Input filename should be a char array');
end

parts = strsplit(fileFullpath, filesep);
basename = parts{end};

end
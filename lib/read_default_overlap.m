function [height, overlap] = read_default_overlap(file)
%read_default_overlap Read the overlap function from file.
%   Example:
%       [height, overlap] = read_default_overlap(file)
%   Inputs:
%       file: char
%           overlap file. The format of this file can be referred to doc/polly_defaults.md
%   Outputs:
%       height: array
%           height for each range bin. [m] 
%       overlap: array
%           overlap function.
%   History:
%       2018-12-21. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

height = [];
overlap = [];

if ~ exist(file, 'file')
    warning('overlap file does not exist.\n%s\n', file);
    return;
end

data = dlmread(file, ',', 1, 0);
height = transpose(data(:, 1));
overlap = transpose(data(:, 2));

end
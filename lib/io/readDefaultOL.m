function [height, overlap] = readDefaultOL(file)
%READDEFAULTOL Read default overlap function from file.
%
% USAGE:
%    [height, overlap] = readDefaultOL(file)
%
% INPUTS:
%    file: char
%        overlap file. The format of this file can be referred to 
%        doc/polly_defaults.md
%
% OUTPUTS:
%    height: array
%        height for each range bin. [m] 
%    overlap: array
%        overlap function.
%
% HISTORY:
%    - 2021-05-22: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

height = [];
overlap = [];

if exist(file, 'file') ~= 2
    warning('overlap file does not exist.\n%s\n', file);
    return;
end

data = dlmread(file, ',', 1, 0);
height = transpose(data(:, 1));
overlap = transpose(data(:, 2));

end
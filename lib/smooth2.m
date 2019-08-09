function res = smooth2(data, win_m, win_n)
%SMOOTH2 smooth matrix with running mean window.
%   Usage:
%       res = smooth2(data, win_m, win_n)
%   Inputs:
%       data: matrix
%           input data.
%       win_m: int32
%           span along the 1-dimension
%       win_n: int32
%           span along the 2-dimension
%   Outputs:
%       res: matrix
%           smoothed data
%   History:
%       2018-02-22. First edition by Zhenping
%   Copyright:
%       Ground-based remote sensing group. (TROPOS)

if nargin < 3 
    error('Not enough inputs!');
end

if ~ ismatrix(data) 
    error('data is not a matrix.');
end

flag_isnan = isnan(data);
[m, n] = size(data);

for iN = 1:n
    data(:, iN) = smooth(data(:, iN), win_m, 'moving');
end

data(flag_isnan) = NaN;

for iM = 1:m
    data(iM, :) = transpose(smooth(data(iM, :), win_n, 'moving'));
end

res = data;
res(flag_isnan) = NaN;

end
function res = smooth2(data, win_m, win_n, flagMatrix)
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
%       flagMatrix: logical
%           whether to calculate the smoothing in a matrix way, which is much 
%           faster than by loop.
%   Outputs:
%       res: matrix
%           smoothed data
%   History:
%       2018-02-22. First edition by Zhenping
%       2019-09-05. Add the 'flagMatrix' to speed up the 2-D smoothing
%   Contact:
%       zhenping@tropos.de

if nargin < 3 
    error('Not enough inputs!');
end

if ~ ismatrix(data) 
    error('data is not a matrix.');
end

if ~ exist('flagMatrix', 'var')
    flagMatrix = true;
end

if flagMatrix
    % 2-D smoothing with using matrix calculus
    Nr = floor(win_m / 2);
    Nc = floor(win_n / 2);

    res = smooth2a(data, Nr, Nc);
    
else
    % 2-D smoothing by using matlab build-in smooth function
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

end
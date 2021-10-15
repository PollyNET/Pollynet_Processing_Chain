function [filename] = rmext(file)
% RMEXT remove file extension.
%
% USAGE:
%    [filename] = rmext(file)
%
% INPUTS:
%    file: char
%        file.
%        e.g., 'polly_data.txt'
%
% OUTPUTS:
%    filename: char
%        if there is no extension label, the 'file' will be treated to be no 
%        extension then it will be directly returned. Otherwise, the 
%        extension will be removed.
%        e.g., 'polly_data'
%
% HISTORY:
%    - 2021-06-13: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

thisBasename = basename(file);

res = strsplit(thisBasename, '.');

if length(res) >= 3
    filename = strjoin(res(1:(end - 1)), '.');
elseif length(res) == 2
    filename = res{1};
else
    filename = thisBasename;
end

end
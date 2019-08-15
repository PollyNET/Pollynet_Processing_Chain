function [filename] = rmext(file)
%RMEXT remove the file extension.
%   Example:
%       [filename] = rmext(file)
%   Inputs:
%       file: char
%           file.
%           e.g., 'polly_data.txt'
%   Outputs:
%       filename: char
%           if there is no extension label, the 'file' will be treated to be no 
%           extension then it will be directly returned. Otherwise, the 
%           extension will be removed.
%           e.g., 'polly_data'
%   History:
%       2018-12-29. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de
    
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
function [] = diaryon(file)
%diaryon Activate the diary function.
%   Example:
%       [] = diaryon(file)
%   Inputs:
%       file: char
%           log file.
%   Outputs:
%       
%   History:
%       2018-12-28. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if ~ exist(file, 'file')
    fprintf('Create %s for writing log info.\n', file);
    fid = fopen(file, 'w');
    fclose(fid);
end

diary(file);

end
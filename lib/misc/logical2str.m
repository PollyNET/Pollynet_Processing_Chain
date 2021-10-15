function [strOut] = logical2str(logicalIn, replaceString)
% LOGICAL2STR convert logical array to cell array with replacing 0/1 to true/false or yes/no.
%
% USAGE:
%   [strOut] = logical2str(logicalIn, replaceString)
%
% INPUTS:
%   logicalIn: logical
%   replaceString: char
%       If set 'yes', the true will be replaced with yes. Otherwise, 
%       true will be replaced with true.
%
% OUTPUTS:
%   strOut: cell
%       char array for each logical element
%
% HISTORY:
%    - 2021-06-13: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

if ~ exist('replaceString', 'var')
    replaceString = 'true';
end

strOut = cell(size(logicalIn));

switch lower(replaceString)
case 'true'
    for indx = 1:numel(logicalIn)
        if logicalIn(indx)
            strOut{indx} = 'true';
        else
            strOut{indx} = 'false';
        end
    end
case 'yes'
    for indx = 1:numel(logicalIn)
        if logicalIn(indx)
            strOut{indx} = 'yes';
        else
            strOut{indx} = 'no';
        end
    end
otherwise
    error('Unknown replaceString. (true or yes)');
end

end
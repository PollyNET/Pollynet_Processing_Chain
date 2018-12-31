function [strOut] = logical2str(logicalIn, replaceString)
%logical2str convert the logical array to cell array with replace the 0/1 to true/false or yes/no.
%   Example:
%       [strOut] = logical2str(logicalIn, replaceString)
%   Inputs:
%       logicalIn: logical
%       replaceString: char
%           If set 'yes', the true will be replaced with yes. Otherwisem true will be replaced with true.
%   Outputs:
%       strOut: cell
%   History:
%       2018-12-30. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

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
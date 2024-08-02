function [charArr] = cell2char(matCell)
% CELL2CHAR convert matlab cell to char array.
%
% USAGE:
%    [charArr] = cell2char(matCell)
%
% INPUTS:
%    matCell: cell
%
% OUTPUTS:
%    charArr: char
%
% HISTORY:
%    2024-08-01: first edition by Zhenping
% .. Authors: - zp.yin@whu.edu.cn

charArr = '';
for iCell = 1:numel(matCell)

    thisCell = matCell{iCell};
    thisCharArr = '';

    if iscell(thisCell)

        thisCharArr = cell2char(thisCell);

    elseif islogical(thisCell)

        thisCharArr = num2str(double(thisCell));

    elseif ischar(thisCell)

        thisCharArr = thisCell;

    elseif isstring(thisCell)

        thisCharArr = char(thisCell);

    elseif isstruct(thisCell)

        thisCharArr = struct2char(thisCell);

    else

        if isnumeric(thisCell)
            
            if size(thisCell, 1) > 1
                thisCharArr = num2str(reshape(thisCell, 1, size(thisCell, 1) * size(thisCell, 2)));
            else
                thisCharArr = num2str(thisCell);
            end
        end
    end

    charArr = strcat(charArr, sprintf('[%d]', iCell), ',', thisCharArr, ',');
end

end
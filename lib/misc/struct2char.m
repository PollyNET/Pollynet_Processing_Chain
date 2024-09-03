function [charArr] = struct2char(matStruct)
% STRUCT2CHAR convert matlab struct to char array.
%
% USAGE:
%    [charArr] = struct2char(matStruct)
%
% INPUTS:
%    matStruct: struct
%
% OUTPUTS:
%    charArr: char
%
% HISTORY:
%    2024-08-01: first edition by Zhenping
% .. Authors: - zp.yin@whu.edu.cn

charArr = '';
for fn = fieldnames(matStruct)'

    thisField = matStruct.(fn{1});
    thisCharArr = '';

    if iscell(thisField)

        thisCharArr = cell2char(thisField);

    elseif islogical(thisField)

        thisCharArr = num2str(double(thisField));

    elseif ischar(thisField)

        thisCharArr = thisField;

    elseif isstring(thisField)

        thisCharArr = char(thisField);

    else

        if isnumeric(thisField)
            
            if size(thisField, 1) > 1
                thisCharArr = num2str(reshape(thisField, 1, size(thisField, 1) * size(thisField, 2)));
            else
                thisCharArr = num2str(thisField);
            end
        end
    end

    charArr = strcat(charArr, fn{1}, ': ', thisCharArr, ',');
end

end
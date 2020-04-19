function [figPos] = subfigPos(pos, nRow, nColumn, xPad, yPad)
%SUBFIGPOS calculate the normalized position of each subfigure.
%Example:
%   [figPos] = subfigPos(pos, nRow, nColumn, xpad, ypad)
%Inputs:
%   pos: 4-element array
%       [left, bottom, width, height]
%   nRow: integer
%       number of the total rows. (default, 1)
%   nColumn: integer
%       number of the total columns. (default, 1)
%   xPad: numeric
%       x-padding
%   yPad: numeric
%       y-padding
%Outputs:
%   figPos: matrix
%       returned postition of each subfigures. The first figure is the 
%       top-right one and as followed by from left-to-right and 
%       top-to-base.
%History:
%   2018-11-09. First edition by Zhenping
%   2019-12-15. Enable set the x-y padding.
%Contact:
%   zhenping@tropos.de

if ~ exist('xPad', 'var')
    xPad = 0;
end

if ~ exist('yPad', 'var')
    yPad = 0;
end

figPos = zeros(nRow * nColumn, 4);

leftMargin = pos(1);
rightMargin = 1 - pos(1) - pos(3);
topMargin = 1 - pos(2) - pos(4);
baseMargin = pos(2);

widthCol = (1 - leftMargin - rightMargin - (nColumn - 1) * xPad) / nColumn;
widthRow = (1 - topMargin - baseMargin - (nRow - 1) * yPad) / nRow;
for iRow = 1:nRow
    for iCol = 1:nColumn
        xPos = leftMargin + (iCol - 1) * (widthCol + xPad);
        yPos = baseMargin + (nRow - iRow) * (widthRow + yPad);
        figPos((iRow - 1)*nColumn + iCol, :) = [xPos, yPos, widthCol, widthRow];
    end 
end

end

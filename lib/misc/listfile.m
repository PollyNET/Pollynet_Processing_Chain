function [files, filesize] = listfile(inPath, exppat, depth)
% LISTFILE list all qualified files in path.
%
% USAGE:
%    % Usecase 1: search matlab file at 'Desktop'
%    a = listfile('~/Desktop', '*.m');
%    % Usecase 2: search matlab file with folder depth of 2
%    a = listfile('~/Desktop', '*.m', 2);
%
% INPUTS:
%    inPath: char
%        the path for searching.
%    exppat: [optional] 
%        expression pattern for the searching.
%    depth: [optional]
%        recursive searching depth
%
% OUTPUTS:
%    files: cell array
%        absolute paths of the matched items.
%    filesize: cell array
%        the size the searched items. [bytes]
%
% HISTORY:
%    - 2018-07-25: First edition by Zhenping.
%    - 2018-09-14: Add recursive searching depth.
%    - 2019-09-03: Add the output of filesize.
%    - 2020-07-18: Stop interative search when searched the special folder of '..' or '.'
%
% .. Authors: - zhenping@tropos.de

files = cell(0);
filesize = cell(0);

if ~ exist(inPath, 'dir')
    warning('%s is not a valid directory.', inPath);
    return
end

if ~ exist('depth', 'var')
    depth = 1;
end

tmp = dir(inPath);

% no items in this directory
if isempty(tmp)
    return;
end

% recursively searching
indx = 0;
for iItem = 1:length(tmp)
    if ~ tmp(iItem).isdir
        if exist('exppat', 'var')
            if regexp(tmp(iItem).name, exppat)
                % if there are required items, return the results
                indx = indx + 1;
                files{indx} = fullfile(inPath, tmp(iItem).name);
                filesize{indx} = tmp(iItem).bytes;
            end
        else
            indx = indx + 1;
            files{indx} = fullfile(inPath, tmp(iItem).name);
            filesize{indx} = tmp(iItem).bytes;
        end
    else
        % if there is no matched item, go into the subdirectory
        if (depth > 1) && all(~ strcmpi(tmp(iItem).name, {'.', '..'}))
            [filesTmp, filesizeTmp] = listfile(fullfile(inPath, tmp(iItem).name), exppat, depth - 1);
            files = cat(2, files, filesTmp);
            filesize = cat(2, filesize, filesizeTmp);
        end
    end
end

end
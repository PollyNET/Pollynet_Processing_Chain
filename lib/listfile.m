function [files, filesize] = listfile(path, exppat, depth)
%LISTFILE list all the qualified files in path.
%Usage:
%   a = listfile('~/Desktop', '*.m');
%Inputs:
%   path: char
%       the path for searching.
%   exppat: [optional] 
%       expression pattern for the searching.
%   depth: [optional]
%       recursive searching depth
%Outputs:
%   files: cell array
%       the searched items.
%   filesize: cell array
%       the size the searched items. [bytes]
%History:
%   2018-07-25. First edition by Zhenping.
%   2018-09-14. Add recursive searching depth.
%   2019-09-03. Add the output of filesize
%Contact:
%   zhenping@tropos.de

files = cell(0);
filesize = cell(0);

if ~ exist(path, 'dir')
    warning('%s is not a valid directory.', path);
    return
end

if ~ exist('depth', 'var')
    depth = 1;
end

tmp = dir(path);

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
                % if there is required items, return the results
                indx = indx + 1;
                files{indx} = fullfile(path, tmp(iItem).name);
                filesize{indx} = tmp(iItem).bytes;
            end
        else
            indx = indx + 1;
            files{indx} = fullfile(path, tmp(iItem).name);
            filesize{indx} = tmp(iItem).bytes;
        end
    else
        % if there is no matched items, go into the subdirectory
        if depth > 1
            [filesTmp, filesizeTmp] = listfile(fullfile(path, tmp(iItem).name), exppat, depth - 1);
            files = cat(2, files, filesTmp);
            filesize = cat(2, filesize, filesizeTmp);
        end
    end
end

end
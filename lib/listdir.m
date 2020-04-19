function [dirs] = listdir(path, exppat, depth)
%LISTDIR list all the valid directory in path.
%Usage:
%   a = listdir('~/Desktop');
%Inputs:
%   path: char
%       the path for searching.
%   exppat: [optional] 
%       expression pattern for the search.
%   depth: [optional]
%       recursive searching depth.
%Outputs:
%   dirs: cell array
%       the searched items.
%History:
%   2018-05-18. First edition by Zhenping.
%   2018-09-14. Add the depth parameter for supporting recursive searching.
%   2018-11-11. Remove the searched . and .. folder. Rearrange the search 
%               logic
%Contact:
%   zhenping@tropos.de

dirs = cell(0);

if ~ exist(path, 'dir')
    warning('%s is not a valid directory.', path);
    return
end

if ~ exist('depth', 'var')
    depth = 1;
end

tmp = dir(path);
tmp(ismember({tmp.name}, {'.', '..'})) = [];   % remove the . and .. folder

% no items in this directory
if isempty(tmp)
    return;
end

for iItem = 1:length(tmp)
    if tmp(iItem).isdir
        if exist('exppat', 'var')
            % if there is required items, return the results
            if regexp(tmp(iItem).name, exppat)
                dirs{end + 1} = fullfile(path, tmp(iItem).name);
                if depth > 1
                    dirs = cat(2, dirs, ...
                    listdir(fullfile(path, tmp(iItem).name), exppat, depth-1));
                else
                    continue;
                end

            elseif depth > 1
                dirs = cat(2, dirs, ...
                    listdir(fullfile(path, tmp(iItem).name), exppat, depth-1));
            else 
                continue;
            end
        else
            % if no required items, go inside of the current directory
            if depth == 1
                dirs{end + 1} = fullfile(path, tmp(iItem).name);
            else 
                dirs = cat(2, dirs, listdir(fullfile(path, tmp(iItem).name), ...
                exppat, depth-1));
            end
        end
    end
end

end
function [flag] = download_radiosonde_list()
%DOWNLOAD_RADIOSONDE_LIST Download global radiosonde site list.
%Example:
%   [flag] = download_radiosonde_list()
%Inputs:
%Outputs:
%   flag: logical
%       return status of the function.
%History:
%   2018-12-22. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

url = 'https://www1.ncdc.noaa.gov/pub/data/igra/igra2-station-list.txt';
saveFile = 'radiosonde-station-list.txt';
saveFolder = fullfile(parentFolder(mfilename('fullpath'), 2), 'doc');

if ispc
    status = system(sprintf('curl -o %s %s', ...
                            fullfile(saveFolder, saveFile), url));
    if status ~= 0
        error(['Error in calling curl in window cmd. ' ...
               'Please make sure curl is in the searching path.']);
    end
elseif isunix
    status = system(sprintf('wget -qO %s %s', ...
                            fullfile(saveFolder, saveFile), url));
end

if status == 0
    flag = true;
    fprintf('Updating the radiosonde-station-list successfully!\n');
else
    fprintf(['Failure in updating the radiosonde-station-list.\n' ...
             'Try to debug with %s\n'], sprintf('wget -qO %s %s', ...
             fullfile(saveFolder, saveFile), url));
    flag = false;
end

end
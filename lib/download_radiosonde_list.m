function [flag] = download_radiosonde_list()
%download_radiosonde_list Download global radiosonde site list.
%   Example:
%       [flag] = download_radiosonde_list()
%   Inputs:
%       
%   Outputs:
%       flag
%   History:
%       2018-12-22. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

url = 'https://www1.ncdc.noaa.gov/pub/data/igra/igra2-station-list.txt';
saveFile = 'radiosonde-station-list.txt';
saveFolder = fullfile(parentFolder(mfilename('fullpath'), 2), 'doc');

status = system(sprintf('curl -o %s %s', fullfile(saveFolder, saveFile), url));

if status == 0
    flag = true;
    fprintf('Updating the radiosonde-station-list successfully!\n');
else
    fprintf('Failure in updating the radiosonde-station-list.\nTry to debug with %s\n', sprintf('curl -o %s %s', fullfile(saveFolder, saveFile), url));
    flag = false;
end

end
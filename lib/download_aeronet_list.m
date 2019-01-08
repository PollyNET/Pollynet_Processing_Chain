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

url = 'https://aeronet.gsfc.nasa.gov/aeronet_locations_v3.txt';
saveFile = 'AERONET-station-list.txt';
saveFolder = fullfile(parentFolder(mfilename('fullpath'), 2), 'doc');

if ispc
    status = system(sprintf('curl -o %s %s', fullfile(saveFolder, saveFile), url));
    if status ~= 0
        error('Error in calling curl in window cmd. Please make sure curl is in the searching path.');
    end
elseif isunix
    status = system(sprintf('wget -qO %s %s', fullfile(saveFolder, saveFile), url));
end

if status == 0
    flag = true;
    fprintf('Updating the AERONET-station-list successfully!\n');
else
    fprintf('Failure in updating the AERONET-station-list.\nTry to debug with %s\n', sprintf('wget -qO %s %s', fullfile(saveFolder, saveFile), url));
    flag = false;
end

end
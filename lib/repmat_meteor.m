function [temperature, pressure, globalAttri] = repmat_meteor(mTime, alt, gdas1site, gdas1folder)
%repmat_meteor Read GDAS1 meteorological data, then repmat it to the lidar measurment grids.
%   Example:
%       [temperature, pressure, globalAttri] = repmat_meteor(mTime, alt, gdas1site, gdas1folder)
%   Inputs:
%       mTime: array
%           datetime for each polly profile. [datenum] 
%       alt: array
%           altitude (above the mean sea level). [m] 
%       gdas1site: char
%           gdas1 site. You can find the site by checking the doc/gdas1_site_list.txt 
%       gdas1folder: char
%           gdas1 main folder.
%   Outputs:
%       temperature: matrix
%           air temperature. [°C]
%       pressure: matrix
%           air pressure. [hPa]
%       globalAttri: struct
%           source: char
%               the source of meteorological data.
%   History:
%       2018-12-25. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

temperature = [];
pressure = [];
globalAttri = struct();
globalAttri.source = 'none';

[altRaw, tempRaw, presRaw, ~] = read_gdas1(mean(mTime), gdas1site, gdas1folder);
if isempty(altRaw)
    [altRaw, ~, ~, tempRaw, presRaw] = atmo(alt(end) + 1, 0.03, 1);
    altRaw = altRaw * 1e3;
    globalAttri.source = 'standard_atmosphere';
else
    globalAttri.source = 'gdas1';
end

% interp the meteorological parameters to lidar grid
temp = interp_meteor(altRaw, tempRaw, alt);
pres = interp_meteor(altRaw, presRaw, alt);

% repmat the signal profile to the whole lidar grid
temperature = repmat(transpose(temp), 1, numel(mTime));
pressure = repmat(transpose(pres), 1, numel(mTime));

end
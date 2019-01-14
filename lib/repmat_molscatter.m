function [molBsc355, molExt355, molBsc532, molExt532, molBsc1064, molExt1064, globalAttri] = repmat_molscatter(mTime, alt, gdas1site, gdas1folder)
%repmat_molscatter Read GDAS1 meteorological data and calculate molecule optical properties, then repmat it to the lidar measurment grids.
%   Example:
%       [molBsc355, molExt355, molBsc532, molExt532, molBsc1064, molExt1064, globalAttri] = repmat_molscatter(mTime, alt, gdas1site, gdas1folder)
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
%       molBsc355: matrix
%           molecule backscatter coefficient at 355 nm with a size of numel(alt)*numel(mTime). [m^{-1}Sr^{-1}] 
%       molExt355: matrix
%           molecule extinction coefficient at 355 nm with a size of numel(alt)*numel(mTime). [m^{-1}Sr^{-1}]  
%       molBsc532: matrix
%           molecule backscatter coefficient at 532 nm with a size of numel(alt)*numel(mTime). [m^{-1}Sr^{-1}] 
%       molExt532: matrix
%           molecule extinction coefficient at 532 nm with a size of numel(alt)*numel(mTime). [m^{-1}Sr^{-1}]  
%       molBsc1064: matrix
%           molecule backscatter coefficient at 1064 nm with a size of numel(alt)*numel(mTime). [m^{-1}Sr^{-1}] 
%       molExt1064: matrix
%           molecule extinction coefficient at 1064 nm with a size of numel(alt)*numel(mTime). [m^{-1}Sr^{-1}]  
%       globalAttri: struct
%           source: char
%               the source of meteorological data.
%           datetime: float
%               the time stamp for the meteorological data.
%   History:
%       2018-12-25. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

molBsc355 = [];
molExt355 = [];
molBsc532 = [];
molExt532 = [];
molBsc1064 = [];
molExt1064 = [];
globalAttri = struct();
globalAttri.source = 'none';
globalAttri.datetime = [];

[altRaw, tempRaw, presRaw, ~, gdas1File] = read_gdas1(mean(mTime), gdas1site, gdas1folder);
if isnan(altRaw(1))
    [altRaw, ~, ~, tempRaw, presRaw] = atmo((alt(end) + 1)/1000, 0.03, 1);
    altRaw = altRaw * 1e3;
    presRaw = presRaw / 1e2;   % convert to hPa
    tempRaw = tempRaw - 273.17;   % convert to C
    globalAttri.source = 'standard_atmosphere';
else
    globalAttri.source = 'gdas1';
    globalAttri.datetime = gdas1FileTimestamp(gdas1File);
end

% interp the meteorological parameters to lidar grid
temperature = interp_meteor(altRaw, tempRaw, alt);
pressure = interp_meteor(altRaw, presRaw, alt);

% calculate the molecule optical properties
[thisMolBsc355, thisMolExt355] = rayleigh_scattering(355, pressure, temperature + 273.17, 380, 70);
[thisMolBsc532, thisMolExt532] = rayleigh_scattering(532, pressure, temperature + 273.17, 380, 70);
[thisMolBsc1064, thisMolExt1064] = rayleigh_scattering(1064, pressure, temperature + 273.17, 380, 70);

% repmat the signal profile to the whole lidar grid
molBsc355 = repmat(transpose(thisMolBsc355), 1, numel(mTime));
molExt355 = repmat(transpose(thisMolExt355), 1, numel(mTime));
molBsc532 = repmat(transpose(thisMolBsc532), 1, numel(mTime));
molExt532 = repmat(transpose(thisMolExt532), 1, numel(mTime));
molBsc1064 = repmat(transpose(thisMolBsc1064), 1, numel(mTime));
molExt1064 = repmat(transpose(thisMolExt1064), 1, numel(mTime));

end
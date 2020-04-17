function [molBsc355, molExt355, molBsc532, molExt532, molBsc1064, molExt1064, globalAttri, molBsc387, molExt387, molBsc607, molExt607] = repmat_molscatter(mTime, alt, meteorInfo)
%REPMAT_MOLSCATTER Read GDAS1 meteorological data and calculate molecule optical 
%properties, then repmat it to the lidar measurment grids.
%   Example:
%       [molBsc355, molExt355, molBsc532, molExt532, molBsc1064, molExt1064, 
%       globalAttri, molBsc387, molExt387, molBsc607, molExt607] = 
%       repmat_molscatter(mTime, alt, meteorInfo)
%   Inputs:
%       mTime: array
%           datetime for each polly profile. [datenum] 
%       alt: array
%           altitude (above the mean sea level). [m] 
%       meteorInfo: struct
%           meteorDataSource: str
%               meteorological data type.
%               e.g., 'gdas1', 'standard_atmosphere', 'websonde', 'radiosonde'
%           gdas1Site: str
%               the GDAS1 site for the current campaign.
%           gdas1_folder: str
%               the main folder of the GDAS1 profiles.
%           radiosondeSitenum: integer
%               site number, which can be found in 
%               doc/radiosonde-station-list.txt. You can update the list with 
%               using download_radiosonde_list.m
%           radiosondeFolder: str
%               the folder of the sonding files. 
%   Outputs:
%       molBsc355: matrix
%           molecule backscatter coefficient at 355 nm with a size of 
%           numel(alt)*numel(mTime). [m^{-1}Sr^{-1}] 
%       molExt355: matrix
%           molecule extinction coefficient at 355 nm with a size of 
%           numel(alt)*numel(mTime). [m^{-1}Sr^{-1}]  
%       molBsc532: matrix
%           molecule backscatter coefficient at 532 nm with a size of 
%           numel(alt)*numel(mTime). [m^{-1}Sr^{-1}] 
%       molExt532: matrix
%           molecule extinction coefficient at 532 nm with a size of 
%           numel(alt)*numel(mTime). [m^{-1}Sr^{-1}]  
%       molBsc1064: matrix
%           molecule backscatter coefficient at 1064 nm with a size of 
%           numel(alt)*numel(mTime). [m^{-1}Sr^{-1}] 
%       molExt1064: matrix
%           molecule extinction coefficient at 1064 nm with a size of 
%           numel(alt)*numel(mTime). [m^{-1}Sr^{-1}]  
%       globalAttri: struct
%           source: char
%               the source of meteorological data.
%           datetime: float
%               the time stamp for the meteorological data.
%       molBsc387: matrix
%           molecule backscatter coefficient at 387 nm with a size of 
%           numel(alt)*numel(mTime). [m^{-1}Sr^{-1}] 
%       molExt387: matrix
%           molecule extinction coefficient at 387 nm with a size of 
%           numel(alt)*numel(mTime). [m^{-1}Sr^{-1}]  
%       molBsc607: matrix
%           molecule backscatter coefficient at 607 nm with a size of 
%           numel(alt)*numel(mTime). [m^{-1}Sr^{-1}] 
%       molExt607: matrix
%           molecule extinction coefficient at 607 nm with a size of 
%           numel(alt)*numel(mTime). [m^{-1}Sr^{-1}]  
%   History:
%       2018-12-25. First Edition by Zhenping
%       2019-08-03. Add the output of molecular backscatter and extinction at 
%                   387 and 407 nm.
%   Contact:
%       zhenping@tropos.de

globalAttri = struct();
globalAttri.source = 'none';
globalAttri.datetime = [];

% redistribute the meteorological data to 30-s intervals.
[altRaw, tempRaw, presRaw, ~, attri] = read_meteor_data(...
                mean(mTime), alt, ...
                'meteorDataSource', meteorInfo.meteorDataSource, ...
                'gdas1Site', meteorInfo.gdas1Site, ...
                'gdas1_folder', meteorInfo.gdas1_folder, ...
                'radiosondeSitenum', meteorInfo.radiosondeSitenum, ...
                'radiosondeFolder', meteorInfo.radiosondeFolder, ...
                'radiosondeType', meteorInfo.radiosondeType);
globalAttri.source = attri.dataSource;
globalAttri.datetime = attri.datetime;

% interp the parameters
temperature = interp_meteor(altRaw, tempRaw, alt);
pressure = interp_meteor(altRaw, presRaw, alt);

% calculate the molecule optical properties
[thisMolBsc355, thisMolExt355] = rayleigh_scattering(355, pressure, ...
        temperature + 273.17, 380, 70);
[thisMolBsc532, thisMolExt532] = rayleigh_scattering(532, pressure, ...
        temperature + 273.17, 380, 70);
[thisMolBsc1064, thisMolExt1064] = rayleigh_scattering(1064, pressure, ...
        temperature + 273.17, 380, 70);
[thisMolBsc387, thisMolExt387] = rayleigh_scattering(387, pressure, ...
        temperature + 273.17, 380, 70);
[thisMolBsc607, thisMolExt607] = rayleigh_scattering(607, pressure, ...
        temperature + 273.17, 380, 70);

% repmat the signal profile to the whole lidar grid
molBsc355 = repmat(transpose(thisMolBsc355), 1, numel(mTime));
molExt355 = repmat(transpose(thisMolExt355), 1, numel(mTime));
molBsc532 = repmat(transpose(thisMolBsc532), 1, numel(mTime));
molExt532 = repmat(transpose(thisMolExt532), 1, numel(mTime));
molBsc1064 = repmat(transpose(thisMolBsc1064), 1, numel(mTime));
molExt1064 = repmat(transpose(thisMolExt1064), 1, numel(mTime));
molBsc387 = repmat(transpose(thisMolBsc387), 1, numel(mTime));
molExt387 = repmat(transpose(thisMolExt387), 1, numel(mTime));
molBsc607 = repmat(transpose(thisMolBsc607), 1, numel(mTime));
molExt607 = repmat(transpose(thisMolExt607), 1, numel(mTime));

end
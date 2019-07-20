function [temp, pres, relh, meteorAttri] = arielle_readmeteor(data, config)
%arielle_readmeteor Read meteorological data.
%   Example:
%       [temp, pres, relh, meteorAttri] = arielle_readmeteor(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       temp: matrix (cloudfreegroups * height)
%           temperature for each range bin. [C]
%       pres: matrix (cloudfreegroups * height)
%           pressure for each range bin. [hPa]
%       rh: matrix (cloudfreegroups * height)
%           relative humidity for each range bin. [%]
%       meteorAttri: struct
%           dataSource: cell
%               The data source used in the data processing for each cloud-free group.
%           URL: cell
%               The data file info for each cloud-free group.
%           datetime: array
%               datetime label for the meteorlogical data.
%   History:
%       2018-12-22. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo 

temp = [];
pres = [];
relh = [];
meteorAttri.dataSource = cell(0);
meteorAttri.URL = cell(0);
meteorAttri.datetime = [];

if isempty(data.rawSignal)
    return;
end

%% read meteorological data for each cloud-free group
for iGroup = 1:size(data.cloudFreeGroups, 1)
    measTime = mean(data.mTime(data.cloudFreeGroups(iGroup, :)));

    % read the meteorological data
    [altRaw, tempRaw, presRaw, relhRaw, attri] = read_meteor_data(measTime, data.alt, config);
    meteorAttri.dataSource{end + 1} = attri.dataSource;
    meteorAttri.URL{end + 1} = attri.URL;
    meteorAttri.datetime = [meteorAttri.datetime, attri.datetime];

    % interp the parameters
    thistemp = interp_meteor(altRaw, tempRaw, data.alt);
    thispres = interp_meteor(altRaw, presRaw, data.alt);
    thisrelh = interp_meteor(altRaw, relhRaw, data.alt);

    % concatenate the parameters
    temp = cat(1, temp, thistemp);
    pres = cat(1, pres, thispres);
    relh = cat(1, relh, thisrelh);
end

end
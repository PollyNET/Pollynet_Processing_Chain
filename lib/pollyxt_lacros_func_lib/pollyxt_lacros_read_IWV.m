function [IWV, globalAttri] = pollyxt_lacros_read_IWV(data, config)
%pollyxt_lacros_read_IWV read integrated water vapor from external instruments, like Cimel sunphotometer and MWR.
%   Example:
%       [IWV, globalAttri] = pollyxt_lacros_read_IWV(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       IWV: array
%           integrated water vapor. (kg * m^{-2})
%       globalAttri:
%           source: char
%               data source. ('AERONET', 'MWR' or else)
%           site: char
%               measurement site.
%           datetime: array
%               datetime of applied IWV.
%           PI: char
%           contact: char
%   History:
%       2018-12-26. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global campaignInfo

IWV = [];
globalAttri = struct();
globalAttri.source = 'none';
globalAttri.site = '';
globalAttri.datetime = [];
globalAttri.PI = '';
globalAttri.contact = '';

if isempty(data.rawSignal)
    return;
end

%% retrieve instrument info
switch lower(config.IWV_instrument)
case 'aeronet'
    globalAttri.source = 'AERONET';
    globalAttri.site = config.AERONETSite;
    globalAttri.PI = data.AERONET.AERONETAttri.PI;
    globalAttri.contact = data.AERONET.AERONETAttri.contact;
case 'mwr'
    globalAttri.source = 'MWR';
    globalAttri.site = campaignInfo.location;
    globalAttri.PI = 'Patric Seifert';
    globalAttri.contact = 'seifert@tropos.de';
end

%% retrieve data
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisIWV = NaN;
    thisDatetime = NaN;

    switch lower(config.IWV_instrument)
    case 'aeronet'
        if isempty(data.AERONET.IWV)
            fprintf('No IWV data at %s, %s.\n', datestr(data.mTime(1), 'yyyy-mm-dd'), campaignInfo.location);
            IWV = NaN(1, size(data.cloudFreeGroups, 1));
            globalAttri.datetime = NaN(1, site(data.cloudFreeGroups, 1));
            return;
        else
            [tLag, IWVIndx] = min(abs(data.AERONET.datetime - mean(data.mTime(data.cloudFreeGroups(iGroup, :)))));
            if tLag > config.maxIWVTLag
                fprintf('No temporal close measurement for IWV at %s - %s.\n', datestr(data.mTime(data.cloudFreeGroups(iGroup, 1)), 'yyyymmdd HH:MM'), datestr(data.mTime(data.cloudFreeGroups(iGroup, 2)), 'HH:MM'));
            else
                thisIWV = data.AERONET.IWV(IWVIndx);
                thisDatetime = data.datetime(IWVIndx);
            end
        end
    case 'mwr'
        % [thisIWV, thisDatetime] = read_hatpro(mean(data.mTime(data.cloudFreeGroups(iGroup, :))), config.WMRFolder, campaignInfo.location);
    otherwise
        thisIWV = NaN;
        thisDatetime = NaN;
    end

    % concatenate results
    IWV = cat(1, IWV, thisIWV);
    globalAttri.datetime = cat(1, globalAttri.datetime, thisDatetime);
end

end
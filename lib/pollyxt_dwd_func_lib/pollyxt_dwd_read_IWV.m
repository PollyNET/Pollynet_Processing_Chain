function [IWV, globalAttri] = pollyxt_dwd_read_IWV(data, config)
%pollyxt_dwd_read_IWV read integrated water vapor from external instruments, like Cimel sunphotometer and MWR.
%   Example:
%       [IWV, globalAttri] = pollyxt_dwd_read_IWV(data, config)
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
    mwrResFileSearch = dir(fullfile(config.MWRFolder, sprintf('ioppta_lac_mwr00_l2_prw_v00_%s*.nc', datestr(data.mTime(1), 'yyyymmdd'))));
    if isempty(mwrResFileSearch)
        mwrResFile = '';
    elseif length(mwrResFileSearch) >= 2
        warning('More than two mwr products were found.\n%s\n%s\n', mwrResFileSearch(1).name, mwrResFileSearch(2).name);
        return;
    else
        mwrResFile = fullfile(config.MWRFolder, mwrResFileSearch(1).name);
    end
    
    [tIWV_mwr, IWV_mwr, ~, attri_mwr] = read_MWR_IWV(mwrResFile);

    globalAttri.source = attri_mwr.source;
    globalAttri.site = attri_mwr.site;
    contactInfo = regexp(attri_mwr.contact, '(?<PI>.*) \((?<contact>.*)\)', 'names');
    globalAttri.PI = contactInfo.PI;
    globalAttri.contact = contactInfo.contact;
end

%% retrieve data
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisIWV = NaN;
    thisDatetime = NaN;

    switch lower(config.IWV_instrument)
    case 'aeronet'
        if isempty(data.AERONET.IWV)
            fprintf('No IWV measurement for AERONET at %s, %s.\n', datestr(data.mTime(1), 'yyyy-mm-dd'), campaignInfo.location);
            IWV = NaN(1, size(data.cloudFreeGroups, 1));
            globalAttri.datetime = NaN(1, size(data.cloudFreeGroups, 1));
            return;
        else
            [tLag, IWVIndx] = min(abs(data.AERONET.datetime - mean(data.mTime(data.cloudFreeGroups(iGroup, :)))));
            if tLag > config.maxIWVTLag
                fprintf('No close measurement for IWV at %s - %s.\n', datestr(data.mTime(data.cloudFreeGroups(iGroup, 1)), 'yyyymmdd HH:MM'), datestr(data.mTime(data.cloudFreeGroups(iGroup, 2)), 'HH:MM'));
            else
                thisIWV = data.AERONET.IWV(IWVIndx);
                thisDatetime = data.AERONET.datetime(IWVIndx);
            end
        end
    case 'mwr'        
        if isempty(tIWV_mwr)
            fprintf('No IWV measurement for HATPRO at %s, %s.\n', datestr(data.mTime(1), 'yyyy-mm-dd'), campaignInfo.location);
            IWV = NaN(1, size(data.cloudFreeGroups, 1));
            globalAttri.datetime = NaN(1, size(data.cloudFreeGroups, 1));
            return;
        else
            [tLagStart, tStartIndx] = min(abs(tIWV_mwr - data.mTime(data.cloudFreeGroups(iGroup, 1))));
            [tLagEnd, tEndIndx] = min(abs(tIWV_mwr - data.mTime(data.cloudFreeGroups(iGroup, 2))));
            
            if (tLagStart > config.maxIWVTLag) || (tLagEnd > config.maxIWVTLag)
                fprintf('No close measurement for IWV at %s - %s.\n', datestr(data.mTime(data.cloudFreeGroups(iGroup, 1)), 'yyyymmdd HH:MM'), datestr(data.mTime(data.cloudFreeGroups(iGroup, 2)), 'HH:MM'));
            else
                thisIWV = nanmean(IWV_mwr(tStartIndx:tEndIndx));
                thisDatetime = mean(tIWV_mwr(tStartIndx:tEndIndx));
            end
        end
    otherwise
        thisIWV = NaN;
        thisDatetime = NaN;
    end

    % concatenate results
    IWV = cat(1, IWV, thisIWV);
    globalAttri.datetime = cat(1, globalAttri.datetime, thisDatetime);
end

end
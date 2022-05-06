function [IWV, globalAttri] = readIWV(instrument, clFreTime, varargin)
% READIWV read integrated water vapor from external instruments, like sunphotometer or microwave radiometer.
%
% USAGE:
%    [IWV, globalAttri] = readIWV(instrument, clFreTime, varargin)
%
% INPUTS:
%    instrument: char
%        instrument for providing integral water vapor (IWV) measurements.
%        'AERONET' or 'MWR'
%    clFreTime: matrix
%        start and stop time of cloud free segments.
%        [[startTime1, stopTime1]; [startTime2, stopTime2], ...]
%
% KEYWORDS:
%    AERONETSite: char
%        AERONET site (default: leipzig).
%    AERONETIWV: numeric
%        IWV from AERONET (default: []). [kg * m^{-2}] 
%    AERONETTime: numeric
%        measurement time for IWV measurements (default: []).
%    MWRFolder: char
%        folder of microwave radiometer (MWR) results (default: '').
%    MWRSite: char
%        microwave radiometer deployed site (default: 'leipzig').
%    maxIWVTLag: numeric
%        maximum temporal offset between IWV measurements and lidar measurements.
%        (default: datenum(0,1,0,2,0,0))
%    PI: char
%        PI (default: '').
%    contact: char
%        contact of PI (default: '').
%
% OUTPUTS:
%    IWV: array
%        integrated water vapor. (kg * m^{-2})
%    globalAttri:
%        source: char
%            data source. ('AERONET', 'MWR' or else)
%        site: char
%            measurement site.
%        datetime: array
%            datetime of applied IWV.
%        PI: char
%            PI
%        contact: char
%            contact
%
% HISTORY:
%    - 2018-12-26: First Edition by Zhenping
%    - 2019-05-19: Fix the bug of returning empty IWV when more than 2 MWR files were found.
%
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'instrument', @ischar);
addRequired(p, 'clFreTime', @isnumeric);
addParameter(p, 'AERONETSite', 'leipzig', @ischar);
addParameter(p, 'AERONETIWV', [], @isnumeric);
addParameter(p, 'AERONETTime', [], @isnumeric);
addParameter(p, 'MWRFolder', '', @ischar);
addParameter(p, 'MWRSite', 'leipzig', @ischar);
addParameter(p, 'maxIWVTLag', datenum(0,1,0,2,0,0), @isnumeric);
addParameter(p, 'PI', '', @ischar);
addParameter(p, 'contact', '', @ischar);

parse(p, instrument, clFreTime, varargin{:});

IWV = [];
globalAttri = struct();
globalAttri.source = 'none';
globalAttri.site = '';
globalAttri.datetime = [];
globalAttri.PI = '';
globalAttri.contact = '';

if isempty(clFreTime)
    return;
end

%% retrieve instrument info
switch lower(instrument)
case 'aeronet'
    globalAttri.source = 'AERONET';
    globalAttri.site = p.Results.AERONETSite;
    globalAttri.PI = p.Results.PI;
    globalAttri.contact = p.Results.contact;
case 'mwr'
    mwrResFileSearch = dir(fullfile(p.Results.MWRFolder, ...
         datestr(clFreTime(1), 'yymm'), ...
         sprintf('*_mwr00_l2_prw_v00_%s*.nc', ...
            datestr(clFreTime(1), 'yyyymmdd'))));
    if isempty(mwrResFileSearch)
        mwrResFile = '';
    elseif length(mwrResFileSearch) >= 2
        warning(['More than two mwr products were found.\n', ...
                 '%s\n%s\n', ...
                 'Only choose the first one for the calibration.\n'], ...
                 mwrResFileSearch(1).name, mwrResFileSearch(2).name);
        mwrResFile = fullfile(p.Results.MWRFolder, ...
            datestr(clFreTime(1), 'yymm'), mwrResFileSearch(1).name);
    else
        mwrResFile = fullfile(p.Results.MWRFolder, ...
            datestr(clFreTime(1), 'yymm'), mwrResFileSearch(1).name);
    end

    [tIWV_mwr, IWV_mwr, ~, attri_mwr] = readMWR(mwrResFile);

    globalAttri.source = attri_mwr.source;
    globalAttri.site = attri_mwr.site;
    if ~ isempty(attri_mwr.contact)
        contactInfo = regexp(attri_mwr.contact, ...
            '(?<PI>.*) \((?<contact>.*)\)', 'names');
        globalAttri.PI = contactInfo.PI;
        globalAttri.contact = contactInfo.contact;
    end
end

%% retrieve data
for iGrp = 1:size(clFreTime, 1)
    thisIWV = NaN;
    thisDatetime = NaN;

    switch lower(instrument)
    case 'aeronet'
        if isempty(p.Results.AERONETIWV)
            fprintf('No IWV measurement for AERONET at %s, %s.\n', ...
                datestr(clFreTime(1), 'yyyy-mm-dd'), p.Results.AERONETSite);
            IWV = NaN(1, size(clFreTime, 1));
            globalAttri.datetime = NaN(1, size(clFreTime, 1));
            return;
        else
            [tLag, IWVIndx] = min(abs(p.Results.AERONETTime - ...
                        mean(clFreTime(iGrp, :))));
            if tLag > p.Results.maxIWVTLag
                fprintf('No close measurement for IWV at %s - %s.\n', ...
                    datestr(clFreTime(iGrp, 1), 'yyyymmdd HH:MM'), ...
                    datestr(clFreTime(iGrp, 2), 'HH:MM'));
            else
                thisIWV = p.Results.AERONETIWV(IWVIndx);
                thisDatetime = p.Results.AERONETTime(IWVIndx);
            end
        end
    case 'mwr'        
        if isempty(tIWV_mwr)
            fprintf('No IWV measurement for HATPRO at %s, %s.\n', ...
                datestr(clFreTime(1), 'yyyy-mm-dd'), p.Results.MWRSite);
            IWV = NaN(1, size(clFreTime, 1));
            globalAttri.datetime = NaN(1, size(clFreTime, 1));
            return;
        else
            [tLagStart, tStartIndx] = min(abs(tIWV_mwr - clFreTime(iGrp, 1)));
            [tLagEnd, tEndIndx] = min(abs(tIWV_mwr - clFreTime(iGrp, 2)));

            if (tLagStart > p.Results.maxIWVTLag) || (tLagEnd > p.Results.maxIWVTLag)
                fprintf('No close measurement for IWV at %s - %s.\n', ...
                    datestr(clFreTime(iGrp, 1), 'yyyymmdd HH:MM'), ...
                    datestr(clFreTime(iGrp, 2), 'HH:MM'));
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
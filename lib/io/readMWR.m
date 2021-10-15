function [tIWV, IWV, IWVErr, IWVAttri] = readMWR(files)
% READMWR read integrated water vapor from the microwave radiometer outputs.
%
% USAGE:
%    [tIWV, IWV, IWVErr, IWVAttri] = readMWR(files)
%
% INPUTS:
%    files: char | cell
%        absolute paths of the netcdf files for saving the IWV results from 
%        HATPRO. Generally, you can find the data in our rsd server. 
%        Detailed information you can contact with Patric Seifert.
%
% OUTPUTS:
%    IWV: array
%        intergrated water vapor. [kg*m^{-2}] 
%    tIWV: array
%        time for each bin. [datenum]
%    IWVErr: float
%        standar deviation of IWV. [kg*m^{-2}]
%    IWVAttri: struct
%        institution: char
%            Institution
%        contact: char
%            contact
%        source: char
%            data source or instrument.
%        site: char
%            site
%
% HISTORY:
%    - 2019-01-03: First Edition by Zhenping
%    - 2019-12-02: Add support for reading multiple files.
%
% .. Authors: - zhenping@tropos.de

tIWV = [];
IWV = [];
IWVErr = [];
IWVAttri = struct();
IWVAttri.institution = '';
IWVAttri.contact = '';
IWVAttri.source = '';
IWVAttri.site = '';

if ischar(files)
    files = {files};   % convert char array to cell
end

for iFile = 1:length(files)

    thisFile = files{iFile};

    if exist(thisFile, 'file') ~= 2
        warning('HATPRO file does not exist.\n%s\n', thisFile);
        continue;
    end

    %% read data
    thisIWV = ncread(thisFile, 'prw');
    thisTSec = ncread(thisFile, 'time');
    thistIWV = unix_timestamp_2_datenum(thisTSec);
    thisIWVErr = ncread(thisFile, 'prw_err');
    IWVAttri.institution = ncreadatt(thisFile, '/', 'Institution');
    IWVAttri.contact = ncreadatt(thisFile, '/', 'Contact_person');
    IWVAttri.source = ncreadatt(thisFile, '/', 'Source');
    IWVAttri.site = ncreadatt(thisFile, '/', 'Measurement_site');

    %% append data
    tIWV = cat(1, tIWV, thistIWV);
    IWV = cat(1, IWV, thisIWV);
    IWVErr = cat(1, IWVErr, thisIWVErr);
end

end
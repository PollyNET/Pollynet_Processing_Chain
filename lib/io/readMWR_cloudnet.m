function [tIWV, IWV, IWVAttri] = readMWR_cloudnet(files)
% READMWR read integrated water vapor from the microwave radiometer outputs.
%
% USAGE:
%    [tIWV, IWV, IWVAttri] = readMWR(files)
%
% INPUTS:
%    files: char | cell
%        absolute paths of the netcdf files for saving the IWV results from 
%        HATPRO. Generally, you can find the data on rsd2 server: 
%        '/data/level1b/cloudnetpy/products/'. Otherwise those data can be
%        accessed via the cloudnet page from the fmi institution, e.g.:
%        'https://cloudnet.fmi.fi/search/data?site=mindelo&dateFrom=2023-03-27&dateTo=2023-03-27&product=mwr'
%
% OUTPUTS:
%    IWV: array
%        intergrated water vapor. [kg*m^{-2}] 
%    tIWV: array
%        time for each bin. [datenum]
%    IWVAttri: struct
%        instrument_pid: char
%            unique instrument_pid given by the fmi
%        source: char
%            data source or instrument.
%        site: char
%            site
%
% HISTORY:
%    - 2023-07-12: First Edition by Andi Klamt
%
% .. Authors: - klamt@tropos.de

tIWV = [];
IWV = [];
IWVAttri = struct();
IWVAttri.instrument_pid = '';
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
    thisIWV = ncread(thisFile, 'iwv');
    thisTSec = ncread(thisFile, 'time');
    thistIWV = unix_timestamp_2_datenum(thisTSec);
    IWVAttri.instrument_pid = ncreadatt(thisFile, '/', 'instrument_pid');
    IWVAttri.source = ncreadatt(thisFile, '/', 'source');
    IWVAttri.site = ncreadatt(thisFile, '/', 'location');

    %% append data
    tIWV = cat(1, tIWV, thistIWV);
    IWV = cat(1, IWV, thisIWV);
end

end

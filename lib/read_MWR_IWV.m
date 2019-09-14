function [tIWV, IWV, IWVErr, IWVAttri] = read_MWR_IWV(file)
%READ_MWR_IWV read the integrated water vapor from the microwave radiometer 
%outputs.
%   Example:
%       [tIWV, IWV, IWVErr] = read_MWR_IWV(tIWV, IWV, IWVErr Inputs)
%   Inputs:
%       file: char
%           netcdf file of saving the IWV results from HATPRO. Generally you can
%           find the data in our rsd server. Detailed information you can 
%           contact with Patric Seifert.
%   Outputs:
%       IWV: array
%           intergrated water vapor. [kg*m^{-2}] 
%       tIWV: array
%           time for each bin. [datenum]
%       IWVErr: float
%           standar deviation of IWV. [kg*m^{-2}]
%       IWVAttri: struct
%           institution: char
%           contact: char
%           source: char
%               data source or instrument.
%           site: char
%   History:
%       2019-01-03. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

tIWV = [];
IWV = [];
IWVErr = [];
IWVAttri = struct();
IWVAttri.institution = '';
IWVAttri.contact = '';
IWVAttri.source = '';
IWVAttri.site = '';

if exist(file, 'file') ~= 2
    warning('HATPRO file does not exist.\n%s\n', file);
    return;
end

%% read data
IWV = ncread(file, 'prw');
tSeconds = ncread(file, 'time');
tIWV = datenum(1970, 1, 1, 0, 0, 0) + datenum(0, 1, 0, 0, 0, tSeconds);
IWVErr = ncread(file, 'prw_err');
IWVAttri.institution = ncreadatt(file, '/', 'Institution');
IWVAttri.contact = ncreadatt(file, '/', 'Contact_person');
IWVAttri.source = ncreadatt(file, '/', 'Source');
IWVAttri.site = ncreadatt(file, '/', 'Measurement_site');

end
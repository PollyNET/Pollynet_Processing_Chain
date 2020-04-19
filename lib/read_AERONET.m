function [measTime, AOD_1640, AOD_1020, AOD_870, AOD_675, AOD_500, AOD_440, AOD_380, AOD_340, wavelength, IWV, angstrexp440_870, AERONETAttri] = read_AERONET(site, mdate, level, flagFilterNegAOD)
%READ_AERONET This function determines the Aerosol Optical Depth (AOD) from a
%collocated photometer. Available AOD values for a specified day are returned. 
%Data is downloaded for the specified location from Aeronet website:
%http://aeronet.gsfc.nasa.gov/new_web/aerosols.html
%The function accesses the appropriate aeronet website first. This way
%the website is triggered to create a compressed file with the requested
%data. This file is accessed and unzipped into a temporary file. The
%temporary file is then read and finally deleted. AOD values and
%corresponding time along with the link to the aeronet website are
%returned.   
%Example:
%   [measTime, AOD, wavelength, IWV, angstrexp440_870, AERONETAttri] = 
%   read_AERONET(site, date, level)
%Inputs:
%   site: char
%       AERONET site. You can find the nearest site by referring to 
%       doc/AERONET-station-list.txt 
%   mdate: integer or two-element array
%       the measurement day or [startDate, endDate]. [datenum] 
%   level: char
%       product level. ('10', '15', '20')
%   flagFilterNegAOD: logical
%       flag to control whether to filter out the negative AOD values. 
%       (default: true)
%Outputs:
%   measTime: array
%       time of each measurment point.
%   AOD_{wavelength}: array
%       AOD at wavelength.
%   wavelength: array
%       wavelength of each channel. [nm]
%   IWV: array
%       Integrated Water Vapor. [kg * m^{-2}] 
%   angstrexp440_870: array
%       angstroem exponent 440-870 nm
%   AERONETAttri: struct 
%       URL: char
%           URL to retrieve the data.
%       level: char
%           product level. ('10', '15', '20')
%       status: logical
%           status to show whether retrieve the data successfully.
%       IWVUnit: char
%           unit of integrated water vapor. [kg * m^{-2}]
%       location: char
%           AERONET site
%       PI: char
%           PI of the current AERONET site.
%       contact: char
%           email of the PI.
%Reference:
%   ceilo_bsc_readAeronetPhotometerAOD_wget.m
%History:
%   2017-12-19. First edition by Zhenping.
%   2018-06-22. Add 'TreatAsEmpty' keyword to textscan function to filter 
%               N/A field in AERONET data.
%   2018-12-23. Second Edition by Zhenping
%   2019-02-06. Add 'flagFilterNegAOD' to keyword to enable filtering out 
%               negative AOD values.
%   2019-09-01. Enable download the AERONET data between two dates.
%Contact:
%   zhenping@tropos.de

if ~ exist('flagFilterNegAOD', 'var')
    flagFilterNegAOD = true;
end

measTime = [];
AOD_1640 = [];
AOD_1020 = [];
AOD_870 = [];
AOD_675 = [];
AOD_500 = [];
AOD_440 = [];
AOD_380 = [];
AOD_340 = [];
wavelength = [1640, 1020, 870, 675, 500, 440, 380, 340];
IWV = [];
angstrexp440_870 = [];
AERONETAttri.URL = '';
AERONETAttri.level = '';
AERONETAttri.status = false;
AERONETAttri.IWVUnit = '';
AERONETAttri.location = '';
AERONETAttri.PI = '';
AERONETAttri.contact = '';

% specify date to download appropriate AOD file
if length(mdate) == 1
    [thisyear1, thismonth1, thisday1] = datevec(mdate);
    [thisyear2, thismonth2, thisday2] = datevec(mdate);
elseif length(mdate) == 2
    [thisyear1, thismonth1, thisday1] = datevec(mdate(1));
    [thisyear2, thismonth2, thisday2] = datevec(mdate(end));
else
    warning('mdate can only be an integer or an 2-element array.');
    return;
end

thisYearStr1 = num2str(thisyear1 - 1900);
thisMonthStr1 = num2str(thismonth1);
thisDayStr1 = num2str(thisday1);
thisYearStr2 = num2str(thisyear2 - 1900);
thisMonthStr2 = num2str(thismonth2);
thisDayStr2 = num2str(thisday2);

% link to access website to create file
aod_url = ['https://aeronet.gsfc.nasa.gov/cgi-bin/print_web_data_v2?site=' site ...
    '&year=' thisYearStr1 '&month=' thisMonthStr1 '&day=' thisDayStr1 ...
    '&year2=' thisYearStr2 '&month2=' thisMonthStr2 '&day2=' thisDayStr2 ...
    '&LEV' level '=1&AVG=10'];

% call the system command 'wget' to download the html text
if ispc
    [status, html_text] = system(['wget -qO- "' aod_url '"']);
    if status ~= 0
        warning(['Error in calling wget in window cmd. Please make sure ' ...
                 'wget is available and it is in the searching path of ' ...
                 'window. \nOtherwise, you need to download the suitable ' ...
                 'version online and add the path to the environment ' ...
                 'variables manually.\n You can go to ' ...
                 'https://de.mathworks.com/matlabcentral/answers/' ...
                 '94933-how-do-i-edit-my-system-path-in-windows ' ...
                 'for detailed information']);
        return;
    end
elseif isunix
    [status, html_text] = system(['wget -qO- "' aod_url '"']);
end

if status == 0
    TextSpec = ['%s %s %*s %f %f %f %f', repmat('%*s', 1, 5), ...
                '%f', '%*s %*s', '%f', '%*s', '%f %f %f', ...
                repmat('%*s', 1, 17), '%f', repmat('%*s', 1, 28)];
    T = textscan(html_text, TextSpec, 'Delimiter', ',', ...
                 'HeaderLines', 9, 'TreatAsEmpty', 'N/A');
    if numel(T{1}) > 1
        AOD_1640 = T{3}(1:end-1);
        AOD_1020 = T{4}(1:end-1);
        AOD_870 = T{5}(1:end-1);
        AOD_675 = T{6}(1:end-1);
        AOD_500 = T{7}(1:end-1);
        AOD_440 = T{8}(1:end-1);
        AOD_380 = T{9}(1:end-1);
        AOD_340 = T{10}(1:end-1);
        IWV = T{11}(1:end-1) / 100 * 1000;   % convert the precipitable water 
                                             % vapor (cm) to integrated water 
                                             % vapor (kg * m^{-2}) by timing 
                                             % the density of liquid water.
        angstrexp440_870 = T{12}(1:end-1);
        for iRow = 1:(numel(T{1}) - 1)
            measTime = [measTime; ...
                    datenum([T{1}{iRow} T{2}{iRow}], 'dd:mm:yyyyHH:MM:SS')];
        end

        if flagFilterNegAOD
            flagNegValue = (AOD_1640 <= 0) | (AOD_1020 <= 0) | ...
                           (AOD_870 <= 0) | (AOD_675 <= 0) | ...
                           (AOD_500 <= 0) | (AOD_440 <= 0) | ...
                           (AOD_380 <= 0) | (AOD_340 <= 0) | (IWV <= 0);
            measTime = measTime(~ flagNegValue);
            AOD_1640 = AOD_1640(~ flagNegValue);
            AOD_1020 = AOD_1020(~ flagNegValue);
            AOD_870 = AOD_870(~ flagNegValue);
            AOD_675 = AOD_675(~ flagNegValue);
            AOD_500 = AOD_500(~ flagNegValue);
            AOD_440 = AOD_440(~ flagNegValue);
            AOD_380 = AOD_380(~ flagNegValue);
            AOD_340 = AOD_340(~ flagNegValue);
            IWV = IWV(~ flagNegValue);
            angstrexp440_870 = angstrexp440_870(~ flagNegValue);
        end

        siteinfo = regexp(html_text, ...
                          '\w*,PI=(?<PI>.*),Email=(?<Email>\S*)<br', 'names');
        AERONETAttri.URL = aod_url;
        AERONETAttri.level = level;
        AERONETAttri.status = true;
        AERONETAttri.IWVUnit = 'kg * m^{-2}';
        AERONETAttri.location = site;
        AERONETAttri.PI = siteinfo.PI;
        AERONETAttri.contact = siteinfo.Email;
        return;
    else   % no valid data
        fprintf('Could not extract photometer data (Level: %s)\n%s\n', ...
                level, aod_url);
        AERONETAttri.URL = aod_url;
        AERONETAttri.level = level;
        AERONETAttri.status = false;
        AERONETAttri.IWVUnit = 'kg * m^{-2}';
        AERONETAttri.location = site;
        AERONETAttri.PI = '';
        AERONETAttri.contact = '';
        return;
    end
end

end
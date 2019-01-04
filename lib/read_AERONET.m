function [datetime, AOD_1640, AOD_1020, AOD_870, AOD_675, AOD_500, AOD_440, AOD_380, AOD_340, wavelength, IWV, angstrexp440_870, AERONETAttri] = read_AERONET(site, mdate, level)
%read_AERONET 
%   This function determines the Aerosol Optical Depth (AOD) from a
%   collocated photometer. Available AOD values for a specified day are returned. 
%   Data is downloaded for the specified location from Aeronet website:
%   http://aeronet.gsfc.nasa.gov/new_web/aerosols.html
%   The function accesses the appropriate aeronet website first. This way
%   the website is triggered to create a compressed file with the requested
%   data. This file is accessed and unzipped into a temporary file. The
%   temporary file is then read and finally deleted. AOD values and
%   corresponding time along with the link to the aeronet website are
%   returned.   
%   Example:
%       [datetime, AOD, wavelength, IWV, angstrexp440_870, AERONETAttri] = read_AERONET(site, date, level)
%   Inputs:
%       site: char
%           AERONET site. You can find the nearest site by referring to doc/AERONET-station-list.txt 
%       mdate: datenum
%           the measurement day. 
%       level: char
%           product level. ('10', '15', '20')
%   Outputs:
%       datetime: array
%           time of each measurment point.
%       AOD_{wavelength}: array
%           AOD at wavelength.
%       wavelength: array
%           wavelength of each channel. [nm]
%       IWV: array
%           Integrated Water Vapor. [kg * m^{-2}] 
%       angstrexp440_870: array
%           angstroem exponent 440-870 nm
%       AERONETAttri: struct     
%           URL: char
%               URL to retrieve the data.
%           level: char
%               product level. ('10', '15', '20')
%           status: logical
%               status to show whether retrieve the data successfully.
%           IWVUnit: char
%               unit of integrated water vapor. [kg * m^{-2}]
%           location: char
%               AERONET site
%           PI: char
%               PI of the current AERONET site.
%           contact: char
%               email of the PI.
%   Reference:
%       ceilo_bsc_readAeronetPhotometerAOD_wget.m
%   History:
%       2017-12-19. First edition by Zhenping.
%       2018-06-22. Add 'TreatAsEmpty' keyword to textscan function to filter
%       N/A field in AERONET data.
%       2018-12-23. Second Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

datetime = [];
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

% specify date to download appropriate AOD file
[thisyear, thismonth, thisday] = datevec(mdate);

% year = datestr(time, 'yy');
thisYearStr = num2str(thisyear - 1900);
thisMonthStr = num2str(thismonth);
thisDayStr = num2str(thisday);

% link to access website to create file
% https://aeronet.gsfc.nasa.gov/cgi-bin/print_web_data_v2
% https://aeronet.gsfc.nasa.gov/cgi-bin/print_web_data_v2?site=Cart_Site&year=100&month=6&day=1&year2=100&month2=6&day2=14&LEV10=1&AVG=20
% https://aeronet.gsfc.nasa.gov/cgi-bin/print_warning_opera_v2_new?site=CUT-TEPAK&year=117&month=4&day=11&year2=117&month2=4&day2=11&LEV15=1&AVG=10

aod_url = ['https://aeronet.gsfc.nasa.gov/cgi-bin/print_web_data_v2?site=' ...
    site '&year=' thisYearStr '&month=' thisMonthStr '&day=' thisDayStr '&year2=' thisYearStr ...
    '&month2=' thisMonthStr '&day2=' thisDayStr '&LEV' level '=1&AVG=10'];

% call the system command 'wget' to download the html text
[status, html_text] = system(['curl -s "' aod_url '"']);

if status == 0
    TextSpec = ['%s %s %*s %f %f %f %f', repmat('%*s', 1, 5), '%f', '%*s %*s', '%f', '%*s', '%f %f %f', repmat('%*s', 1, 17), '%s', repmat('%*s', 1, 28)];
    T = textscan(html_text, TextSpec, 'Delimiter', ',', 'HeaderLines', 9, 'TreatAsEmpty', 'N/A');
    if numel(T{1}) > 1
        AOD_1640 = T{3}(1:end-1);
        AOD_1020 = T{4}(1:end-1);
        AOD_870 = T{5}(1:end-1);
        AOD_675 = T{6}(1:end-1);
        AOD_500 = T{7}(1:end-1);
        AOD_440 = T{8}(1:end-1);
        AOD_380 = T{9}(1:end-1);
        AOD_340 = T{10}(1:end-1);
        IWV = T{11}(1:end-1) / 100 * 1000;   % convert the precipitable water vapor (cm) to integrated water vapor (kg * m^{-2}) by timing the density of liquid water.
        angstrexp440_870 = T{12}(1:end-1);
        for iRow = 1:(numel(T{1}) - 1)
            datetime = [datetime, datenum([T{1}{iRow} T{2}{iRow}], 'dd:mm:yyyyHH:MM:SS')];
        end

        siteinfo = regexp(html_text, '\w*,PI=(?<PI>.*),Email=(?<Email>\S*)<br', 'names');
        AERONETAttri.URL = aod_url;
        AERONETAttri.level = level;
        AERONETAttri.status = true;
        AERONETAttri.IWVUnit = 'kg * m^{-2}';
        AERONETAttri.location = site;
        AERONETAttri.PI = siteinfo.PI;
        AERONETAttri.contact = siteinfo.Email;
        return;
    else   % no valid data
        fprintf('Could not extract photometer data (Level: %s)\n%s\n', level, aod_url);
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
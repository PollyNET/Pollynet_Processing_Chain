function health = readPolly1v2Laserlogbook(file, flagDeleteData)
% readPolly1v2Laserlogbook Read the health parameters of the lidar from 
% the zipped laserlogbook file
% USAGE:
%    [output] = readPolly1v2Laserlogbook(file, flagDeleteData)
% INPUTS:
%    file: char
%        the full filename.
%    flagDeleteData: logical
%        flag to control whether to delete the laserlogbook file.
% OUTPUTS:
%    health: struct
%        time: datenum array
%        AD: array
%            laser energy (measured inside laser head.) [a.u.]
%        EN: array
%            laser energy (measured inside laser head.) [mJ]
%        counts: array
%            flashlamp used counts.
%        ExtPyro: array
%            raw output energy (ExtPyro). [mJ]
%        Temp1064: array
%            temperature for the PMT at 1064nm channel. [degree celsius]
%        Temp1: array
%            temperature for the transmitting chamber. [degree celsius]
%        Temp2: array
%            temperature for the receiving chamber. [degree celsius]
%        OutsideRH: array
%            RH outside the polly system. [%]
%        OutsideT: array
%            temperature outside the Polly system. [degree celsius]
%        roof: array
%            status to show whether the roof is closed.
%        rain: array
%            status to show whether it is raining.
%        shutter: array
%            status to show whether the shutter is closed.
% EXAMPLE:
% HISTORY:
%    2021-04-12: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

if ~ exist('flagDeleteData', 'var')
    flagDeleteData = false;
end

%% initialize parameters
health = struct();
health.time = []; 
health.AD = [];
health.EN = [];
health.HT = [];
health.WT = [];
health.LS = [];
health.counts = [];
health.ExtPyro = [];
health.Temp1064 = []; 
health.Temp1 = [];
health.Temp2 = [];
health.OutsideRH = [];
health.OutsideT = [];
health.roof = []; 
health.rain = [];
health.shutter = [];

if exist(file, 'file') ~= 2
    warning('%s laserlogbook file does not exist.\n%s\n', config.pollyVersion, file);
    return;
end

%% read laserlog (credits to Martin's python script "pollyhk_standalone.py")
SC_regexp = '(?<=SC,) *\d*\.?\d*';
WT_regexp = '(?<=WT,) *\d*\.?\d*';
HT_regexp = '(?<=HT,) *\d*\.?\d*';
EN_regexp = '(?<=EN,) *\d*\.?\d*';
AD_regexp = '(?<=AD,) *\d*\.?\d*';
LS_regexp = '(?<=LS,\d*,) *\d*(?=,)';
Temp1064_regexp = '(?<=Temp1064: ) *-?\d*\.?\d*(?= C)';
Temp1_regexp = '(?<=Temp1: ) *-?\d*\.?\d*(?= C)';
Temp2_regexp = '(?<=Temp2: ) *-?\d*\.?\d*(?= C)';
OutsideRH_regexp = '(?<=OutsideRH: ) *\d*\.?\d*(?= %)';
OutsideT_regexp = '(?<=OutsideT: ) *-?\d*\.?\d*(?= C)';
roof_regexp = '(?<=roof: ) *\d{1}';
rain_regexp = '(?<=rain: ) *\d{1}';
shutter_regexp = '(?<=shutter: ) *\d{1}';
ExtPyro_regexp = '(?<=ExtPyro: ) *\d*\.?\d*(?= mJ)';
dateSpec = '(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2}) (?<hour>\d{2}):(?<minute>\d{2}):(?<second>\d{2})';

fid = fopen(file, 'r');

%% read information
iLine = 0;
try
    while ~ feof(fid)
        iLine = iLine + 1;
        thisLine = fgetl(fid);
        
        tokenInfo = regexp(thisLine, dateSpec, 'names');
        if ~ isempty(tokenInfo)
            health.time = [health.time; datenum(str2double(tokenInfo.year), str2double(tokenInfo.month), str2double(tokenInfo.day), str2double(tokenInfo.hour), str2double(tokenInfo.minute), str2double(tokenInfo.second))];
        else
            health.time = [health.time; datenum(0,1,0,0,0,0)];
        end
        health.AD = [health.AD; str2double(regexp_token(thisLine, AD_regexp, '999'))];
        health.EN = [health.EN; str2double(regexp_token(thisLine, EN_regexp, '999'))];
        health.counts = [health.counts; str2double(regexp_token(thisLine, SC_regexp, '999'))];
        health.HT = [health.HT; str2double(regexp_token(thisLine, HT_regexp, '999'))];
        health.WT = [health.WT; str2double(regexp_token(thisLine, WT_regexp, '999'))];
        health.LS = [health.LS; str2double(regexp_token(thisLine, LS_regexp, '999'))];
        health.ExtPyro = [health.ExtPyro; str2double(regexp_token(thisLine, ExtPyro_regexp, '999'))];
        health.Temp1064 = [health.Temp1064; str2double(regexp_token(thisLine, Temp1064_regexp, '999'))];
        health.Temp1 = [health.Temp1; str2double(regexp_token(thisLine, Temp1_regexp, '999'))];
        health.Temp2 = [health.Temp2; str2double(regexp_token(thisLine, Temp2_regexp, '999'))];
        health.rain = [health.rain; str2double(regexp_token(thisLine, rain_regexp, '999'))];
        health.roof = [health.roof; str2double(regexp_token(thisLine, roof_regexp, '999'))];
        health.shutter = [health.shutter; str2double(regexp_token(thisLine, shutter_regexp, '999'))];
        health.OutsideRH = [health.OutsideRH; str2double(regexp_token(thisLine, OutsideRH_regexp, '999'))];
        health.OutsideT = [health.OutsideT; str2double(regexp_token(thisLine, OutsideT_regexp, '999'))];
    end

    % delete the laserlogbook file
    if flagDeleteData
        fclose(fid);
        delete(file);
    end

catch
    fclose(fid);
    warning('Failure in reading %s laserlogbook at line %d.\n%s\n', config.pollyVersion, iLine, file);
    return
end

end
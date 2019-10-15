function health = pollyxt_ift_read_laserlogbook(file, config, flagDeleteData)
%POLLYXT_IFT_READ_LASERLOGBOOK read the health parameters of the lidar from 
%the zipped laserlogbook file
%   Usage:
%       health = pollyxt_ift_read_laserlogbook(file)
%   Inputs:
%       file: char
%           the full filename.
%       config: struct
%           polly configuration file. Detailed information can be found in doc/polly_config.md
%       flagDeleteData: logical
%           flag to control whether to delete the laserlogbook file.
%   Outputs:
%       health: struct
%           time: datenum array
%           AD: array
%               laser energy (measured inside laser head.) [a.u.]
%           EN: array
%               laser energy (measured inside laser head.) [mJ]
%           counts: array
%               flashlamp used counts.
%           Temp1: array
%               temperature for the transmitting chamber. [degree celsius]
%           Temp2: array
%               temperature for the receiving chamber. [degree celsius]
%           WT: array
%               water temperature. [degree celsius]
%           LS: array
%               laser shutter. 
%               (031010000 stands for 'shutter open', otherwise means 'closed')
%           Temp1064: array
%               1064 PMT temperature. [degree celsius]
%           OutsideTemp: array
%               environment temperature. [degree celsius]
%           OutsideRH: array
%               environment relative humidity. [%]
%   History
%       2019-08-26. First edition by Zhenping
%   Contact:
%       zhenping@tropos.de

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
health.Temp1 = [];
health.Temp2 = [];
health.Temp1064 = [];
health.OutsideTemp = [];
health.OutsideRH = [];

if exist(file, 'file') ~= 2
    warning('%s laserlogbook file does not exist.\n%s\n', config.pollyVersion, file);
    return;
end

%% read laserlog (credits to Martin's python script "pollyhk_standalone.py")
SC_regexp = '(?<=SC,)\d*\.?\d*';
WT_regexp = '(?<=WT,)\d*\.?\d*';
HT_regexp = '(?<=HT,)\d*\.?\d*';
EN_regexp = '(?<=EN,)\d*\.?\d*';
AD_regexp = '(?<=AD,)\d*\.?\d*';
LS_regexp = '(?<=LS,)\d*\.?\d*';
Temp1_regexp = '(?<=Temp1: )-?\d*\.?\d*(?= C)';
Temp2_regexp = '(?<=Temp2: )-?\d*\.?\d*(?= C)';
Temp1064_regexp = '(?<=Temp1064:)-?\d*\.?\d*(?= C)';
OutsideTemp_regexp = '(?<=OutsideTemp: )-?\d*\.?\d*(?= C)';
OutsideRH_regexp = '(?<=OutsideHumidity: )-?\d*\.?\d*(?= %)';
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
            health.time = [health.time; datenum(str2num(tokenInfo.year), str2num(tokenInfo.month), str2num(tokenInfo.day), str2num(tokenInfo.hour), str2num(tokenInfo.minute), str2num(tokenInfo.second))];
        else
            health.time = [health.time; datenum(0,1,0,0,0,0)];
        end
        health.AD = [health.AD; str2num(regexp_token(thisLine, AD_regexp, '999'))];   % '999' for defaults
        health.EN = [health.EN; str2num(regexp_token(thisLine, EN_regexp, '999'))];
        health.counts = [health.counts; str2num(regexp_token(thisLine, SC_regexp, '999'))];
        health.HT = [health.HT; str2num(regexp_token(thisLine, HT_regexp, '999'))];
        health.WT = [health.WT; str2num(regexp_token(thisLine, WT_regexp, '999'))];
        health.LS = [health.LS; str2num(regexp_token(thisLine, LS_regexp, '0'))];
        health.Temp1 = [health.Temp1; str2num(regexp_token(thisLine, Temp1_regexp, '999'))];
        health.Temp2 = [health.Temp2; str2num(regexp_token(thisLine, Temp2_regexp, '999'))];
        health.Temp1064 = [health.Temp1064; str2num(regexp_token(thisLine, Temp1064_regexp, '999'))];
        health.OutsideTemp = [health.OutsideTemp; str2num(regexp_token(thisLine, OutsideTemp_regexp, '999'))];
        health.OutsideRH = [health.OutsideRH; str2num(regexp_token(thisLine, OutsideRH_regexp, '999'))];
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
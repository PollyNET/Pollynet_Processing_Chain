function health = polly_1v2_read_laserlogbook(file, config, flagDeleteData)
%POLLY_1v2_READ_LASERLOGBOOK read the health parameters of the lidar from 
%the zipped laserlogbook file
%   Usage:
%       health = polly_1v2_read_laserlogbook(file)
%   Inputs:
%       file: char
%           the full filename.
%		config: struct
%			polly configuration file. Detailed information can be found in doc/polly_config.md
%		flagDeleteData: logical
%			flag to control whether to delete the laserlogbook file.
%   Outputs:
%		health: struct
%   	    time: datenum array
%       	ExtPyro: array
%           	raw output energy (ExtPyro). [mJ]
%       	Temp1064: array
%           	temperature for the PMT at 1064nm channel. [degree celsius]
%       	Temp1: array
%           	temperature for the transmitting chamber. [degree celsius]
%       	Temp2: array
%           	temperature for the receiving chamber. [degree celsius]
%       	OutsideRH: array
%           	RH outside the polly system. [%]
%       	OutsideT: array
%           	temperature outside the Polly system. [degree celsius]
%       	roof: array
%           	status to show whether the roof is closed.
%       	rain: array
%           	status to show whether it is raining.
%       	shutter: array
%           	status to show whether the shutter is closed.
%   History
%       2018-08-05. First edition by Zhenping.
%   Contact:
%       zhenping@tropos.de

if ~ exist('flagDeleteData', 'var')
	flagDeleteData = false;
end

%% initialize parameters
health = struct();
health.time = []; 
health.ExtPyro = [];
health.Temp1064 = []; 
health.Temp1 = [];
health.Temp2 = [];
health.OutsideRH = [];
health.OutsideT = [];
health.roof = []; 
health.rain = [];
health.shutter = [];

if ~ exist(file, 'file')
	warning('%s laserlogbook file does not exist.\n%s\n', config.pollyVersion, file);
	return;
end

%% read log
fid = fopen(file, 'r');
parseFmt = '(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2}) (?<hour>\d{2}):(?<minute>\d{2}):(?<second>\d{2}).*Temp1: (?<temp1>[+-]?\d+\.?\d+) C, Temp2: (?<temp2>[+-]?\d+\.?\d+) C.*RH1: (?<RH1>[+-]?\d+\.?\d+) %, RH2: (?<RH2>[+-]?\d+\.?\d+) %, OutsideRH: (?<OutsideRH>[+-]?\d+\.?\d+) %, OutsideT: (?<OutsideT>.+) C, roof: (?<roof>\d{1}), rain: (?<rain>\d{1}), shutter: (?<shutter>\d{1})';

%% parse information
while ~ feof(fid)
    try
        thisLine = fgetl(fid);
        res = regexp(thisLine, parseFmt, 'names');
        health.time = [health.time, datenum(str2num(res.year), str2num(res.month), str2num(res.day), str2num(res.hour), str2num(res.minute), str2num(res.second))];
        health.ExtPyro = [health.ExtPyro, NaN];
        health.Temp1064 = [health.Temp1064, NaN]; 
        health.Temp1 = [health.Temp1, str2num(res.temp1)]; 
        health.Temp2 = [health.Temp2, str2num(res.temp2)]; 
        health.OutsideRH = [health.OutsideRH, str2num(res.OutsideRH)]; 
        health.OutsideT = [health.OutsideT, str2num(res.OutsideT)]; 
        health.roof = [health.roof, str2num(res.roof)]; 
        health.rain = [health.rain, str2num(res.rain)]; 
        health.shutter = [health.shutter, str2num(res.shutter)];
        
    catch
        warning('Failure in reading %s laserlogbook.\n%s\n', config.pollyVersion, file);
        fclose(fid);
        
        % delete the laserlogbook file
        if flagDeleteData
            delete(file);
        end
        
        return
    end

end

fclose(fid);

% delete the laserlogbook file
if flagDeleteData
    delete(file);
end

end
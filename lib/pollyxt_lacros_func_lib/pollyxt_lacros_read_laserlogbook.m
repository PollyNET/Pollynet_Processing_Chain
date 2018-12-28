function health = polly_lacros_read_laserlogbook(file, config)
%POLLY_lacros_READ_LASERLOGBOOK read the health parameters of the lidar from 
%the zipped laserlogbook file
%   Usage:
%       health = polly_lacros_read_laserlogbook(file)
%   Inputs:
%       file: char
%           the full filename.
%		config: struct
%			polly configuration file. Detailed information can be found in doc/polly_config.md
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
textSpec = ['%04d-%02d-%02d %02d:%02d:%02d%*s %f mJ	Temp1064: %f C, Temp1: %f C, ', ...
           'Temp2: %f C, OutsideRH: %f %*[^,], OutsideT: %f C, roof: %d, rain: %d, shutter: %d'];

fid = fopen(file, 'r');

%% read information
try
	T = textscan(fid, textSpec, 'Delimiter', ' ', 'MultipleDelimsAsOne', 1);
	fclose(fid);
	health.time = datenum(double(T{1}), double(T{2}), double(T{3}), double(T{4}), double(T{5}), double(T{6}));
	health.ExtPyro = T{7};
	health.Temp1064 = T{8}; 
	health.Temp1 = T{9}; 
	health.Temp2 = T{10}; 
	health.OutsideRH = T{11}; 
	health.OutsideT = T{12}; 
	health.roof = T{13}; 
	health.rain = T{14}; 
	health.shutter = T{15};
catch
	warning('Failure in reading %s laserlogbook.\n%s\n', config.pollyVersion, file);
	return
end

end
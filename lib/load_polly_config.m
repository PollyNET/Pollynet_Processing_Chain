function [pollyConfig] = load_polly_config(configFile, configDir)
%LOAD_POLLY_CONFIG load the polly configurations for processing the polly data.
%	Example:
%		[pollyConfig] = load_polly_config(configFile, configDir)
%	Inputs:
%		configFile: char
%		configDir: char
%			the directory for saving the polly configuration files.
%	Outputs:
%		pollyConfig: struct
%			polly configurations. Details can be found in doc/polly_config.md
%	History:
%		2018-12-16. First edition by Zhenping
%	Contact:
%		zhenping@tropos.de

%TODO: add the switch part to read the configurature individually for different polly system.

pollyConfig = '';

if ~ exist(configDir, 'dir')
	error('Error in load_polly_config: folder does not exist.\n%s\n', configDir);
end

configFile = fullfile(configDir, configFile);

if ~ exist(configFile, 'file')
	error('Error in load_polly_config: config file does not exist.\n%s\n', configFile);
end

pollyConfig = loadjson(configFile);

%% convert the cellarray to array
depol_cal_ang_p_time = [];
depol_cal_ang_n_time = [];
for iCali = 1:length(pollyConfig.depol_cal_ang_p_time)
	depol_cal_ang_p_time = [depol_cal_ang_p_time, datenum(['00000100' pollyConfig.depol_cal_ang_p_time{iCali}], 'yyyymmddHH:MM:SS')];
	depol_cal_ang_n_time = [depol_cal_ang_n_time, datenum(['00000100' pollyConfig.depol_cal_ang_n_time{iCali}], 'yyyymmddHH:MM:SS')];
end
pollyConfig.depol_cal_ang_p_time = depol_cal_ang_p_time;
pollyConfig.depol_cal_ang_n_time = depol_cal_ang_n_time;

%% convert logical 
pollyConfig.isFR = logical(pollyConfig.isFR);
pollyConfig.isNR = logical(pollyConfig.isNR);
pollyConfig.is532nm = logical(pollyConfig.is532nm);
pollyConfig.is355nm = logical(pollyConfig.is355nm);
pollyConfig.is1064nm = logical(pollyConfig.is1064nm);
pollyConfig.isTot = logical(pollyConfig.isTot);
pollyConfig.isCross = logical(pollyConfig.isCross);
pollyConfig.is387nm = logical(pollyConfig.is387nm);
pollyConfig.is407nm = logical(pollyConfig.is407nm);
pollyConfig.is607nm = logical(pollyConfig.is607nm);

if ~ isstruct(pollyConfig)
	fprintf('Warning in load_polly_config: no polly configs were loaded.\n');
	return;
end

end
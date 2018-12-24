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
depol_cal_ang_p_time = pollyConfig.depol_cal_ang_p_time;
depol_cal_ang_n_time = pollyConfig.depol_cal_ang_n_time;
for iCali = 1:length(pollyConfig.depol_cal_ang_p_time)
	pollyConfig.depol_cal_ang_p_time = [pollyConfig.depol_cal_ang_p_time, datenum(0, 1, 0) + datenum(pollyConfig.depol_cal_ang_p_time{iCali}, 'HH:MM:SS')];
	pollyConfig.depol_cal_ang_n_time = [pollyConfig.depol_cal_ang_n_time, datenum(0, 1, 0) + datenum(pollyConfig.depol_cal_ang_n_time{iCali}, 'HH:MM:SS')];
end

if ~ isstruct(pollyConfig)
	fprintf('Warning in load_polly_config: no polly configs were loaded.\n');
	return;
end

end
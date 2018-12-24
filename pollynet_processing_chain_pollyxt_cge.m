function [] = pollynet_processing_chain_pollyxt_cge(taskInfo, config, campaignInfo)
%POLLYNET_PROCESSING_CHAIN_POLLYXT_CGE processing the data from pollyxt_cge
%	Example:
%		[] = pollynet_processing_chain_pollyxt_cge(taskInfo, config, campaignInfo)
%	Inputs:
%		taskInfo, config, campaignInfo
%	Outputs:
%		
%	History:
%		2018-12-17. First edition by Zhenping
%	Contact:
%		zhenping@tropos.de

%% read data
fprintf('\n[%s] Start to read %s data.\n%s\n', tNow(), taskInfo.pollyVersion, taskInfo.dataFullpath);
data = polly_read_rawdata(taskInfo.dataFullpath, pollyConfig);
fprintf('[%s] Finish reading data.\n', tNow());

%% read laserlogbook file
laserlogbookFile = sprintf('%s.laserlogbook.txt', taskInfo.dataFullpath);
fprintf('\n[%s] Start to read %s laserlogbook data.\n%s\n', tNow(), taskInfo.pollyVersion, laserlogbookFile);
health = polly_read_laserlogbook(laserlogbookFile, pollyConfig);
fprintf('[%s] Finish reading laserlogbook.\n', tNow);

%% pre-processing
fprintf('\n[%s] Start to preprocess %s data.\n', tNow(), taskInfo.pollyVersion);
data = polly_preprocess(data, pollyConfig);
fprintf('[%s] Finish signal preprocessing.\n', tNow());

%% depol calibration
fprintf('\n[%s] Start to calibrate %s depol channel.\n', tNow(), taskInfo.pollyVersion);
data = polly_depolcali(data, pollyConfig);
fprintf('[%s] Finish depol calibration.\n', tNow())

%% cloud screening

%% overlap estimation

%% rayleigh fitting

%% optical properties retrieving

%% lidar calibration

%% target classification

%% saving results
end
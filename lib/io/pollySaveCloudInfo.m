function pollySaveCloudInfo(data)
% POLLYSAVECLOUDINFO save cloud layering information to netcdf file.
%
% USAGE:
%    pollySaveCloudInfo(data)
%
% INPUTS:
%    data: struct
%
% HISTORY:
%    - 2021-06-09: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyDataInfo PollyConfig

if ~ isfield(data, 'clBaseH')
    warning('No available cloud information.');
    return;
end

ncfile = fullfile(PicassoConfig.results_folder, ...
                  CampaignConfig.name, ...
                  datestr(data.mTime(1), 'yyyy'), ...
                  datestr(data.mTime(1), 'mm'), ...
                  datestr(data.mTime(1), 'dd'), ...
                  sprintf('%s_cloudinfo.nc', rmext(PollyDataInfo.pollyDataFile)));

mode = netcdf.getConstant('NETCDF4');
mode = bitor(mode, netcdf.getConstant('CLASSIC_MODEL'));
mode = bitor(mode, netcdf.getConstant('CLOBBER'));
ncID = netcdf.create(ncfile, mode);

% define dimensions
dimID_layer_index = netcdf.defDim(ncID, 'layer_index', size(data.clBaseH, 1));
dimID_time = netcdf.defDim(ncID, 'time', length(data.mTime));
dimID_constant = netcdf.defDim(ncID, 'constant', 1);

% define variables
varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_FLOAT', dimID_constant);
varID_longitude = netcdf.defVar(ncID, 'longitude', 'NC_FLOAT', dimID_constant);
varID_latitude = netcdf.defVar(ncID, 'latitude', 'NC_FLOAT', dimID_constant);
varID_time = netcdf.defVar(ncID, 'time', 'NC_DOUBLE', dimID_time);
varID_layer_index = netcdf.defVar(ncID, 'layer_index', 'NC_BYTE', dimID_layer_index);
varID_cloud_base_height = netcdf.defVar(ncID, 'cloud_base_height', 'NC_FLOAT', [dimID_layer_index, dimID_time]);
varID_cloud_top_height = netcdf.defVar(ncID, 'cloud_top_height', 'NC_FLOAT', [dimID_layer_index, dimID_time]);
varID_cloud_phase = netcdf.defVar(ncID, 'cloud_phase', 'NC_BYTE', [dimID_layer_index, dimID_time]);
varID_cloud_phase_probability = netcdf.defVar(ncID, 'cloud_phase_probability', 'NC_FLOAT', [dimID_layer_index, dimID_time]);

% define the filling value
netcdf.defVarFill(ncID, varID_cloud_base_height, false, NaN);
netcdf.defVarFill(ncID, varID_cloud_top_height, false, NaN);
netcdf.defVarFill(ncID, varID_cloud_phase, false, 0);
netcdf.defVarFill(ncID, varID_cloud_phase_probability, false, NaN);

% define the data compression
netcdf.defVarDeflate(ncID, varID_cloud_base_height, true, true, 5);
netcdf.defVarDeflate(ncID, varID_cloud_top_height, true, true, 5);
netcdf.defVarDeflate(ncID, varID_cloud_phase, true, true, 5);
netcdf.defVarDeflate(ncID, varID_cloud_phase_probability, true, true, 5);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_altitude, single(data.alt0));
netcdf.putVar(ncID, varID_longitude, single(data.lon));
netcdf.putVar(ncID, varID_latitude, single(data.lat));
netcdf.putVar(ncID, varID_time, datenum_2_unix_timestamp(data.mTime));   % do the conversion
netcdf.putVar(ncID, varID_layer_index, int8(1:size(data.clBaseH, 1)));
netcdf.putVar(ncID, varID_cloud_base_height, single(data.clBaseH));
netcdf.putVar(ncID, varID_cloud_top_height, single(data.clTopH));
netcdf.putVar(ncID, varID_cloud_phase, int8(data.clPh));
netcdf.putVar(ncID, varID_cloud_phase_probability, single(data.clPhProb));

% re enter define mode
netcdf.reDef(ncID);

%% write attributes to the variables

% altitude
netcdf.putAtt(ncID, varID_altitude, 'unit', 'm');
netcdf.putAtt(ncID, varID_altitude, 'long_name', 'Height of lidar above mean sea level');
netcdf.putAtt(ncID, varID_altitude, 'standard_name', 'altitude');

% longitude
netcdf.putAtt(ncID, varID_longitude, 'unit', 'degrees_east');
netcdf.putAtt(ncID, varID_longitude, 'long_name', 'Longitude of the site');
netcdf.putAtt(ncID, varID_longitude, 'standard_name', 'longitude');
netcdf.putAtt(ncID, varID_longitude, 'axis', 'X');

% latitude
netcdf.putAtt(ncID, varID_latitude, 'unit', 'degrees_north');
netcdf.putAtt(ncID, varID_latitude, 'long_name', 'Latitude of the site');
netcdf.putAtt(ncID, varID_latitude, 'standard_name', 'latitude');
netcdf.putAtt(ncID, varID_latitude, 'axis', 'Y');

% time
netcdf.putAtt(ncID, varID_time, 'unit', 'seconds since 1970-01-01 00:00:00 UTC');
netcdf.putAtt(ncID, varID_time, 'long_name', 'Time UTC');
netcdf.putAtt(ncID, varID_time, 'standard_name', 'time');
netcdf.putAtt(ncID, varID_time, 'axis', 'T');
netcdf.putAtt(ncID, varID_time, 'calendar', 'julian');

% layer_index
netcdf.putAtt(ncID, varID_layer_index, 'unit', '');
netcdf.putAtt(ncID, varID_layer_index, 'long_name', 'cloud layer index');
netcdf.putAtt(ncID, varID_layer_index, 'standard_name', 'ith cloud');
netcdf.putAtt(ncID, varID_layer_index, 'axis', 'Z');

% cloud_base_height
netcdf.putAtt(ncID, varID_cloud_base_height, 'unit', 'm');
netcdf.putAtt(ncID, varID_cloud_base_height, 'long_name', 'cloud base height');
netcdf.putAtt(ncID, varID_cloud_base_height, 'standard_name', 'H_cb');
netcdf.putAtt(ncID, varID_cloud_base_height, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_cloud_base_height, 'comment', 'cloud base height for each classified cloud layer.');

% cloud_top_height
netcdf.putAtt(ncID, varID_cloud_top_height, 'unit', 'm');
netcdf.putAtt(ncID, varID_cloud_top_height, 'long_name', 'cloud top height');
netcdf.putAtt(ncID, varID_cloud_top_height, 'standard_name', 'H_ct');
netcdf.putAtt(ncID, varID_cloud_top_height, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_cloud_top_height, 'comment', 'cloud top height for each classified cloud layer.');

% cloud_phase
netcdf.putAtt(ncID, varID_cloud_phase, 'unit', '');
netcdf.putAtt(ncID, varID_cloud_phase, 'long_name', 'cloud phase');
netcdf.putAtt(ncID, varID_cloud_phase, 'standard_name', 'cloud_phase');
netcdf.putAtt(ncID, varID_cloud_phase, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_cloud_phase, 'comment', 'cloud phase for each classified cloud layer (0: unknow; 1: liquid; 2: ice; 3: mixed phase)');

% cloud_phase_probability
netcdf.putAtt(ncID, varID_cloud_phase_probability, 'unit', '');
netcdf.putAtt(ncID, varID_cloud_phase_probability, 'long_name', 'probability of cloud phase');
netcdf.putAtt(ncID, varID_cloud_phase_probability, 'standard_name', 'prob_cloud_phase');
netcdf.putAtt(ncID, varID_cloud_phase_probability, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_cloud_phase_probability, 'comment', 'probability for the cloud phase.');

varID_global = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncID, varID_global, 'Conventions', 'CF-1.0');
netcdf.putAtt(ncID, varID_global, 'Licence', 'Creative Commons Attribution Share Alike 4.0 International (CC BY-SA 4.0)');
netcdf.putAtt(ncID, varID_global, 'Data Policy', 'Each PollyNET site has Principal Investigator(s) (PI), responsible for deployment, maintenance and data collection. Information on which PI is responsible can be gathered via polly@tropos.de. The PI has priority use of the data collected at the site. The PI is entitled to be informed of any use of that data. Mandatory guidelines for data use and publication: Using PollyNET data or plots (also for presentations/workshops): Please consult with the PI or the PollyNET team (see contact_mail contact) before using data or plots! This will help to avoid misinterpretations of the lidar data and avoid the use of data from periods of malfunction of the instrument. Using PollyNET images/data on external websites: PIs and PollyNET must be asked for agreement and a link directed to polly.tropos.de must be included. Publishing PollyNET data and/or plots data: Offer authorship for the PI(s)! Acknowledge projects which have made the measurements possible according to PI(s) recommendation. PollyNET requests a notification of any published papers or reports or a brief description of other uses (e.g., posters, oral presentations, etc.) of data/plots used from PollyNET. This will help us determine the use of PollyNET data, which is helpful in optimizing product development and acquire new funding for future measurements. It also helps us to keep our product-related references up-to-date.');
netcdf.putAtt(ncID, varID_global, 'location', CampaignConfig.location);
netcdf.putAtt(ncID, varID_global, 'institute', PicassoConfig.institute);
netcdf.putAtt(ncID, varID_global, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_global, 'version', PicassoConfig.PicassoVersion);
netcdf.putAtt(ncID, varID_global, 'reference', PicassoConfig.homepage);
netcdf.putAtt(ncID, varID_global, 'contact', PicassoConfig.contact);
netcdf.putAtt(ncID, varID_global, 'PicassoConfig_Info', data.PicassoConfig_saving_info);
netcdf.putAtt(ncID, varID_global, 'PollyConfig_Info', data.PollyConfig_saving_info);
netcdf.putAtt(ncID, varID_global, 'CampaignConfig_Info', data.CampaignConfig_saving_info);
netcdf.putAtt(ncID, varID_global, 'PollyData_Info', data.PollyDataInfo_saving_info);
cwd = pwd;
cd(PicassoConfig.PicassoRootDir);
gitInfo = getGitInfo();
cd(cwd);
netcdf.putAtt(ncID, varID_global, 'history', sprintf('Last processing time at %s by %s, git branch: %s, git commit: %s', tNow, mfilename, gitInfo.branch, gitInfo.hash));

% close file
netcdf.close(ncID);

end
function pollySaveCloudInfo(data)
% pollySaveCloudInfo save cloud layering information to netcdf file.
% USAGE:
%    pollySaveCloudInfo(data)
% INPUTS:
%    data: struct
% EXAMPLE:
% HISTORY:
%    2021-06-09: first edition by Zhenping
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
netcdf.putAtt(ncID, varID_global, 'location', CampaignConfig.location);
netcdf.putAtt(ncID, varID_global, 'institute', PicassoConfig.institute);
netcdf.putAtt(ncID, varID_global, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_global, 'version', PicassoConfig.PicassoVersion);
netcdf.putAtt(ncID, varID_global, 'reference', PicassoConfig.homepage);
netcdf.putAtt(ncID, varID_global, 'PI', PollyConfig.PI);
netcdf.putAtt(ncID, varID_global, 'PI_affiliation', PollyConfig.PI_affiliation);
netcdf.putAtt(ncID, varID_global, 'PI_affiliation_acronym', PollyConfig.PI_affiliation_acronym);
netcdf.putAtt(ncID, varID_global, 'PI_address', PollyConfig.PI_address);
netcdf.putAtt(ncID, varID_global, 'PI_phone', PollyConfig.PI_phone);
netcdf.putAtt(ncID, varID_global, 'PI_email', PollyConfig.PI_email);
netcdf.putAtt(ncID, varID_global, 'Data_Originator', PollyConfig.Data_Originator);
netcdf.putAtt(ncID, varID_global, 'Data_Originator_affiliation', PollyConfig.Data_Originator_affiliation);
netcdf.putAtt(ncID, varID_global, 'Data_Originator_affiliation_acronym', PollyConfig.Data_Originator_affiliation_acronym);
netcdf.putAtt(ncID, varID_global, 'Data_Originator_address', PollyConfig.Data_Originator_address);
netcdf.putAtt(ncID, varID_global, 'Data_Originator_phone', PollyConfig.Data_Originator_phone);
netcdf.putAtt(ncID, varID_global, 'Data_Originator_email', PollyConfig.Data_Originator_email);
netcdf.putAtt(ncID, varID_global, 'title', 'cloud geometrical properties');
netcdf.putAtt(ncID, varID_global, 'comment', PollyConfig.comment);
cwd = pwd;
cd(PicassoConfig.PicassoRootDir);
gitInfo = getGitInfo();
cd(cwd);
netcdf.putAtt(ncID, varID_global, 'history', sprintf('Last processing time at %s by %s, git branch: %s, git commit: %s', tNow, mfilename, gitInfo.branch, gitInfo.hash));

% close file
netcdf.close(ncID);

end
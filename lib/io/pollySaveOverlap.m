function pollySaveOverlap(data, file)
% POLLYSAVEOVERLAP save overlap function.
%
% USAGE:
%    pollySaveOverlap(data, file)
%
% INPUTS:
%    data: struct
%    file: char
%
% HISTORY:
%   - 2018-12-21. First Edition by Zhenping
%   - 2019-05-16. Extended the attributes for all the variables and comply with the ACTRIS convention.
%   - 2019-09-27. Turn on the netCDF4 compression.
%   - 2023-09-28: Edition by Cristofer. Raman method added.
%
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyConfig

if isempty(data.rawSignal)
    return;
end

% convert empty array to defaults
overlap355 = data.olFunc355;
overlap532 = data.olFunc532;
overlap355Raman = data.olFunc355Raman;
overlap532Raman = data.olFunc532Raman;
overlap355Raman_raw = data.olFunc355Raman_raw;
overlap532Raman_raw = data.olFunc532Raman_raw;
LR_derived532=data.olAttri532Raman.LR_derived;
LR_derived355=data.olAttri355Raman.LR_derived;
overlap355Defaults = data.olFuncDeft355;
overlap532Defaults = data.olFuncDeft532;

if isempty(overlap532)
    overlap532 = -999 * ones(size(data.height));
end

if isempty(overlap355)
    overlap355 = -999 * ones(size(data.height));
end
if isempty(overlap532Raman)
    overlap532Raman = -999 * ones(size(data.height));
end
if isempty(overlap355Raman)
    overlap355Raman = -999 * ones(size(data.height));
end

if isempty(overlap532Raman_raw)
    overlap532Raman = -999 * ones(size(data.height));
end
if isempty(overlap355Raman_raw)
    overlap355Raman = -999 * ones(size(data.height));
end


if isempty(overlap355Defaults)
    overlap355Defaults = -999 * ones(size(data.height));
end
if isempty(overlap532Defaults)
    overlap532Defaults = -999 * ones(size(data.height));
end

% Create .nc file by overwriting any existing file with the name filename
mode = netcdf.getConstant('NETCDF4');
mode = bitor(mode, netcdf.getConstant('CLASSIC_MODEL'));
mode = bitor(mode, netcdf.getConstant('CLOBBER'));
ncID = netcdf.create(file, mode);

% define dimensions
dimID_height = netcdf.defDim(ncID, 'height', length(data.height));
dimID_time = netcdf.defDim(ncID, 'time', length(data.olAttri355.time));
dimID_method = netcdf.defDim(ncID, 'method', 1);
dimID_constant = netcdf.defDim(ncID, 'constant', 1);

%% define variables
varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_FLOAT', dimID_constant);
varID_longitude = netcdf.defVar(ncID, 'longitude', 'NC_FLOAT', dimID_constant);
varID_latitude = netcdf.defVar(ncID, 'latitude', 'NC_FLOAT', dimID_constant);
varID_startTime = netcdf.defVar(ncID, 'start_time', 'NC_DOUBLE', dimID_constant);
varID_endTime = netcdf.defVar(ncID, 'end_time', 'NC_DOUBLE', dimID_constant);
varID_height = netcdf.defVar(ncID, 'height', 'NC_FLOAT', dimID_height);
varID_time = netcdf.defVar(ncID, 'time', 'NC_FLOAT', dimID_time);
varID_tilt_angle = netcdf.defVar(ncID, 'tilt_angle', 'NC_FLOAT', dimID_constant);
varID_overlap532 = netcdf.defVar(ncID, 'overlap532', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_overlap355 = netcdf.defVar(ncID, 'overlap355', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_overlap532Raman = netcdf.defVar(ncID, 'overlap532Raman', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_overlap355Raman = netcdf.defVar(ncID, 'overlap355Raman', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_overlap532Raman_raw = netcdf.defVar(ncID, 'overlap532Raman_raw', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_overlap355Raman_raw = netcdf.defVar(ncID, 'overlap355Raman_raw', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_LR_derived532 = netcdf.defVar(ncID, 'LRderived532', 'NC_FLOAT', dimID_time);
varID_LR_derived355 = netcdf.defVar(ncID, 'LRderived355', 'NC_FLOAT', dimID_time);
varID_overlap532Defaults = netcdf.defVar(ncID, 'overlap532Defaults', 'NC_FLOAT', dimID_height);
varID_overlap355Defaults = netcdf.defVar(ncID, 'overlap355Defaults', 'NC_FLOAT', dimID_height);
varID_overlapCorMode = netcdf.defVar(ncID, 'correction_used', 'NC_SHORT', dimID_method);
varID_overlapCalMethod = netcdf.defVar(ncID, 'method', 'NC_SHORT', dimID_method);



% define the filling value
netcdf.defVarFill(ncID, varID_overlap532, false, -999);
netcdf.defVarFill(ncID, varID_overlap355, false, -999);
netcdf.defVarFill(ncID, varID_overlap532Raman, false, -999);
netcdf.defVarFill(ncID, varID_overlap355Raman, false, -999);
netcdf.defVarFill(ncID, varID_overlap532Raman_raw, false, -999);
netcdf.defVarFill(ncID, varID_overlap355Raman_raw, false, -999);
netcdf.defVarFill(ncID, varID_LR_derived532, false, -999);
netcdf.defVarFill(ncID, varID_LR_derived355, false, -999);
netcdf.defVarFill(ncID, varID_overlap532Defaults, false, -999);
netcdf.defVarFill(ncID, varID_overlap355Defaults, false, -999);

% define the data compression
netcdf.defVarDeflate(ncID, varID_overlap532, true, true, 5);
netcdf.defVarDeflate(ncID, varID_overlap355, true, true, 5);
netcdf.defVarDeflate(ncID, varID_overlap355Raman, true, true, 5);
netcdf.defVarDeflate(ncID, varID_overlap532Raman, true, true, 5);
netcdf.defVarDeflate(ncID, varID_overlap355Raman_raw, true, true, 5);
netcdf.defVarDeflate(ncID, varID_overlap532Raman_raw, true, true, 5);
netcdf.defVarDeflate(ncID, varID_LR_derived532, true, true, 5);
netcdf.defVarDeflate(ncID, varID_LR_derived355, true, true, 5);
netcdf.defVarDeflate(ncID, varID_overlap355Defaults, true, true, 5);
netcdf.defVarDeflate(ncID, varID_overlap532Defaults, true, true, 5);

% leave define mode
netcdf.endDef(ncID);

%% write data to .nc file
netcdf.putVar(ncID, varID_altitude, single(data.alt0));
netcdf.putVar(ncID, varID_longitude, single(data.lon));
netcdf.putVar(ncID, varID_latitude, single(data.lat));
netcdf.putVar(ncID, varID_startTime, datenum_2_unix_timestamp(data.mTime(1)));
netcdf.putVar(ncID, varID_endTime, datenum_2_unix_timestamp(data.mTime(end)));
netcdf.putVar(ncID, varID_height, single(data.height));
netcdf.putVar(ncID, varID_time, datenum_2_unix_timestamp(data.olAttri355.time));
netcdf.putVar(ncID, varID_tilt_angle, single(data.angle));
netcdf.putVar(ncID, varID_overlap532, single(overlap532));
netcdf.putVar(ncID, varID_overlap355, single(overlap355));
netcdf.putVar(ncID, varID_overlap532Raman, single(overlap532Raman));
netcdf.putVar(ncID, varID_overlap355Raman, single(overlap355Raman));
netcdf.putVar(ncID, varID_overlap532Raman_raw, single(overlap532Raman_raw));
netcdf.putVar(ncID, varID_overlap355Raman_raw, single(overlap355Raman_raw));
netcdf.putVar(ncID, varID_LR_derived532, single(LR_derived532));
netcdf.putVar(ncID, varID_LR_derived355, single(LR_derived355));
netcdf.putVar(ncID, varID_overlap532Defaults, single(overlap532Defaults));
netcdf.putVar(ncID, varID_overlap355Defaults, single(overlap355Defaults));
netcdf.putVar(ncID, varID_overlapCorMode, int16(PollyConfig.overlapCorMode));
netcdf.putVar(ncID, varID_overlapCalMethod, int16(PollyConfig.overlapCalMode));

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

% start_time
netcdf.putAtt(ncID, varID_startTime, 'unit', 'seconds since 1970-01-01 00:00:00 UTC');
netcdf.putAtt(ncID, varID_startTime, 'long_name', 'Time UTC to start the current measurement');
netcdf.putAtt(ncID, varID_startTime, 'standard_name', 'time');
netcdf.putAtt(ncID, varID_startTime, 'calendar', 'julian');

% end_time
netcdf.putAtt(ncID, varID_endTime, 'unit', 'seconds since 1970-01-01 00:00:00 UTC');
netcdf.putAtt(ncID, varID_endTime, 'long_name', 'Time UTC to finish the current measurement');
netcdf.putAtt(ncID, varID_endTime, 'standard_name', 'time');
netcdf.putAtt(ncID, varID_endTime, 'calendar', 'julian');

% height
netcdf.putAtt(ncID, varID_height, 'unit', 'm');
netcdf.putAtt(ncID, varID_height, 'long_name', 'Height above the ground');
netcdf.putAtt(ncID, varID_height, 'standard_name', 'height');
netcdf.putAtt(ncID, varID_height, 'axis', 'Z');

% time
netcdf.putAtt(ncID, varID_time, 'unit', 'seconds since 1970-01-01 00:00:00 UTC');
netcdf.putAtt(ncID, varID_time, 'long_name', 'Time UTC');
netcdf.putAtt(ncID, varID_time, 'standard_name', 'time');
netcdf.putAtt(ncID, varID_time, 'axis', 'T');
netcdf.putAtt(ncID, varID_time, 'calendar', 'julian');

% tilt_angle
netcdf.putAtt(ncID, varID_tilt_angle, 'unit', 'degrees');
netcdf.putAtt(ncID, varID_tilt_angle, 'long_name', 'Tilt angle of lidar device');
netcdf.putAtt(ncID, varID_tilt_angle, 'standard_name', 'tilt_angle');

% overlap 532
netcdf.putAtt(ncID, varID_overlap532, 'unit', '');
netcdf.putAtt(ncID, varID_overlap532, 'long_name', 'overlap function for 532nm far-range channel');
netcdf.putAtt(ncID, varID_overlap532, 'valid_min', 0.0);
netcdf.putAtt(ncID, varID_overlap532, 'valid_max', 100);
netcdf.putAtt(ncID, varID_overlap532, 'plot_range', [0, 1.1]);
netcdf.putAtt(ncID, varID_overlap532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_overlap532, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_overlap532, 'comment', 'This variable is not quality-assured. Only use with instructions from the PollyNET develop team.');

% overlap 355
netcdf.putAtt(ncID, varID_overlap355, 'unit', '');
netcdf.putAtt(ncID, varID_overlap355, 'long_name', 'overlap function for 355nm far-range channel');
netcdf.putAtt(ncID, varID_overlap355, 'valid_min', 0.0);
netcdf.putAtt(ncID, varID_overlap355, 'valid_max', 100);
netcdf.putAtt(ncID, varID_overlap355, 'plot_range', [0, 1.1]);
netcdf.putAtt(ncID, varID_overlap355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_overlap355, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_overlap355, 'comment', 'This variable is not quality-assured. Only use with instructions from the PollyNET develop team.');


% overlap 532 Raman
netcdf.putAtt(ncID, varID_overlap532Raman, 'unit', '');
netcdf.putAtt(ncID, varID_overlap532Raman, 'long_name', 'overlap function for 532nm far-range channel (Raman method)');
netcdf.putAtt(ncID, varID_overlap532Raman, 'valid_min', 0.0);
netcdf.putAtt(ncID, varID_overlap532Raman, 'valid_max', 100);
netcdf.putAtt(ncID, varID_overlap532Raman, 'plot_range', [0, 1.1]);
netcdf.putAtt(ncID, varID_overlap532Raman, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_overlap532Raman, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_overlap532Raman, 'comment', 'This variable is not quality-assured. Only use with instructions from the PollyNET develop team.');

% overlap 355 Raman
netcdf.putAtt(ncID, varID_overlap355Raman, 'unit', '');
netcdf.putAtt(ncID, varID_overlap355Raman, 'long_name', 'overlap function for 355nm far-range channel (Raman method)');
netcdf.putAtt(ncID, varID_overlap355Raman, 'valid_min', 0.0);
netcdf.putAtt(ncID, varID_overlap355Raman, 'valid_max', 100);
netcdf.putAtt(ncID, varID_overlap355Raman, 'plot_range', [0, 1.1]);
netcdf.putAtt(ncID, varID_overlap355Raman, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_overlap355Raman, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_overlap355Raman, 'comment', 'This variable is not quality-assured. Only use with instructions from the PollyNET develop team.');

% overlap 532 Raman (raw)
netcdf.putAtt(ncID, varID_overlap532Raman_raw, 'unit', '');
netcdf.putAtt(ncID, varID_overlap532Raman_raw, 'long_name', 'overlap function for 532nm far-range channel (Raman method -raw version)');
netcdf.putAtt(ncID, varID_overlap532Raman_raw, 'valid_min', 0.0);
netcdf.putAtt(ncID, varID_overlap532Raman_raw, 'valid_max', 100);
netcdf.putAtt(ncID, varID_overlap532Raman_raw, 'plot_range', [0, 1.1]);
netcdf.putAtt(ncID, varID_overlap532Raman_raw, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_overlap532Raman_raw, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_overlap532Raman_raw, 'comment', 'This variable is not quality-assured. Only use with instructions from the PollyNET develop team.');

% overlap 355 Raman (raw)
netcdf.putAtt(ncID, varID_overlap355Raman_raw, 'unit', '');
netcdf.putAtt(ncID, varID_overlap355Raman_raw, 'long_name', 'overlap function for 355nm far-range channel (Raman method - raw version)');
netcdf.putAtt(ncID, varID_overlap355Raman_raw, 'valid_min', 0.0);
netcdf.putAtt(ncID, varID_overlap355Raman_raw, 'valid_max', 100);
netcdf.putAtt(ncID, varID_overlap355Raman_raw, 'plot_range', [0, 1.1]);
netcdf.putAtt(ncID, varID_overlap355Raman_raw, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_overlap355Raman_raw, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_overlap355Raman_raw, 'comment', 'This variable is not quality-assured. Only use with instructions from the PollyNET develop team.');

% LR derived for optimal overlap function 532
netcdf.putAtt(ncID, varID_LR_derived532, 'unit', 'sr');
netcdf.putAtt(ncID, varID_LR_derived532, 'long_name', 'Extinction-to-backscattering ratio for optimal retrieval of overlap function (Raman method 532)');
netcdf.putAtt(ncID, varID_LR_derived532, 'valid_min', 0.0);
netcdf.putAtt(ncID, varID_LR_derived532, 'valid_max', 100);
netcdf.putAtt(ncID, varID_LR_derived532, 'plot_range', [0 100]);
netcdf.putAtt(ncID, varID_LR_derived532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LR_derived532, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_LR_derived532, 'comment', 'This variable is not quality-assured. Only use with instructions from the PollyNET develop team.');

% LR derived for optimal overlap function 355
netcdf.putAtt(ncID, varID_LR_derived355, 'unit', 'sr');
netcdf.putAtt(ncID, varID_LR_derived355, 'long_name', 'Extinction-to-backscattering ratio for optimal retrieval of overlap function (Raman method 532)');
netcdf.putAtt(ncID, varID_LR_derived355, 'valid_min', 0.0);
netcdf.putAtt(ncID, varID_LR_derived355, 'valid_max', 100);
netcdf.putAtt(ncID, varID_LR_derived355, 'plot_range', [0, 1.1]);
netcdf.putAtt(ncID, varID_LR_derived355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LR_derived355, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_LR_derived355, 'comment', 'This variable is not quality-assured. Only use with instructions from the PollyNET develop team.');


% Default overlap 532
netcdf.putAtt(ncID, varID_overlap532Defaults, 'unit', '');
netcdf.putAtt(ncID, varID_overlap532Defaults, 'long_name', 'Default overlap function for 532nm far-range channel');
netcdf.putAtt(ncID, varID_overlap532Defaults, 'valid_min', 0.0);
netcdf.putAtt(ncID, varID_overlap532Defaults, 'valid_max', 1.0);
netcdf.putAtt(ncID, varID_overlap532Defaults, 'plot_range', [0, 1.1]);
netcdf.putAtt(ncID, varID_overlap532Defaults, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_overlap532Defaults, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_overlap532Defaults, 'comment', 'This is the theoretical overlap function which is not identical to the real overlap function. Do not use it to correct the signal.');

% Default overlap 355
netcdf.putAtt(ncID, varID_overlap355Defaults, 'unit', '');
netcdf.putAtt(ncID, varID_overlap355Defaults, 'long_name', 'Default overlap function for 355nm far-range channel');
netcdf.putAtt(ncID, varID_overlap355Defaults, 'valid_min', 0.0);
netcdf.putAtt(ncID, varID_overlap355Defaults, 'valid_max', 1.0);
netcdf.putAtt(ncID, varID_overlap355Defaults, 'plot_range', [0, 1.1]);
netcdf.putAtt(ncID, varID_overlap355Defaults, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_overlap355Defaults, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_overlap355Defaults, 'comment', 'This is the theoretical overlap function which is not identical to the real overlap function. Do not use it to correct the signal.');

% overlap correction mode
netcdf.putAtt(ncID, varID_overlapCorMode, 'unit', '');
netcdf.putAtt(ncID, varID_overlapCorMode, 'long_name', 'Overlap correction mode');
netcdf.putAtt(ncID, varID_overlapCorMode, 'definition', '0: no overlap correction, 1:overlap correction with using the default overlap function, 2: overlap correction with using the calculated overlap function (NR/FR), 3: overlap correction with gluing near-range and far-range signal');

% overlap calibration method
netcdf.putAtt(ncID, varID_overlapCalMethod, 'unit', '');
netcdf.putAtt(ncID, varID_overlapCalMethod, 'long_name', 'Overlap calibration method');
netcdf.putAtt(ncID, varID_overlapCalMethod, 'definition', '1: signal ratio of near and far range signal; 2: Raman method (Wandinger and Ansmann 2002)');

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
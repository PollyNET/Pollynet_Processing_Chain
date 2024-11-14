function pollySaveRCS(data)
% POLLYSAVERCS save range corrected information to netcdf file.
%
% USAGE:
%    pollySaveRCS(data)
%
% INPUTS:
%    data: struct
%
% HISTORY:
%    - 2021-06-09: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyDataInfo PollyConfig

missing_value = -999999999;

ncfile = fullfile(PicassoConfig.results_folder, ...
                  CampaignConfig.name, ...
                  datestr(data.mTime(1), 'yyyy'), ...
                  datestr(data.mTime(1), 'mm'), ...
                  datestr(data.mTime(1), 'dd'), ...
                  sprintf('%s_RCS.nc', rmext(PollyDataInfo.pollyDataFile)));

mode = netcdf.getConstant('NETCDF4');
mode = bitor(mode, netcdf.getConstant('CLASSIC_MODEL'));
mode = bitor(mode, netcdf.getConstant('CLOBBER'));
ncID = netcdf.create(ncfile, mode);

% define dimensions
dimID_time = netcdf.defDim(ncID, 'time', length(data.mTime));
dimID_height = netcdf.defDim(ncID, 'height', length(data.height));
dimID_constant = netcdf.defDim(ncID, 'constant', 1);

% define variables
varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_FLOAT', dimID_constant);
varID_longitude = netcdf.defVar(ncID, 'longitude', 'NC_FLOAT', dimID_constant);
varID_latitude = netcdf.defVar(ncID, 'latitude', 'NC_FLOAT', dimID_constant);
varID_time = netcdf.defVar(ncID, 'time', 'NC_DOUBLE', dimID_time);
varID_height = netcdf.defVar(ncID, 'height', 'NC_FLOAT', dimID_height);
varID_rcs_fr_355 = netcdf.defVar(ncID, 'RCS_FR_355nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_fr_355x = netcdf.defVar(ncID, 'RCS_FR_cross_355nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_nr_355 = netcdf.defVar(ncID, 'RCS_NR_355nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_rr_355 = netcdf.defVar(ncID, 'RCS_RR_355nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_fr_387 = netcdf.defVar(ncID, 'RCS_FR_387nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_nr_387 = netcdf.defVar(ncID, 'RCS_NR_387nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_fr_407 = netcdf.defVar(ncID, 'RCS_FR_407nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_nr_407 = netcdf.defVar(ncID, 'RCS_NR_407nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_fr_532 = netcdf.defVar(ncID, 'RCS_FR_532nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_fr_532x = netcdf.defVar(ncID, 'RCS_FR_cross_532nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_fr_532p = netcdf.defVar(ncID, 'RCS_FR_parallel_532nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_nr_532 = netcdf.defVar(ncID, 'RCS_NR_532nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_nr_532x = netcdf.defVar(ncID, 'RCS_NR_cross_532nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_rr_532 = netcdf.defVar(ncID, 'RCS_RR_532nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_fr_607 = netcdf.defVar(ncID, 'RCS_FR_607nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_nr_607 = netcdf.defVar(ncID, 'RCS_NR_607nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_fr_1064 = netcdf.defVar(ncID, 'RCS_FR_1064nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_fr_1064x = netcdf.defVar(ncID, 'RCS_FR_cross_1064nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_rcs_rr_1064 = netcdf.defVar(ncID, 'RCS_RR_1064nm', 'NC_FLOAT', [dimID_height, dimID_time]);

% define the filling value
netcdf.defVarFill(ncID, varID_rcs_fr_355, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_fr_355x, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_nr_355, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_rr_355, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_fr_387, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_nr_387, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_fr_407, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_nr_407, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_fr_532, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_fr_532x, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_fr_532p, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_nr_532, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_nr_532x, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_rr_532, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_fr_607, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_nr_607, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_fr_1064, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_fr_1064x, false, missing_value);
netcdf.defVarFill(ncID, varID_rcs_rr_1064, false, missing_value);

% define the data compression
netcdf.defVarDeflate(ncID, varID_rcs_fr_355, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_fr_355x, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_nr_355, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_rr_355, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_fr_387, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_nr_387, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_fr_407, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_nr_407, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_fr_532, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_fr_532x, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_fr_532p, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_nr_532, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_nr_532x, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_rr_532, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_fr_607, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_nr_607, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_fr_1064, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_fr_1064x, true, true, 5);
netcdf.defVarDeflate(ncID, varID_rcs_rr_1064, true, true, 5);

% leave define mode
netcdf.endDef(ncID);

%% channel-labeling
flag355FR = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
flag355FRx = data.flagFarRangeChannel & data.flag355nmChannel & data.flagCrossChannel;
flag355NR = data.flagNearRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
flag355RR = data.flag355nmChannel & data.flagRotRamanChannel;
flag387FR = data.flagFarRangeChannel & data.flag387nmChannel;
flag387NR = data.flagNearRangeChannel & data.flag387nmChannel;
flag407FR = data.flagFarRangeChannel & data.flag407nmChannel;
flag407NR = data.flagNearRangeChannel & data.flag407nmChannel;
flag532FR = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flag532FRx = data.flagFarRangeChannel & data.flag532nmChannel & data.flagCrossChannel;
flag532FRp = data.flagFarRangeChannel & data.flag532nmChannel & data.flagParallelChannel;
flag532NR = data.flagNearRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flag532NRx = data.flagNearRangeChannel & data.flag532nmChannel & data.flagCrossChannel;
flag532RR = data.flag532nmChannel & data.flagRotRamanChannel;
flag607FR = data.flagFarRangeChannel & data.flag607nmChannel;
flag607NR = data.flagNearRangeChannel & data.flag607nmChannel;
flag1064FR = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagTotalChannel;
flag1064FRx = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagCrossChannel;
flag1064RR = data.flag1064nmChannel & data.flagRotRamanChannel; %% 1058nm Rotational Raman of 1064nm

%% calculate RCS values and write to nc-file
if (sum(flag355FR) == 1)
    RCS_FR_355 = squeeze(data.signal(flag355FR, :, :)) ./ repmat(data.mShots(flag355FR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_fr_355, single(fillmissing(RCS_FR_355, missing_value)));
end
if (sum(flag355FRx) == 1)
    RCS_FR_355x = squeeze(data.signal(flag355FRx, :, :)) ./ repmat(data.mShots(flag355FRx, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_fr_355x, single(fillmissing(RCS_FR_355x, missing_value)));
end
if (sum(flag355NR) == 1)
    RCS_NR_355 = squeeze(data.signal(flag355NR, :, :)) ./ repmat(data.mShots(flag355NR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_nr_355, single(fillmissing(RCS_NR_355, missing_value)));
end
if (sum(flag355RR) == 1)
    RCS_RR_355 = squeeze(data.signal(flag355RR, :, :)) ./ repmat(data.mShots(flag355RR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_rr_355, single(fillmissing(RCS_RR_355, missing_value)));
end
if (sum(flag387FR) == 1)
    RCS_FR_387 = squeeze(data.signal(flag387FR, :, :)) ./ repmat(data.mShots(flag387FR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_fr_387, single(fillmissing(RCS_FR_387, missing_value)));
end
if (sum(flag387NR) == 1)
    RCS_NR_387 = squeeze(data.signal(flag387NR, :, :)) ./ repmat(data.mShots(flag387NR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_nr_387, single(fillmissing(RCS_NR_387, missing_value)));
end
if (sum(flag407FR) == 1)
    RCS_FR_407 = squeeze(data.signal(flag407FR, :, :)) ./ repmat(data.mShots(flag407FR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_fr_407, single(fillmissing(RCS_FR_407, missing_value)));
end
if (sum(flag407NR) == 1)
    RCS_NR_407 = squeeze(data.signal(flag407NR, :, :)) ./ repmat(data.mShots(flag407NR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_nr_407, single(fillmissing(RCS_NR_407, missing_value)));
end
if (sum(flag532FR) == 1)
    RCS_FR_532 = squeeze(data.signal(flag532FR, :, :)) ./ repmat(data.mShots(flag532FR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_fr_532, single(fillmissing(RCS_FR_532, missing_value)));
end
if (sum(flag532FRx) == 1)
    RCS_FR_532x = squeeze(data.signal(flag532FRx, :, :)) ./ repmat(data.mShots(flag532FRx, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_fr_532x, single(fillmissing(RCS_FR_532x, missing_value)));
end
if (sum(flag532FRp) == 1)
    RCS_FR_532p = squeeze(data.signal(flag532FRp, :, :)) ./ repmat(data.mShots(flag532FRp, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_fr_532p, single(fillmissing(RCS_FR_532p, missing_value)));
end
if (sum(flag532NR) == 1)
    RCS_NR_532 = squeeze(data.signal(flag532NR, :, :)) ./ repmat(data.mShots(flag532NR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_nr_532, single(fillmissing(RCS_NR_532, missing_value)));
end
if (sum(flag532NRx) == 1)
    RCS_NR_532x = squeeze(data.signal(flag532NRx, :, :)) ./ repmat(data.mShots(flag532NRx, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_nr_532x, single(fillmissing(RCS_NR_532x, missing_value)));
end
if (sum(flag532RR) == 1)
    RCS_RR_532 = squeeze(data.signal(flag532RR, :, :)) ./ repmat(data.mShots(flag532RR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_rr_532, single(fillmissing(RCS_RR_532, missing_value)));
end
if (sum(flag607FR) == 1)
    RCS_FR_607 = squeeze(data.signal(flag607FR, :, :)) ./ repmat(data.mShots(flag607FR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_fr_607, single(fillmissing(RCS_FR_607, missing_value)));
end
if (sum(flag607NR) == 1)
    RCS_NR_607 = squeeze(data.signal(flag607NR, :, :)) ./ repmat(data.mShots(flag607NR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_nr_607, single(fillmissing(RCS_NR_607, missing_value)));
end
if (sum(flag1064FR) == 1)
    RCS_FR_1064 = squeeze(data.signal(flag1064FR, :, :)) ./ repmat(data.mShots(flag1064FR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_fr_1064, single(fillmissing(RCS_FR_1064, missing_value)));
end
if (sum(flag1064FRx) == 1)
    RCS_FR_1064x = squeeze(data.signal(flag1064FRx, :, :)) ./ repmat(data.mShots(flag1064FRx, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_fr_1064x, single(fillmissing(RCS_FR_1064x, missing_value)));
end
if (sum(flag1064RR) == 1)
    RCS_RR_1064 = squeeze(data.signal(flag1064RR, :, :)) ./ repmat(data.mShots(flag1064RR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    netcdf.putVar(ncID, varID_rcs_rr_1064, single(fillmissing(RCS_RR_1064, missing_value)));
end



% write data to .nc file
netcdf.putVar(ncID, varID_altitude, single(data.alt0));
netcdf.putVar(ncID, varID_longitude, single(data.lon));
netcdf.putVar(ncID, varID_latitude, single(data.lat));
netcdf.putVar(ncID, varID_time, datenum_2_unix_timestamp(data.mTime));   % do the conversion
netcdf.putVar(ncID, varID_height, single(data.height));

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

% height
netcdf.putAtt(ncID, varID_height, 'unit', 'm');
netcdf.putAtt(ncID, varID_height, 'long_name', 'Height above the ground');
netcdf.putAtt(ncID, varID_height, 'standard_name', 'height');
netcdf.putAtt(ncID, varID_height, 'axis', 'Z');

% RCS_FR_355
netcdf.putAtt(ncID, varID_rcs_fr_355, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_355, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_355, 'long_name', 'range corrected signal far-range at 355 nm');
netcdf.putAtt(ncID, varID_rcs_fr_355, 'standard_name', 'RCS_FR_355');
netcdf.putAtt(ncID, varID_rcs_fr_355, 'plot_range', PollyConfig.zLim_FR_RCS_355);
netcdf.putAtt(ncID, varID_rcs_fr_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_fr_355, 'source', CampaignConfig.name);

% RCS_FR_355x
netcdf.putAtt(ncID, varID_rcs_fr_355x, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_355x, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_355x, 'long_name', 'range corrected signal far-range at 355 nm cross-channel');
netcdf.putAtt(ncID, varID_rcs_fr_355x, 'standard_name', 'RCS_FR_355x');
netcdf.putAtt(ncID, varID_rcs_fr_355x, 'plot_range', PollyConfig.zLim_FR_RCS_355);
netcdf.putAtt(ncID, varID_rcs_fr_355x, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_fr_355x, 'source', CampaignConfig.name);

% RCS_NR_355
netcdf.putAtt(ncID, varID_rcs_nr_355, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_nr_355, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_nr_355, 'long_name', 'range corrected signal near-range at 355 nm');
netcdf.putAtt(ncID, varID_rcs_nr_355, 'standard_name', 'RCS_NR_355');
netcdf.putAtt(ncID, varID_rcs_nr_355, 'plot_range', PollyConfig.zLim_NR_RCS_355);
netcdf.putAtt(ncID, varID_rcs_nr_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_nr_355, 'source', CampaignConfig.name);

% RCS_RR_355
netcdf.putAtt(ncID, varID_rcs_rr_355, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_rr_355, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_rr_355, 'long_name', 'range corrected signal rotational Raman at 355 nm');
netcdf.putAtt(ncID, varID_rcs_rr_355, 'standard_name', 'RCS_RR_355');
netcdf.putAtt(ncID, varID_rcs_rr_355, 'plot_range', PollyConfig.zLim_FR_RCS_355);
netcdf.putAtt(ncID, varID_rcs_rr_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_rr_355, 'source', CampaignConfig.name);

% RCS_FR_387
netcdf.putAtt(ncID, varID_rcs_fr_387, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_387, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_387, 'long_name', 'range corrected signal far-range at 387 nm');
netcdf.putAtt(ncID, varID_rcs_fr_387, 'standard_name', 'RCS_FR_387');
netcdf.putAtt(ncID, varID_rcs_fr_387, 'plot_range', PollyConfig.zLim_FR_RCS_355);
netcdf.putAtt(ncID, varID_rcs_fr_387, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_fr_387, 'source', CampaignConfig.name);

% RCS_NR_387
netcdf.putAtt(ncID, varID_rcs_nr_387, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_nr_387, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_nr_387, 'long_name', 'range corrected signal near-range at 387 nm');
netcdf.putAtt(ncID, varID_rcs_nr_387, 'standard_name', 'RCS_NR_387');
netcdf.putAtt(ncID, varID_rcs_nr_387, 'plot_range', PollyConfig.zLim_NR_RCS_355);
netcdf.putAtt(ncID, varID_rcs_nr_387, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_nr_387, 'source', CampaignConfig.name);

% RCS_FR_407
netcdf.putAtt(ncID, varID_rcs_fr_407, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_407, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_407, 'long_name', 'range corrected signal far-range at 407 nm');
netcdf.putAtt(ncID, varID_rcs_fr_407, 'standard_name', 'RCS_FR_407');
netcdf.putAtt(ncID, varID_rcs_fr_407, 'plot_range', PollyConfig.zLim_FR_RCS_532);
netcdf.putAtt(ncID, varID_rcs_fr_407, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_fr_407, 'source', CampaignConfig.name);

% RCS_NR_407
netcdf.putAtt(ncID, varID_rcs_nr_407, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_nr_407, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_nr_407, 'long_name', 'range corrected signal near-range at 407 nm');
netcdf.putAtt(ncID, varID_rcs_nr_407, 'standard_name', 'RCS_NR_407');
netcdf.putAtt(ncID, varID_rcs_nr_407, 'plot_range', PollyConfig.zLim_NR_RCS_532);
netcdf.putAtt(ncID, varID_rcs_nr_407, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_nr_407, 'source', CampaignConfig.name);

% RCS_FR_532
netcdf.putAtt(ncID, varID_rcs_fr_532, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_532, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_532, 'long_name', 'range corrected signal far-range at 532 nm');
netcdf.putAtt(ncID, varID_rcs_fr_532, 'standard_name', 'RCS_FR_532');
netcdf.putAtt(ncID, varID_rcs_fr_532, 'plot_range', PollyConfig.zLim_FR_RCS_532);
netcdf.putAtt(ncID, varID_rcs_fr_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_fr_532, 'source', CampaignConfig.name);

% RCS_FR_532x
netcdf.putAtt(ncID, varID_rcs_fr_532x, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_532x, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_532x, 'long_name', 'range corrected signal far-range at 532 nm cross-channel');
netcdf.putAtt(ncID, varID_rcs_fr_532x, 'standard_name', 'RCS_FR_532x');
netcdf.putAtt(ncID, varID_rcs_fr_532x, 'plot_range', PollyConfig.zLim_FR_RCS_532);
netcdf.putAtt(ncID, varID_rcs_fr_532x, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_fr_532x, 'source', CampaignConfig.name);

% RCS_NR_532
netcdf.putAtt(ncID, varID_rcs_nr_532, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_nr_532, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_nr_532, 'long_name', 'range corrected signal near-range at 532 nm');
netcdf.putAtt(ncID, varID_rcs_nr_532, 'standard_name', 'RCS_NR_532');
netcdf.putAtt(ncID, varID_rcs_nr_532, 'plot_range', PollyConfig.zLim_NR_RCS_532);
netcdf.putAtt(ncID, varID_rcs_nr_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_nr_532, 'source', CampaignConfig.name);

% RCS_NR_532x
netcdf.putAtt(ncID, varID_rcs_nr_532x, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_nr_532x, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_nr_532x, 'long_name', 'range corrected signal near-range at 532 nm cross-channel');
netcdf.putAtt(ncID, varID_rcs_nr_532x, 'standard_name', 'RCS_NR_532x');
netcdf.putAtt(ncID, varID_rcs_nr_532x, 'plot_range', PollyConfig.zLim_NR_RCS_532);
netcdf.putAtt(ncID, varID_rcs_nr_532x, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_nr_532x, 'source', CampaignConfig.name);

% RCS_RR_532
netcdf.putAtt(ncID, varID_rcs_rr_532, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_rr_532, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_rr_532, 'long_name', 'range corrected signal rotational Raman at 532 nm');
netcdf.putAtt(ncID, varID_rcs_rr_532, 'standard_name', 'RCS_RR_532');
netcdf.putAtt(ncID, varID_rcs_rr_532, 'plot_range', PollyConfig.zLim_FR_RCS_532);
netcdf.putAtt(ncID, varID_rcs_rr_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_rr_532, 'source', CampaignConfig.name);

% RCS_FR_607
netcdf.putAtt(ncID, varID_rcs_fr_607, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_607, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_607, 'long_name', 'range corrected signal far-range at 607 nm');
netcdf.putAtt(ncID, varID_rcs_fr_607, 'standard_name', 'RCS_FR_607');
netcdf.putAtt(ncID, varID_rcs_fr_607, 'plot_range', PollyConfig.zLim_FR_RCS_532);
netcdf.putAtt(ncID, varID_rcs_fr_607, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_fr_607, 'source', CampaignConfig.name);

% RCS_NR_607
netcdf.putAtt(ncID, varID_rcs_nr_607, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_nr_607, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_nr_607, 'long_name', 'range corrected signal near-range at 607 nm');
netcdf.putAtt(ncID, varID_rcs_nr_607, 'standard_name', 'RCS_NR_607');
netcdf.putAtt(ncID, varID_rcs_nr_607, 'plot_range', PollyConfig.zLim_NR_RCS_532);
netcdf.putAtt(ncID, varID_rcs_nr_607, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_nr_607, 'source', CampaignConfig.name);

% RCS_FR_1064
netcdf.putAtt(ncID, varID_rcs_fr_1064, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_1064, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_1064, 'long_name', 'range corrected signal far-range at 1064 nm');
netcdf.putAtt(ncID, varID_rcs_fr_1064, 'standard_name', 'RCS_FR_1064');
netcdf.putAtt(ncID, varID_rcs_fr_1064, 'plot_range', PollyConfig.zLim_FR_RCS_1064);
netcdf.putAtt(ncID, varID_rcs_fr_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_fr_1064, 'source', CampaignConfig.name);

% RCS_FR_1064x
netcdf.putAtt(ncID, varID_rcs_fr_1064x, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_1064x, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_fr_1064x, 'long_name', 'range corrected signal far-range at 1064 nm cross-channel');
netcdf.putAtt(ncID, varID_rcs_fr_1064x, 'standard_name', 'RCS_FR_1064x');
netcdf.putAtt(ncID, varID_rcs_fr_1064x, 'plot_range', PollyConfig.zLim_FR_RCS_1064);
netcdf.putAtt(ncID, varID_rcs_fr_1064x, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_fr_1064x, 'source', CampaignConfig.name);

% RCS_RR_1064
netcdf.putAtt(ncID, varID_rcs_rr_1064, 'unit', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_rr_1064, 'unit_html', 'a.u.');
netcdf.putAtt(ncID, varID_rcs_rr_1064, 'long_name', 'range corrected signal rotational Raman at 1064 nm');
netcdf.putAtt(ncID, varID_rcs_rr_1064, 'standard_name', 'RCS_RR_1064');
netcdf.putAtt(ncID, varID_rcs_rr_1064, 'plot_range', PollyConfig.zLim_FR_RCS_1064);
netcdf.putAtt(ncID, varID_rcs_rr_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_rcs_rr_1064, 'source', CampaignConfig.name);


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

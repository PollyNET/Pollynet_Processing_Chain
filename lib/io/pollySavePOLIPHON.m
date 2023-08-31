function pollySavePOLIPHON(data, POLIPHON1)
%POLLYSAVEPOLIPHON save POLIPHON_one results 
%
% INPUTS:
%    data: struct
%    POLIPHON1 : struct
%
% HISTORY:
%    - 2023-06-26: first edition by Athena A. Floutsi 
%
% .. Authors: - floutsi@tropos.de
global PicassoConfig CampaignConfig PollyDataInfo PollyConfig
missing_value = -999;

for iGrp = 1:size(data.clFreGrps, 1)
ncFile = fullfile(PicassoConfig.results_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_POLIPHON_1.nc', rmext(PollyDataInfo.pollyDataFile), datestr(data.mTime(data.clFreGrps(iGrp, 1)), 'HHMM'), datestr(data.mTime(data.clFreGrps(iGrp, 2)), 'HHMM')));
startTime = data.mTime(data.clFreGrps(iGrp, 1));
endTime = data.mTime(data.clFreGrps(iGrp, 2));

mode = netcdf.getConstant('NETCDF4');
mode = bitor(mode, netcdf.getConstant('CLASSIC_MODEL'));
mode = bitor(mode, netcdf.getConstant('CLOBBER'));
ncID = netcdf.create(ncFile, mode);

% define dimensions
dimID_height = netcdf.defDim(ncID, 'height', length(data.height));
dimID_method = netcdf.defDim(ncID, 'method', 1);
dimID_time = netcdf.defDim(ncID, 'time', length(data.mTime));


% define variables
varID_altitude  = netcdf.defVar(ncID, 'altitude', 'NC_FLOAT', dimID_method);
varID_longitude = netcdf.defVar(ncID, 'longitude', 'NC_FLOAT', dimID_method);
varID_latitude  = netcdf.defVar(ncID, 'latitude', 'NC_FLOAT', dimID_method);
varID_startTime = netcdf.defVar(ncID, 'start_time', 'NC_DOUBLE', dimID_method);
varID_endTime   = netcdf.defVar(ncID, 'end_time', 'NC_DOUBLE', dimID_method);
varID_height    = netcdf.defVar(ncID, 'height', 'NC_FLOAT', dimID_height);
varID_time      = netcdf.defVar(ncID, 'time', 'NC_FLOAT', dimID_time);

varID_aerBsc_klett_355     = netcdf.defVar(ncID, 'aerBsc_klett_355', 'NC_FLOAT', dimID_height);
varID_aerBscStd_klett_355  = netcdf.defVar(ncID, 'uncertainty_aerBsc_klett_355', 'NC_FLOAT', dimID_height);
varID_aerBsc_klett_532     = netcdf.defVar(ncID, 'aerBsc_klett_532', 'NC_FLOAT', dimID_height);
varID_aerBscStd_klett_532  = netcdf.defVar(ncID, 'uncertainty_aerBsc_klett_532', 'NC_FLOAT', dimID_height);
varID_aerBsc_klett_1064    = netcdf.defVar(ncID, 'aerBsc_klett_1064', 'NC_FLOAT', dimID_height);
varID_aerBscStd_klett_1064 = netcdf.defVar(ncID, 'uncertainty_aerBsc_klett_1064', 'NC_FLOAT', dimID_height);
varID_aerBsc_raman_355     = netcdf.defVar(ncID, 'aerBsc_raman_355', 'NC_FLOAT', dimID_height);
varID_aerBscStd_raman_355  = netcdf.defVar(ncID, 'uncertainty_aerBsc_raman_355', 'NC_FLOAT', dimID_height);
varID_aerBsc_raman_532     = netcdf.defVar(ncID, 'aerBsc_raman_532', 'NC_FLOAT', dimID_height);
varID_aerBscStd_raman_532  = netcdf.defVar(ncID, 'uncertainty_aerBsc_raman_532', 'NC_FLOAT', dimID_height);
varID_aerBsc_raman_1064    = netcdf.defVar(ncID, 'aerBsc_raman_1064', 'NC_FLOAT', dimID_height);
varID_aerBscStd_raman_1064 = netcdf.defVar(ncID, 'uncertainty_aerBsc_raman_1064', 'NC_FLOAT', dimID_height);

varID_aerBsc355_klett_d1       = netcdf.defVar(ncID, 'aerBsc355_klett_d1', 'NC_FLOAT', dimID_height);
varID_err_aerBsc355_klett_d1   = netcdf.defVar(ncID, 'uncertainty_aerBsc355_klett_d1', 'NC_FLOAT', dimID_height);
varID_aerBsc355_klett_nd1      = netcdf.defVar(ncID, 'aerBsc355_klett_nd1', 'NC_FLOAT', dimID_height);
varID_err_aerBsc355_klett_nd1  = netcdf.defVar(ncID, 'uncertainty_aerBsc355_klett_nd1', 'NC_FLOAT', dimID_height);
varID_aerBsc532_klett_d1       = netcdf.defVar(ncID, 'aerBsc532_klett_d1', 'NC_FLOAT', dimID_height);
varID_err_aerBsc532_klett_d1   = netcdf.defVar(ncID, 'uncertainty_aerBsc532_klett_d1', 'NC_FLOAT', dimID_height);
varID_aerBsc532_klett_nd1      = netcdf.defVar(ncID, 'aerBsc532_klett_nd1', 'NC_FLOAT', dimID_height);
varID_err_aerBsc532_klett_nd1  = netcdf.defVar(ncID, 'uncertainty_aerBsc532_klett_nd1', 'NC_FLOAT', dimID_height);
varID_aerBsc1064_klett_d1      = netcdf.defVar(ncID, 'aerBsc1064_klett_d1', 'NC_FLOAT', dimID_height);
varID_err_aerBsc1064_klett_d1  = netcdf.defVar(ncID, 'uncertainty_aerBsc1064_klett_d1', 'NC_FLOAT', dimID_height);
varID_aerBsc1064_klett_nd1     = netcdf.defVar(ncID, 'aerBsc1064_klett_nd1', 'NC_FLOAT', dimID_height);
varID_err_aerBsc1064_klett_nd1 = netcdf.defVar(ncID, 'uncertainty_aerBsc1064__nd1', 'NC_FLOAT', dimID_height);

varID_aerBsc355_raman_d1       = netcdf.defVar(ncID, 'aerBsc355_raman_d1', 'NC_FLOAT', dimID_height);
varID_err_aerBsc355_raman_d1   = netcdf.defVar(ncID, 'uncertainty_aerBsc355_raman_d1', 'NC_FLOAT', dimID_height);
varID_aerBsc355_raman_nd1      = netcdf.defVar(ncID, 'aerBsc355_raman_nd1', 'NC_FLOAT', dimID_height);
varID_err_aerBsc355_raman_nd1  = netcdf.defVar(ncID, 'uncertainty_aerBsc355_raman_nd1', 'NC_FLOAT', dimID_height);
varID_aerBsc532_raman_d1       = netcdf.defVar(ncID, 'aerBsc532_raman_d1', 'NC_FLOAT', dimID_height);
varID_err_aerBsc532_raman_d1   = netcdf.defVar(ncID, 'uncertainty_aerBsc532_raman_d1', 'NC_FLOAT', dimID_height);
varID_aerBsc532_raman_nd1      = netcdf.defVar(ncID, 'aerBsc532_raman_nd1', 'NC_FLOAT', dimID_height);
varID_err_aerBsc532_raman_nd1  = netcdf.defVar(ncID, 'uncertainty_aerBsc532_raman_nd1', 'NC_FLOAT', dimID_height);
varID_aerBsc1064_raman_d1      = netcdf.defVar(ncID, 'aerBsc1064_raman_d1', 'NC_FLOAT', dimID_height);
varID_err_aerBsc1064_raman_d1  = netcdf.defVar(ncID, 'uncertainty_aerBsc1064_raman_d1', 'NC_FLOAT', dimID_height);
varID_aerBsc1064_raman_nd1     = netcdf.defVar(ncID, 'aerBsc1064_raman_nd1', 'NC_FLOAT', dimID_height);
varID_err_aerBsc1064_raman_nd1 = netcdf.defVar(ncID, 'uncertainty_aerBsc1064_raman_nd1', 'NC_FLOAT', dimID_height);

% define the filling value
netcdf.defVarFill(ncID, varID_aerBsc_klett_355, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBscStd_klett_355, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc_klett_532, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBscStd_klett_532, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc_klett_1064, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBscStd_klett_1064, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc_raman_355, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc_raman_532, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBscStd_raman_532, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc_raman_1064, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBscStd_raman_1064, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc355_klett_d1, false, missing_value);
netcdf.defVarFill(ncID, varID_err_aerBsc355_klett_d1, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc355_klett_nd1, false, missing_value);
netcdf.defVarFill(ncID, varID_err_aerBsc355_klett_nd1, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc532_klett_d1, false, missing_value);
netcdf.defVarFill(ncID, varID_err_aerBsc532_klett_d1, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc532_klett_nd1, false, missing_value);
netcdf.defVarFill(ncID, varID_err_aerBsc532_klett_nd1, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc1064_klett_d1, false, missing_value);
netcdf.defVarFill(ncID, varID_err_aerBsc1064_klett_d1, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc1064_klett_nd1, false, missing_value);
netcdf.defVarFill(ncID, varID_err_aerBsc1064_klett_nd1, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc355_raman_d1, false, missing_value);
netcdf.defVarFill(ncID, varID_err_aerBsc355_raman_d1, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc355_raman_nd1, false, missing_value);
netcdf.defVarFill(ncID, varID_err_aerBsc355_raman_nd1, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc532_raman_d1, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc532_raman_d1, false, missing_value);
netcdf.defVarFill(ncID, varID_err_aerBsc532_raman_d1, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc532_raman_nd1, false, missing_value);
netcdf.defVarFill(ncID, varID_err_aerBsc532_raman_nd1, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc1064_raman_d1, false, missing_value);
netcdf.defVarFill(ncID, varID_err_aerBsc1064_raman_d1, false, missing_value);
netcdf.defVarFill(ncID, varID_aerBsc1064_raman_nd1, false, missing_value);
netcdf.defVarFill(ncID, varID_err_aerBsc1064_raman_nd1 , false, missing_value);     

% define the data compression
netcdf.defVarDeflate(ncID, varID_aerBsc_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBscStd_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBsc_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBscStd_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBsc_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBscStd_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBsc_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBscStd_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBsc_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBscStd_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBsc_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBscStd_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBsc355_klett_d1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_err_aerBsc355_klett_d1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBsc355_klett_nd1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_err_aerBsc355_klett_nd1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBsc532_klett_d1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_err_aerBsc532_klett_d1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBsc532_klett_nd1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_err_aerBsc532_klett_nd1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBsc1064_klett_d1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_err_aerBsc1064_klett_d1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBsc1064_klett_nd1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_err_aerBsc1064_klett_nd1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBsc355_raman_d1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_err_aerBsc355_raman_d1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBsc355_raman_nd1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_err_aerBsc355_raman_nd1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBsc532_raman_d1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_err_aerBsc532_raman_d1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBsc532_raman_nd1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_err_aerBsc532_raman_nd1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBsc1064_raman_d1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_err_aerBsc1064_raman_d1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_aerBsc1064_raman_nd1, true, true, 5);
netcdf.defVarDeflate(ncID, varID_err_aerBsc1064_raman_nd1, true, true, 5);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_altitude, single(data.alt0));
netcdf.putVar(ncID, varID_longitude, single(data.lon));
netcdf.putVar(ncID, varID_latitude, single(data.lat));
netcdf.putVar(ncID, varID_startTime, datenum_2_unix_timestamp(data.mTime(1)));
netcdf.putVar(ncID, varID_endTime, datenum_2_unix_timestamp(data.mTime(end)));
netcdf.putVar(ncID, varID_height, single(data.height));

netcdf.putVar(ncID, varID_aerBsc_klett_355, single(fillmissing(data.aerBsc355_klett(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_aerBscStd_klett_355, single(fillmissing(data.aerBscStd355_klett(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_aerBsc_klett_532, single(fillmissing(data.aerBsc532_klett(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_aerBscStd_klett_532, single(fillmissing(data.aerBscStd532_klett(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_aerBsc_klett_1064, single(fillmissing(data.aerBsc1064_klett(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_aerBscStd_klett_1064, single(fillmissing(data.aerBscStd1064_klett(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_aerBsc_raman_355, single(fillmissing(data.aerBsc355_raman(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_aerBscStd_raman_355, single(fillmissing(data.aerBscStd355_raman(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_aerBsc_raman_532, single(fillmissing(data.aerBsc532_raman(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_aerBscStd_raman_532, single(fillmissing(data.aerBscStd532_raman(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_aerBsc_raman_1064, single(fillmissing(data.aerBsc1064_raman(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_aerBscStd_raman_1064, single(fillmissing(data.aerBscStd1064_raman(iGrp, :), missing_value)));

netcdf.putVar(ncID, varID_aerBsc355_klett_d1, single(fillmissing(POLIPHON1.aerBsc355_klett_d1(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_err_aerBsc355_klett_d1, single(fillmissing(POLIPHON1.err_aerBsc355_klett_d1(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_aerBsc355_klett_nd1, single(fillmissing(POLIPHON1.aerBsc355_klett_nd1(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_err_aerBsc355_klett_nd1, single(fillmissing(POLIPHON1.err_aerBsc355_klett_nd1(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_aerBsc532_klett_d1, single(fillmissing(POLIPHON1.aerBsc532_klett_d1(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_err_aerBsc532_klett_d1, single(fillmissing(POLIPHON1.err_aerBsc532_klett_d1(iGrp, :), missing_value)));  
netcdf.putVar(ncID, varID_aerBsc532_klett_nd1, single(fillmissing(POLIPHON1.aerBsc532_klett_nd1(iGrp, :), missing_value)));  
netcdf.putVar(ncID, varID_err_aerBsc532_klett_nd1, single(fillmissing(POLIPHON1.err_aerBsc532_klett_nd1(iGrp, :), missing_value)));  
netcdf.putVar(ncID, varID_aerBsc1064_klett_d1, single(fillmissing(POLIPHON1.aerBsc1064_klett_d1(iGrp, :), missing_value)));  
netcdf.putVar(ncID, varID_err_aerBsc1064_klett_d1, single(fillmissing(POLIPHON1.err_aerBsc1064_klett_d1(iGrp, :), missing_value)));  
netcdf.putVar(ncID, varID_aerBsc1064_klett_nd1, single(fillmissing(POLIPHON1.aerBsc1064_klett_nd1(iGrp, :), missing_value)));  
netcdf.putVar(ncID, varID_err_aerBsc1064_klett_nd1, single(fillmissing(POLIPHON1.err_aerBsc1064_klett_nd1(iGrp, :), missing_value)));  

netcdf.putVar(ncID, varID_aerBsc355_raman_d1, single(fillmissing(POLIPHON1.aerBsc355_raman_d1(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_err_aerBsc355_raman_d1, single(fillmissing(POLIPHON1.err_aerBsc355_raman_d1(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_aerBsc355_raman_nd1, single(fillmissing(POLIPHON1.aerBsc355_raman_nd1(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_err_aerBsc355_raman_nd1, single(fillmissing(POLIPHON1.err_aerBsc355_raman_nd1(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_aerBsc532_raman_d1, single(fillmissing(POLIPHON1.aerBsc532_raman_d1(iGrp, :), missing_value)));
netcdf.putVar(ncID, varID_err_aerBsc532_raman_d1, single(fillmissing(POLIPHON1.err_aerBsc532_raman_d1(iGrp, :), missing_value)));  
netcdf.putVar(ncID, varID_aerBsc532_raman_nd1, single(fillmissing(POLIPHON1.aerBsc532_raman_nd1(iGrp, :), missing_value)));  
netcdf.putVar(ncID, varID_err_aerBsc532_raman_nd1, single(fillmissing(POLIPHON1.err_aerBsc532_raman_nd1(iGrp, :), missing_value)));  
netcdf.putVar(ncID, varID_aerBsc1064_raman_d1, single(fillmissing(POLIPHON1.aerBsc1064_raman_d1(iGrp, :), missing_value)));  
netcdf.putVar(ncID, varID_err_aerBsc1064_raman_d1, single(fillmissing(POLIPHON1.err_aerBsc1064_raman_d1(iGrp, :), missing_value)));  
netcdf.putVar(ncID, varID_aerBsc1064_raman_nd1, single(fillmissing(POLIPHON1.aerBsc1064_raman_nd1(iGrp, :), missing_value)));  
netcdf.putVar(ncID, varID_err_aerBsc1064_raman_nd1, single(fillmissing(POLIPHON1.err_aerBsc1064_raman_nd1(iGrp, :), missing_value)));  
   
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

% aerBsc_klett_355
netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'long_name', 'aerosol backscatter coefficient at 355 nm retrieved with Klett method');
netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'standard_name', 'beta (aer, 355 nm)');
netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'retrieving_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', PollyConfig.LR355, PollyConfig.refBeta355 * 1e6, PollyConfig.heightFullOverlap(flagCh355FR), PollyConfig.maxDecomHeight355, PollyConfig.smoothWin_klett_355 * data.hRes));
netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'comment', sprintf('The result is retrieved with Klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));

% aerBscStd_klett_355
netcdf.putAtt(ncID, varID_aerBscStd_klett_355, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBscStd_klett_355, 'long_name', 'uncertainty of aerosol backscatter coefficient at 355 nm');
netcdf.putAtt(ncID, varID_aerBscStd_klett_355, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_aerBscStd_klett_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBscStd_klett_355, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID, varID_aerBscStd_klett_355, 'retrieving_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', PollyConfig.LR355, PollyConfig.refBeta355 * 1e6, PollyConfig.heightFullOverlap(flagCh355FR), PollyConfig.maxDecomHeight355, PollyConfig.smoothWin_klett_355 * data.hRes));
netcdf.putAtt(ncID, varID_aerBscStd_klett_355, 'comment', sprintf('The result is retrieved with Klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));

% aerBsc_klett_532
netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with Klett method');
netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'standard_name', 'beta (aer, 532 nm)');
netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'retrieving_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', PollyConfig.LR532, PollyConfig.refBeta532 * 1e6, PollyConfig.heightFullOverlap(flagCh532FR), PollyConfig.maxDecomHeight532, PollyConfig.smoothWin_klett_532 * data.hRes));
netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'comment', sprintf('The result is retrieved with Klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));

% aerBscStd_klett_532
netcdf.putAtt(ncID, varID_aerBscStd_klett_532, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBscStd_klett_532, 'long_name', 'uncertainty of aerosol backscatter coefficient at 532 nm');
netcdf.putAtt(ncID, varID_aerBscStd_klett_532, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_aerBscStd_klett_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBscStd_klett_532, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID, varID_aerBscStd_klett_532, 'retrieving_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', PollyConfig.LR532, PollyConfig.refBeta532 * 1e6, PollyConfig.heightFullOverlap(flagCh532FR), PollyConfig.maxDecomHeight532, PollyConfig.smoothWin_klett_532 * data.hRes));
netcdf.putAtt(ncID, varID_aerBscStd_klett_532, 'comment', sprintf('The result is retrieved with Klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));

% aerBsc_klett_1064
netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'long_name', 'aerosol backscatter coefficient at 1064 nm retrieved with Klett method');
netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'standard_name', 'beta (aer, 1064 nm)');
netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'retrieving_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', PollyConfig.LR1064, PollyConfig.refBeta1064 * 1e6, PollyConfig.heightFullOverlap(flagCh1064FR), PollyConfig.maxDecomHeight1064, PollyConfig.smoothWin_klett_1064 * data.hRes));
netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'comment', sprintf('The result is retrieved with Klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));

% aerBscStd_klett_1064
netcdf.putAtt(ncID, varID_aerBscStd_klett_1064, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBscStd_klett_1064, 'long_name', 'uncertainty of aerosol backscatter coefficient at 1064 nm');
netcdf.putAtt(ncID, varID_aerBscStd_klett_1064, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_aerBscStd_klett_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBscStd_klett_1064, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID, varID_aerBscStd_klett_1064, 'retrieving_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', PollyConfig.LR1064, PollyConfig.refBeta1064 * 1e6, PollyConfig.heightFullOverlap(flagCh1064FR), PollyConfig.maxDecomHeight1064, PollyConfig.smoothWin_klett_1064 * data.hRes));
netcdf.putAtt(ncID, varID_aerBscStd_klett_1064, 'comment', sprintf('The result is retrieved with Klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));

% aerBsc_raman_355
netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'long_name', 'aerosol backscatter coefficient at 355 nm retrieved with Raman method');
netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'standard_name', 'beta (aer, 355 nm)');
netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta355 * 1e6, PollyConfig.heightFullOverlap(flagCh355FR), PollyConfig.maxDecomHeight355, PollyConfig.smoothWin_raman_355 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% aerBscStd_raman_355
netcdf.putAtt(ncID, varID_aerBscStd_raman_355, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBscStd_raman_355, 'long_name', 'uncertainty of aerosol backscatter coefficient at 355 nm');
netcdf.putAtt(ncID, varID_aerBscStd_raman_355, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_aerBscStd_raman_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBscStd_raman_355, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID, varID_aerBscStd_raman_355, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta355 * 1e6, PollyConfig.heightFullOverlap(flagCh355FR), PollyConfig.maxDecomHeight355, PollyConfig.smoothWin_raman_355 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID, varID_aerBscStd_raman_355, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% aerBsc_raman_532
netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with Raman method');
netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'standard_name', 'beta (aer, 532 nm)');
netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta532 * 1e6, PollyConfig.heightFullOverlap(flagCh532FR), PollyConfig.maxDecomHeight532, PollyConfig.smoothWin_raman_532 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% aerBscStd_raman_532
netcdf.putAtt(ncID, varID_aerBscStd_raman_532, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBscStd_raman_532, 'long_name', 'uncertainty of aerosol backscatter coefficient at 532 nm');
netcdf.putAtt(ncID, varID_aerBscStd_raman_532, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_aerBscStd_raman_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBscStd_raman_532, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID, varID_aerBscStd_raman_532, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta532 * 1e6, PollyConfig.heightFullOverlap(flagCh532FR), PollyConfig.maxDecomHeight532, PollyConfig.smoothWin_raman_532 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID, varID_aerBscStd_raman_532, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% aerBsc_raman_1064
netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'long_name', 'aerosol backscatter coefficient at 1064 nm retrieved with Raman method');
netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'standard_name', 'beta (aer, 1064 nm)');
netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta1064 * 1e6, PollyConfig.heightFullOverlap(flagCh1064FR), PollyConfig.maxDecomHeight1064, PollyConfig.smoothWin_raman_1064 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% aerBscStd_raman_1064
netcdf.putAtt(ncID, varID_aerBscStd_raman_1064, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBscStd_raman_1064, 'long_name', 'uncertainty of aerosol backscatter coefficient at 1064 nm');
netcdf.putAtt(ncID, varID_aerBscStd_raman_1064, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_aerBscStd_raman_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBscStd_raman_1064, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID, varID_aerBscStd_raman_1064, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta1064 * 1e6, PollyConfig.heightFullOverlap(flagCh1064FR), PollyConfig.maxDecomHeight1064, PollyConfig.smoothWin_raman_1064 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID, varID_aerBscStd_raman_1064, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% varID_aerBsc355_klett_d1 
netcdf.putAtt(ncID, varID_aerBsc355_klett_d1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc355_klett_d1, 'long_name', 'one-step dust particle backscatter coefficient at 355 nm retrieved with Klett method');
netcdf.putAtt(ncID, varID_aerBsc355_klett_d1, 'standard_name', 'beta dust (aer, 355 nm)');
netcdf.putAtt(ncID, varID_aerBsc355_klett_d1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc355_klett_d1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_aerBsc355_klett_d1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc355_klett_d1 
netcdf.putAtt(ncID, varID_err_aerBsc355_klett_d1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_err_aerBsc355_klett_d1, 'long_name', 'uncertainty of one-step dust particle backscatter coefficient at 355 nm retrieved with Klett method');
netcdf.putAtt(ncID, varID_err_aerBsc355_klett_d1, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_err_aerBsc355_klett_d1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_err_aerBsc355_klett_d1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_err_aerBsc355_klett_d1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc355_klett_nd1 
netcdf.putAtt(ncID, varID_aerBsc355_klett_nd1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc355_klett_nd1, 'long_name', 'one-step non-dust particle backscatter coefficient at 355 nm retrieved with Klett method');
netcdf.putAtt(ncID, varID_aerBsc355_klett_nd1, 'standard_name', 'beta non-dust (aer, 355 nm)');
netcdf.putAtt(ncID, varID_aerBsc355_klett_nd1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc355_klett_nd1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_aerBsc355_klett_nd1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc355_klett_nd1 
netcdf.putAtt(ncID, varID_err_aerBsc355_klett_nd1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_err_aerBsc355_klett_nd1, 'long_name', 'uncertainty of one-step non-dust particle backscatter coefficient at 355 nm retrieved with Klett method');
netcdf.putAtt(ncID, varID_err_aerBsc355_klett_nd1, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_err_aerBsc355_klett_nd1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_err_aerBsc355_klett_nd1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_err_aerBsc355_klett_nd1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc532_klett_d1 
netcdf.putAtt(ncID, varID_aerBsc532_klett_d1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc532_klett_d1, 'long_name', 'one-step dust particle backscatter coefficient at 532 nm retrieved with Klett method');
netcdf.putAtt(ncID, varID_aerBsc532_klett_d1, 'standard_name', 'beta dust (aer, 532 nm)');
netcdf.putAtt(ncID, varID_aerBsc532_klett_d1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc532_klett_d1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_aerBsc532_klett_d1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc532_klett_d1 
netcdf.putAtt(ncID, varID_err_aerBsc532_klett_d1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_err_aerBsc532_klett_d1, 'long_name', 'uncertainty of one-step dust particle backscatter coefficient at 532 nm retrieved with Klett method');
netcdf.putAtt(ncID, varID_err_aerBsc532_klett_d1, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_err_aerBsc532_klett_d1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_err_aerBsc532_klett_d1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_err_aerBsc532_klett_d1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc532_klett_nd1 
netcdf.putAtt(ncID, varID_aerBsc532_klett_nd1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc532_klett_nd1, 'long_name', 'one-step non-dust particle backscatter coefficient at 532 nm retrieved with Klett method');
netcdf.putAtt(ncID, varID_aerBsc532_klett_nd1, 'standard_name', 'beta non-dust (aer, 532 nm)');
netcdf.putAtt(ncID, varID_aerBsc532_klett_nd1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc532_klett_nd1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_aerBsc532_klett_nd1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc532_klett_nd1 
netcdf.putAtt(ncID, varID_err_aerBsc532_klett_nd1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_err_aerBsc532_klett_nd1, 'long_name', 'uncertainty of one-step non-dust particle backscatter coefficient at 532 nm retrieved with Klett method');
netcdf.putAtt(ncID, varID_err_aerBsc532_klett_nd1, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_err_aerBsc532_klett_nd1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_err_aerBsc532_klett_nd1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_err_aerBsc532_klett_nd1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc1064_klett_d1 
netcdf.putAtt(ncID, varID_aerBsc1064_klett_d1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc1064_klett_d1, 'long_name', 'one-step dust particle backscatter coefficient at 1064 nm retrieved with Klett method');
netcdf.putAtt(ncID, varID_aerBsc1064_klett_d1, 'standard_name', 'beta dust (aer, 1064 nm)');
netcdf.putAtt(ncID, varID_aerBsc1064_klett_d1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc1064_klett_d1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_aerBsc1064_klett_d1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc1064_klett_d1 
netcdf.putAtt(ncID, varID_err_aerBsc1064_klett_d1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_err_aerBsc1064_klett_d1, 'long_name', 'uncertainty of one-step dust particle backscatter coefficient at 1064 nm retrieved with Klett method');
netcdf.putAtt(ncID, varID_err_aerBsc1064_klett_d1, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_err_aerBsc1064_klett_d1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_err_aerBsc1064_klett_d1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_err_aerBsc1064_klett_d1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc1064_klett_nd1 
netcdf.putAtt(ncID, varID_aerBsc1064_klett_nd1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc1064_klett_nd1, 'long_name', 'one-step non-dust particle backscatter coefficient at 1064 nm retrieved with Klett method');
netcdf.putAtt(ncID, varID_aerBsc1064_klett_nd1, 'standard_name', 'beta non-dust (aer, 1064 nm)');
netcdf.putAtt(ncID, varID_aerBsc1064_klett_nd1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc1064_klett_nd1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_aerBsc1064_klett_nd1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc1064_klett_nd1 
netcdf.putAtt(ncID, varID_err_aerBsc1064_klett_nd1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_err_aerBsc1064_klett_nd1, 'long_name', 'uncertainty of one-step non-dust particle backscatter coefficient at 1064 nm retrieved with Klett method');
netcdf.putAtt(ncID, varID_err_aerBsc1064_klett_nd1, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_err_aerBsc1064_klett_nd1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_err_aerBsc1064_klett_nd1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_err_aerBsc1064_klett_nd1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc355_raman_d1 
netcdf.putAtt(ncID, varID_aerBsc355_raman_d1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc355_raman_d1, 'long_name', 'one-step dust particle backscatter coefficient at 355 nm retrieved with Raman method');
netcdf.putAtt(ncID, varID_aerBsc355_raman_d1, 'standard_name', 'beta dust (aer, 355 nm)');
netcdf.putAtt(ncID, varID_aerBsc355_raman_d1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc355_raman_d1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_aerBsc355_raman_d1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc355_raman_d1 
netcdf.putAtt(ncID, varID_err_aerBsc355_raman_d1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_err_aerBsc355_raman_d1, 'long_name', 'uncertainty of one-step dust particle backscatter coefficient at 355 nm retrieved with Raman method');
netcdf.putAtt(ncID, varID_err_aerBsc355_raman_d1, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_err_aerBsc355_raman_d1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_err_aerBsc355_raman_d1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_err_aerBsc355_raman_d1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc355_raman_nd1 
netcdf.putAtt(ncID, varID_aerBsc355_raman_nd1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc355_raman_nd1, 'long_name', 'one-step non-dust particle backscatter coefficient at 355 nm retrieved with Raman method');
netcdf.putAtt(ncID, varID_aerBsc355_raman_nd1, 'standard_name', 'beta dust (aer, 355 nm)');
netcdf.putAtt(ncID, varID_aerBsc355_raman_nd1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc355_raman_nd1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_aerBsc355_raman_nd1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc355_raman_nd1 
netcdf.putAtt(ncID, varID_err_aerBsc355_raman_nd1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_err_aerBsc355_raman_nd1, 'long_name', 'uncertainty of one-step non-dust particle backscatter coefficient at 355 nm retrieved with Raman method');
netcdf.putAtt(ncID, varID_err_aerBsc355_raman_nd1, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_err_aerBsc355_raman_nd1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_err_aerBsc355_raman_nd1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_err_aerBsc355_raman_nd1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc532_raman_d1 
netcdf.putAtt(ncID, varID_aerBsc532_raman_d1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc532_raman_d1, 'long_name', 'one-step dust particle backscatter coefficient at 532 nm retrieved with Raman method');
netcdf.putAtt(ncID, varID_aerBsc532_raman_d1, 'standard_name', 'beta dust (aer, 532 nm)');
netcdf.putAtt(ncID, varID_aerBsc532_raman_d1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc532_raman_d1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_aerBsc532_raman_d1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc532_raman_d1 
netcdf.putAtt(ncID, varID_err_aerBsc532_raman_d1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_err_aerBsc532_raman_d1, 'long_name', 'uncertainty of one-step dust particle backscatter coefficient at 532 nm retrieved with Raman method');
netcdf.putAtt(ncID, varID_err_aerBsc532_raman_d1, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_err_aerBsc532_raman_d1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_err_aerBsc532_raman_d1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_err_aerBsc532_raman_d1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc532_raman_nd1 
netcdf.putAtt(ncID, varID_aerBsc532_raman_nd1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc532_raman_nd1, 'long_name', 'one-step non-dust particle backscatter coefficient at 532 nm retrieved with Raman method');
netcdf.putAtt(ncID, varID_aerBsc532_raman_nd1, 'standard_name', 'beta dust (aer, 532 nm)');
netcdf.putAtt(ncID, varID_aerBsc532_raman_nd1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc532_raman_nd1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_aerBsc532_raman_nd1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc532_raman_nd1 
netcdf.putAtt(ncID, varID_err_aerBsc532_raman_nd1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_err_aerBsc532_raman_nd1, 'long_name', 'uncertainty of one-step non-dust particle backscatter coefficient at 532 nm retrieved with Raman method');
netcdf.putAtt(ncID, varID_err_aerBsc532_raman_nd1, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_err_aerBsc532_raman_nd1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_err_aerBsc532_raman_nd1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_err_aerBsc532_raman_nd1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc1064_raman_d1 
netcdf.putAtt(ncID, varID_aerBsc1064_raman_d1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc1064_raman_d1, 'long_name', 'one-step dust particle backscatter coefficient at 1064 nm retrieved with Raman method');
netcdf.putAtt(ncID, varID_aerBsc1064_raman_d1, 'standard_name', 'beta dust (aer, 1064 nm)');
netcdf.putAtt(ncID, varID_aerBsc1064_raman_d1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc1064_raman_d1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_aerBsc1064_raman_d1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc1064_raman_d1 
netcdf.putAtt(ncID, varID_err_aerBsc1064_raman_d1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_err_aerBsc1064_raman_d1, 'long_name', 'uncertainty of one-step dust particle backscatter coefficient at 1064 nm retrieved with Raman method');
netcdf.putAtt(ncID, varID_err_aerBsc1064_raman_d1, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_err_aerBsc1064_raman_d1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_err_aerBsc1064_raman_d1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_err_aerBsc1064_raman_d1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc1064_raman_nd1 
netcdf.putAtt(ncID, varID_aerBsc1064_raman_nd1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_aerBsc1064_raman_nd1, 'long_name', 'one-step non-dust particle backscatter coefficient at 1064 nm retrieved with Raman method');
netcdf.putAtt(ncID, varID_aerBsc1064_raman_nd1, 'standard_name', 'beta dust (aer, 1064 nm)');
netcdf.putAtt(ncID, varID_aerBsc1064_raman_nd1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_aerBsc1064_raman_nd1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_aerBsc1064_raman_nd1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc1064_raman_nd1 
netcdf.putAtt(ncID, varID_err_aerBsc1064_raman_nd1, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_err_aerBsc1064_raman_nd1, 'long_name', 'uncertainty of one-step non-dust particle backscatter coefficient at 1064 nm retrieved with Raman method');
netcdf.putAtt(ncID, varID_err_aerBsc1064_raman_nd1, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID, varID_err_aerBsc1064_raman_nd1, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_err_aerBsc1064_raman_nd1, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_err_aerBsc1064_raman_nd1, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

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
cwd = pwd;
cd(PicassoConfig.PicassoRootDir);
gitInfo = getGitInfo();
cd(cwd);
netcdf.putAtt(ncID, varID_global, 'history', sprintf('Last processing time at %s by %s, git branch: %s, git commit: %s', tNow, mfilename, gitInfo.branch, gitInfo.hash));

% close file
netcdf.close(ncID);
end
end
function [] = pollyxt_first_save_retrieving_results(data, taskInfo, config)
%polly_1v2_save_retrieving_results saving the retrieved results, including backscatter, extinction coefficients, lidar ratio, volume/particles depolarization ratio and so on.
%   Example:
%       [] = polly_1v2_save_retrieving_results(data, taskInfo, config)
%   Inputs:
%       data.struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       taskInfo: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       
%   History:
%       2018-12-31. First Edition by Zhenping
%       2019-05-10. Add one field of start&end time to be compatible with larda ncReader.
%       2019-05-16. Extended the attributes for all the variables and comply with the ACTRIS
%       2019-05-24. Add voldepol with different smoothing window  convention.
%       2019-09-27. Turn on the netCDF4 compression.
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

missing_value = -999;

for iGroup = 1:size(data.cloudFreeGroups, 1)
    ncFile = fullfile(processInfo.results_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_profiles.nc', rmext(taskInfo.dataFilename), datestr(data.mTime(data.cloudFreeGroups(iGroup, 1)), 'HHMM'), datestr(data.mTime(data.cloudFreeGroups(iGroup, 2)), 'HHMM')));
    startTime = data.mTime(data.cloudFreeGroups(iGroup, 1));
    endTime = data.mTime(data.cloudFreeGroups(iGroup, 2));

    % filling missing values for reference height
    if isnan(data.refHIndx532(iGroup, 1))
        refH532 = [missing_value, missing_value];
    else
        refH532 = data.height(data.refHIndx532(iGroup, :));
    end

    % create .nc file by overwriting any existing file with the name filename
    mode = netcdf.getConstant('NETCDF4');
    mode = bitor(mode, netcdf.getConstant('CLASSIC_MODEL'));
    mode = bitor(mode, netcdf.getConstant('CLOBBER'));
    ncID = netcdf.create(ncFile, mode);

    % define dimensions
    dimID_height = netcdf.defDim(ncID, 'altitude', length(data.height));
    dimID_method = netcdf.defDim(ncID, 'method', 1);
    dimID_refHeight = netcdf.defDim(ncID, 'reference_height', 2);

    % define variables
    varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_DOUBLE', dimID_method);
    varID_longitude = netcdf.defVar(ncID, 'longitude', 'NC_DOUBLE', dimID_method);
    varID_latitude = netcdf.defVar(ncID, 'latitude', 'NC_DOUBLE', dimID_method);
    varID_startTime = netcdf.defVar(ncID, 'start_time', 'NC_DOUBLE', dimID_method);
    varID_endTime = netcdf.defVar(ncID, 'end_time', 'NC_DOUBLE', dimID_method);
    varID_height = netcdf.defVar(ncID, 'height', 'NC_DOUBLE', dimID_height);
    varID_aerBsc_klett_532 = netcdf.defVar(ncID, 'aerBsc_klett_532', 'NC_DOUBLE', dimID_height);
    varID_aerBsc_raman_532 = netcdf.defVar(ncID, 'aerBsc_raman_532', 'NC_DOUBLE', dimID_height);
    varID_aerExt_raman_532 = netcdf.defVar(ncID, 'aerExt_raman_532', 'NC_DOUBLE', dimID_height);
    varID_aerLR_raman_532 = netcdf.defVar(ncID, 'aerLR_raman_532', 'NC_DOUBLE', dimID_height);
    varID_aerBsc_RR_532 = netcdf.defVar(ncID, 'aerBsc_RR_532', 'NC_DOUBLE', dimID_height);
    varID_aerExt_RR_532 = netcdf.defVar(ncID, 'aerExt_RR_532', 'NC_DOUBLE', dimID_height);
    varID_aerLR_RR_532 = netcdf.defVar(ncID, 'aerLR_RR_532', 'NC_DOUBLE', dimID_height);
    varID_volDepol_klett_532 = netcdf.defVar(ncID, 'volDepol_klett_532', 'NC_DOUBLE', dimID_height);
    varID_volDepol_raman_532 = netcdf.defVar(ncID, 'volDepol_raman_532', 'NC_DOUBLE', dimID_height);
    varID_parDepol_klett_532 = netcdf.defVar(ncID, 'parDepol_klett_532', 'NC_DOUBLE', dimID_height);
    varID_parDepol_raman_532 = netcdf.defVar(ncID, 'parDepol_raman_532', 'NC_DOUBLE', dimID_height);
    varID_temperature = netcdf.defVar(ncID, 'temperature', 'NC_DOUBLE', dimID_height);
    varID_pressure = netcdf.defVar(ncID, 'pressure', 'NC_DOUBLE', dimID_height);
    varID_reference_height_532 = netcdf.defVar(ncID, 'reference_height_532', 'NC_DOUBLE', dimID_refHeight);

    % define the filling value
    netcdf.defVarFill(ncID, varID_aerBsc_klett_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerExt_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerLR_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_RR_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerExt_RR_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerLR_RR_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_volDepol_klett_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_volDepol_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_parDepol_klett_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_parDepol_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_temperature, false, missing_value);
    netcdf.defVarFill(ncID, varID_pressure, false, missing_value);
    netcdf.defVarFill(ncID, varID_reference_height_532, false, missing_value);

    % define the data compression
    netcdf.defVarDeflate(ncID, varID_aerBsc_klett_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerExt_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerLR_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_RR_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerExt_RR_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerLR_RR_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_volDepol_klett_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_volDepol_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_parDepol_klett_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_parDepol_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_temperature, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pressure, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_reference_height_532, true, true, 5);

    % leve define mode
    netcdf.endDef(ncID);

    % write data to .nc file
    netcdf.putVar(ncID, varID_altitude, data.alt0);
    netcdf.putVar(ncID, varID_longitude, data.lon);
    netcdf.putVar(ncID, varID_latitude, data.lat);
    netcdf.putVar(ncID, varID_startTime, datenum_2_unix_timestamp(startTime));
    netcdf.putVar(ncID, varID_endTime, datenum_2_unix_timestamp(endTime));
    netcdf.putVar(ncID, varID_height, data.height);
    netcdf.putVar(ncID, varID_aerBsc_klett_532, fillmissing(data.aerBsc532_klett(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_aerBsc_raman_532, fillmissing(data.aerBsc532_raman(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_aerExt_raman_532, fillmissing(data.aerExt532_raman(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_aerLR_raman_532, fillmissing(data.LR532_raman(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_temperature, fillmissing(data.temperature(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_pressure, fillmissing(data.pressure(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_reference_height_532, refH532);

    % reenter define mode
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

    % aerBsc_klett_532
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with Klett method');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'standard_name', 'beta (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'plot_range', config.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'retrieved_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', config.LR532, config.refBeta532 * 1e6, config.smoothWin_klett_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'comment', sprintf('The result is retrieved with klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));

    % aerBsc_raman_532
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'standard_name', 'beta (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'plot_range', config.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'retrieved_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.refBeta532 * 1e6, config.smoothWin_raman_532 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));
    
    % aerExt_raman_532
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'unit', 'm^-1');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'unit_html', 'm<sup>-1</sup>');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'long_name', 'aerosol extinction coefficient at 532 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'standard_name', 'alpha (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'plot_range', config.xLim_Profi_Ext/1e6);
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'retrieved_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.smoothWin_raman_532 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));
    
    % aerLR_raman_532
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'long_name', 'aerosol lidar ratio at 532 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'standard_name', 'S (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'plot_range', config.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'retrieved_info', sprintf('Smoothing window: %d [m]', config.smoothWin_raman_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));
    
    % temperature
    netcdf.putAtt(ncID, varID_temperature, 'unit', 'degree_Celsius');
    netcdf.putAtt(ncID, varID_temperature, 'unit_html', '&#176C');
    netcdf.putAtt(ncID, varID_temperature, 'long_name', 'Temperature');
    netcdf.putAtt(ncID, varID_temperature, 'standard_name', 'air_temperature');
    netcdf.putAtt(ncID, varID_temperature, 'plot_range', [-60, 40]);
    netcdf.putAtt(ncID, varID_temperature, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_temperature, 'retrieved_info', sprintf('Meteorological Source: %s', data.meteorAttri.dataSource{iGroup}));
    
    % pressure
    netcdf.putAtt(ncID, varID_pressure, 'unit', 'hPa');
    netcdf.putAtt(ncID, varID_pressure, 'long_name', 'Pressure');
    netcdf.putAtt(ncID, varID_pressure, 'standard_name', 'air_pressure');
    netcdf.putAtt(ncID, varID_pressure, 'plot_range', [0, 1000]);
    netcdf.putAtt(ncID, varID_pressure, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pressure, 'retrieved_info', sprintf('Meteorological Source: %s', data.meteorAttri.dataSource{iGroup}));
    
    % reference_height_532
    netcdf.putAtt(ncID, varID_reference_height_532, 'unit', 'm');
    netcdf.putAtt(ncID, varID_reference_height_532, 'long_name', 'Reference height for 532 nm');
    netcdf.putAtt(ncID, varID_reference_height_532, 'standard_name', 'ref_h_532');
    netcdf.putAtt(ncID, varID_reference_height_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_reference_height_532, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_reference_height_532, 'comment', sprintf('The reference height is searched by Rayleigh Fitting algorithm. It is through comparing the correlation of the slope between molecule backscatter and range-corrected signal and find the segement with best agreement.'));
    
    varID_global = netcdf.getConstant('GLOBAL');
    netcdf.putAtt(ncID, varID_global, 'latitude', data.lat);
    netcdf.putAtt(ncID, varID_global, 'longtitude', data.lon);
    netcdf.putAtt(ncID, varID_global, 'elev', data.alt0);
    netcdf.putAtt(ncID, varID_global, 'location', campaignInfo.location);
    netcdf.putAtt(ncID, varID_global, 'institute', processInfo.institute);
    netcdf.putAtt(ncID, varID_global, 'version', processInfo.programVersion);
    netcdf.putAtt(ncID, varID_global, 'contact', sprintf('%s', processInfo.contact));
    cwd = pwd;
    cd(processInfo.projectDir);
    gitInfo = getGitInfo();
    cd(cwd);
    netcdf.putAtt(ncID, varID_global, 'history', sprintf('Last processing time at %s by %s, git branch: %s, git commit: %s', tNow, mfilename, gitInfo.branch, gitInfo.hash));
    
    % close file
    netcdf.close(ncID);
    
end
function pollySavePOLIPHON2(data, POLIPHON2)
%POLLYSAVEPOLIPHON save POLIPHON_two results 
%
% INPUTS:
%    data: struct
%    POLIPHON2 : struct
%
% HISTORY:
%    - 2025-..-..: first edition by 
%
% Authors: - jneumann@tropos.de
%          - floutsi@tropos.de

global PicassoConfig CampaignConfig PollyDataInfo PollyConfig
missing_value = -999;

for iGrp = 1:size(data.clFreGrps, 1)
ncFile_raman = fullfile(PicassoConfig.results_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_POLIPHON_2_raman.nc', rmext(PollyDataInfo.pollyDataFile), datestr(data.mTime(data.clFreGrps(iGrp, 1)), 'HHMM'), datestr(data.mTime(data.clFreGrps(iGrp, 2)), 'HHMM')));
ncFile_klett = fullfile(PicassoConfig.results_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_POLIPHON_2_klett.nc', rmext(PollyDataInfo.pollyDataFile), datestr(data.mTime(data.clFreGrps(iGrp, 1)), 'HHMM'), datestr(data.mTime(data.clFreGrps(iGrp, 2)), 'HHMM')));
startTime = data.mTime(data.clFreGrps(iGrp, 1));
endTime = data.mTime(data.clFreGrps(iGrp, 2));

mode = netcdf.getConstant('NETCDF4');
%mode = bitor(mode, netcdf.getConstant('CLASSIC_MODEL'));
mode = bitor(mode, netcdf.getConstant('CLOBBER'));
ncID_raman = netcdf.create(ncFile_raman, mode);
ncID_klett = netcdf.create(ncFile_klett, mode);

% define dimensions
dimID_height_raman = netcdf.defDim(ncID_raman, 'height', length(data.height));
dimID_method_raman = netcdf.defDim(ncID_raman, 'method', 1);
dimID_time_raman = netcdf.defDim(ncID_raman, 'time', length(data.mTime));

dimID_height_klett = netcdf.defDim(ncID_klett, 'height', length(data.height));
dimID_method_klett = netcdf.defDim(ncID_klett, 'method', 1);
dimID_time_klett = netcdf.defDim(ncID_klett, 'time', length(data.mTime));


% define variables
% raman
varID_altitude_raman  = netcdf.defVar(ncID_raman, 'altitude', 'NC_FLOAT', dimID_method_raman);
varID_longitude_raman = netcdf.defVar(ncID_raman, 'longitude', 'NC_FLOAT', dimID_method_raman);
varID_latitude_raman  = netcdf.defVar(ncID_raman, 'latitude', 'NC_FLOAT', dimID_method_raman);
varID_startTime_raman = netcdf.defVar(ncID_raman, 'start_time', 'NC_DOUBLE', dimID_method_raman);
varID_endTime_raman   = netcdf.defVar(ncID_raman, 'end_time', 'NC_DOUBLE', dimID_method_raman);
varID_height_raman    = netcdf.defVar(ncID_raman, 'height', 'NC_FLOAT', dimID_height_raman);
varID_time_raman      = netcdf.defVar(ncID_raman, 'time', 'NC_DOUBLE', dimID_time_raman);

varID_beta_dc_raman      = netcdf.defVar(ncID_raman, 'beta_dc_raman', 'NC_FLOAT', dimID_height_raman);
% klett
varID_altitude_klett  = netcdf.defVar(ncID_klett, 'altitude', 'NC_FLOAT', dimID_method_klett);
varID_longitude_klett = netcdf.defVar(ncID_klett, 'longitude', 'NC_FLOAT', dimID_method_klett);
varID_latitude_klett  = netcdf.defVar(ncID_klett, 'latitude', 'NC_FLOAT', dimID_method_klett);
varID_startTime_klett = netcdf.defVar(ncID_klett, 'start_time', 'NC_DOUBLE', dimID_method_klett);
varID_endTime_klett   = netcdf.defVar(ncID_klett, 'end_time', 'NC_DOUBLE', dimID_method_klett);
varID_height_klett    = netcdf.defVar(ncID_klett, 'height', 'NC_FLOAT', dimID_height_klett);
varID_time_klett      = netcdf.defVar(ncID_klett, 'time', 'NC_DOUBLE', dimID_time_klett);

varID_beta_dc_klett      = netcdf.defVar(ncID_klett, 'beta_dc_klett', 'NC_FLOAT', dimID_height_klett);


%% total
varID_aerBsc_klett_355     = netcdf.defVar(ncID_klett, 'aerBsc_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_aerBscStd_klett_355  = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_aerBsc_klett_532     = netcdf.defVar(ncID_klett, 'aerBsc_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_aerBscStd_klett_532  = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_aerBsc_klett_1064    = netcdf.defVar(ncID_klett, 'aerBsc_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_aerBscStd_klett_1064 = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc_klett_1064', 'NC_FLOAT', dimID_height_klett);

varID_aerBsc_raman_355     = netcdf.defVar(ncID_raman, 'aerBsc_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_aerBscStd_raman_355  = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_aerBsc_raman_532     = netcdf.defVar(ncID_raman, 'aerBsc_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_aerBscStd_raman_532  = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_aerBsc_raman_1064    = netcdf.defVar(ncID_raman, 'aerBsc_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_aerBscStd_raman_1064 = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc_raman_1064', 'NC_FLOAT', dimID_height_raman);


%% raman 
varID_aerBsc355_raman_d2        = netcdf.defVar(ncID_raman, 'aerBsc355_raman_d2', 'NC_FLOAT', dimID_height_raman);
varID_err_aerBsc355_raman_d2    = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc355_raman_d2', 'NC_FLOAT', dimID_height_raman);
varID_aerBsc355_raman_dc2       = netcdf.defVar(ncID_raman, 'aerBsc355_raman_dc2', 'NC_FLOAT', dimID_height_raman);
varID_err_aerBsc355_raman_dc2   = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc355_raman_dc2', 'NC_FLOAT', dimID_height_raman);
varID_aerBsc355_raman_df2       = netcdf.defVar(ncID_raman, 'aerBsc355_raman_df2', 'NC_FLOAT', dimID_height_raman);
varID_err_aerBsc355_raman_df2   = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc355_raman_df2', 'NC_FLOAT', dimID_height_raman);
varID_aerBsc355_raman_nddf2     = netcdf.defVar(ncID_raman, 'aerBsc355_raman_nddf2', 'NC_FLOAT', dimID_height_raman);
varID_err_aerBsc355_raman_nddf2 = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc355_raman_nddf2', 'NC_FLOAT', dimID_height_raman);
varID_aerBsc355_raman_nd2       = netcdf.defVar(ncID_raman, 'aerBsc355_raman_nd2', 'NC_FLOAT', dimID_height_raman);
varID_err_aerBsc355_raman_nd2   = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc355_raman_nd2', 'NC_FLOAT', dimID_height_raman);

varID_aerBsc532_raman_d2       = netcdf.defVar(ncID_raman, 'aerBsc532_raman_d2', 'NC_FLOAT', dimID_height_raman);
varID_err_aerBsc532_raman_d2   = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc532_raman_d2', 'NC_FLOAT', dimID_height_raman);
varID_aerBsc532_raman_dc2         = netcdf.defVar(ncID_raman, 'aerBsc532_raman_dc2', 'NC_FLOAT', dimID_height_raman);
varID_err_aerBsc532_raman_dc2     = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc532_raman_dc2', 'NC_FLOAT', dimID_height_raman);
varID_aerBsc532_raman_df2         = netcdf.defVar(ncID_raman, 'aerBsc532_raman_df2', 'NC_FLOAT', dimID_height_raman);
varID_err_aerBsc532_raman_df2     = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc532_raman_df2', 'NC_FLOAT', dimID_height_raman);
varID_aerBsc532_raman_nddf2       = netcdf.defVar(ncID_raman, 'aerBsc532_raman_nddf2', 'NC_FLOAT', dimID_height_raman);
varID_err_aerBsc532_raman_nddf2   = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc532_raman_nddf2', 'NC_FLOAT', dimID_height_raman);
varID_aerBsc532_raman_nd2      = netcdf.defVar(ncID_raman, 'aerBsc532_raman_nd2', 'NC_FLOAT', dimID_height_raman);
varID_err_aerBsc532_raman_nd2  = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc532_raman_nd2', 'NC_FLOAT', dimID_height_raman);

varID_aerBsc1064_raman_d2       = netcdf.defVar(ncID_raman, 'aerBsc1064_raman_d2', 'NC_FLOAT', dimID_height_raman);
varID_err_aerBsc1064_raman_d2   = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc1064_raman_d2', 'NC_FLOAT', dimID_height_raman);
varID_aerBsc1064_raman_dc2         = netcdf.defVar(ncID_raman, 'aerBsc1064_raman_dc2', 'NC_FLOAT', dimID_height_raman);
varID_err_aerBsc1064_raman_dc2     = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc1064_raman_dc2', 'NC_FLOAT', dimID_height_raman);
varID_aerBsc1064_raman_df2         = netcdf.defVar(ncID_raman, 'aerBsc1064_raman_df2', 'NC_FLOAT', dimID_height_raman);
varID_err_aerBsc1064_raman_df2     = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc1064_raman_df2', 'NC_FLOAT', dimID_height_raman);
varID_aerBsc1064_raman_nddf2       = netcdf.defVar(ncID_raman, 'aerBsc1064_raman_nddf2', 'NC_FLOAT', dimID_height_raman);
varID_err_aerBsc1064_raman_nddf2   = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc1064_raman_nddf2', 'NC_FLOAT', dimID_height_raman);
varID_aerBsc1064_raman_nd2      = netcdf.defVar(ncID_raman, 'aerBsc1064_raman_nd2', 'NC_FLOAT', dimID_height_raman);
varID_err_aerBsc1064_raman_nd2  = netcdf.defVar(ncID_raman, 'uncertainty_aerBsc1064_raman_nd2', 'NC_FLOAT', dimID_height_raman);

% extinction coeffs
varID_ext_d_raman_355 = netcdf.defVar(ncID_raman, 'ext_d_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_ext_d_raman_532 = netcdf.defVar(ncID_raman, 'ext_d_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_ext_d_raman_1064 = netcdf.defVar(ncID_raman, 'ext_d_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_ext_cd_raman_355 = netcdf.defVar(ncID_raman, 'ext_cd_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_ext_cd_raman_532 = netcdf.defVar(ncID_raman, 'ext_cd_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_ext_cd_raman_1064 = netcdf.defVar(ncID_raman, 'ext_cd_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_ext_fd_raman_355 = netcdf.defVar(ncID_raman, 'ext_fd_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_ext_fd_raman_532 = netcdf.defVar(ncID_raman, 'ext_fd_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_ext_fd_raman_1064 = netcdf.defVar(ncID_raman, 'ext_fd_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_ext_ndm_raman_355 = netcdf.defVar(ncID_raman, 'ext_ndm1_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_ext_ndm_raman_532 = netcdf.defVar(ncID_raman, 'ext_ndm1_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_ext_ndm_raman_1064 = netcdf.defVar(ncID_raman, 'ext_ndm1_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_ext_nds_raman_355 = netcdf.defVar(ncID_raman, 'ext_nds1_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_ext_nds_raman_532 = netcdf.defVar(ncID_raman, 'ext_nds1_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_ext_nds_raman_1064 = netcdf.defVar(ncID_raman, 'ext_nds1_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_ext_bb_raman_355 = netcdf.defVar(ncID_raman, 'ext_bb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_ext_bb_raman_532 = netcdf.defVar(ncID_raman, 'ext_bb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_ext_bb_raman_1064 = netcdf.defVar(ncID_raman, 'ext_bb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_ext_vsf_raman_355 = netcdf.defVar(ncID_raman, 'ext_vsf_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_ext_vsf_raman_532 = netcdf.defVar(ncID_raman, 'ext_vsf_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_ext_vsf_raman_1064 = netcdf.defVar(ncID_raman, 'ext_vsf_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_ext_vsa_raman_355 = netcdf.defVar(ncID_raman, 'ext_vsa_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_ext_vsa_raman_532 = netcdf.defVar(ncID_raman, 'ext_vsa_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_ext_vsa_raman_1064 = netcdf.defVar(ncID_raman, 'ext_vsa_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_ext_vst_raman_355 = netcdf.defVar(ncID_raman, 'ext_vst_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_ext_vst_raman_532 = netcdf.defVar(ncID_raman, 'ext_vst_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_ext_vst_raman_1064 = netcdf.defVar(ncID_raman, 'ext_vst_raman_1064', 'NC_FLOAT', dimID_height_raman);

% mass concentrations
varID_m_d_raman_355 = netcdf.defVar(ncID_raman, 'm_d_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_m_d_raman_532 = netcdf.defVar(ncID_raman, 'm_d_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_m_d_raman_1064 = netcdf.defVar(ncID_raman, 'm_d_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_m_cd_raman_355 = netcdf.defVar(ncID_raman, 'm_cd_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_m_cd_raman_532 = netcdf.defVar(ncID_raman, 'm_cd_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_m_cd_raman_1064 = netcdf.defVar(ncID_raman, 'm_cd_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_m_fd_raman_355 = netcdf.defVar(ncID_raman, 'm_fd_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_m_fd_raman_532 = netcdf.defVar(ncID_raman, 'm_fd_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_m_fd_raman_1064 = netcdf.defVar(ncID_raman, 'm_fd_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_m_ndm_raman_355 = netcdf.defVar(ncID_raman, 'm_ndm_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_m_ndm_raman_532 = netcdf.defVar(ncID_raman, 'm_ndm_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_m_ndm_raman_1064 = netcdf.defVar(ncID_raman, 'm_ndm_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_m_nds_raman_355 = netcdf.defVar(ncID_raman, 'm_nds_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_m_nds_raman_532 = netcdf.defVar(ncID_raman, 'm_nds_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_m_nds_raman_1064 = netcdf.defVar(ncID_raman, 'm_nds_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_m_bb_raman_355 = netcdf.defVar(ncID_raman, 'm_bb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_m_bb_raman_532 = netcdf.defVar(ncID_raman, 'm_bb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_m_bb_raman_1064 = netcdf.defVar(ncID_raman, 'm_bb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_m_vsf_raman_355 = netcdf.defVar(ncID_raman, 'm_vsf_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_m_vsf_raman_532 = netcdf.defVar(ncID_raman, 'm_vsf_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_m_vsf_raman_1064 = netcdf.defVar(ncID_raman, 'm_vsf_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_m_vsa_raman_355 = netcdf.defVar(ncID_raman, 'm_vsa_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_m_vsa_raman_532 = netcdf.defVar(ncID_raman, 'm_vsa_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_m_vsa_raman_1064 = netcdf.defVar(ncID_raman, 'm_vsa_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_m_vst_raman_355 = netcdf.defVar(ncID_raman, 'm_vst_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_m_vst_raman_532 = netcdf.defVar(ncID_raman, 'm_vst_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_m_vst_raman_1064 = netcdf.defVar(ncID_raman, 'm_vst_raman_1064', 'NC_FLOAT', dimID_height_raman);

% number concentrations
varID_n_100_d_raman_355 = netcdf.defVar(ncID_raman, 'n_100_d_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_100_d_raman_532 = netcdf.defVar(ncID_raman, 'n_100_d_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_100_d_raman_1064 = netcdf.defVar(ncID_raman, 'n_100_d_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_250_d_raman_355 = netcdf.defVar(ncID_raman, 'n_250_d_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_250_d_raman_532 = netcdf.defVar(ncID_raman, 'n_250_d_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_250_d_raman_1064 = netcdf.defVar(ncID_raman, 'n_250_d_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_50_c_raman_355 = netcdf.defVar(ncID_raman, 'n_50_c_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_50_c_raman_532 = netcdf.defVar(ncID_raman, 'n_50_c_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_50_c_raman_1064 = netcdf.defVar(ncID_raman, 'n_50_c_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_250_c_raman_355 = netcdf.defVar(ncID_raman, 'n_250_c_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_250_c_raman_532 = netcdf.defVar(ncID_raman, 'n_250_c_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_250_c_raman_1064 = netcdf.defVar(ncID_raman, 'n_250_c_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_50_m_raman_355 = netcdf.defVar(ncID_raman, 'n_50_m_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_50_m_raman_532 = netcdf.defVar(ncID_raman, 'n_50_m_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_50_m_raman_1064 = netcdf.defVar(ncID_raman, 'n_50_m_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_250_m_raman_355 = netcdf.defVar(ncID_raman, 'n_250_m_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_250_m_raman_532 = netcdf.defVar(ncID_raman, 'n_250_m_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_250_m_raman_1064 = netcdf.defVar(ncID_raman, 'n_250_m_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_50_bb_raman_355 = netcdf.defVar(ncID_raman, 'n_50_bb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_50_bb_raman_532 = netcdf.defVar(ncID_raman, 'n_50_bb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_50_bb_raman_1064 = netcdf.defVar(ncID_raman, 'n_50_bb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_250_bb_raman_355 = netcdf.defVar(ncID_raman, 'n_250_bb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_250_bb_raman_532 = netcdf.defVar(ncID_raman, 'n_250_bb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_250_bb_raman_1064 = netcdf.defVar(ncID_raman, 'n_250_bb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_50_vsf_raman_355 = netcdf.defVar(ncID_raman, 'n_50_vsf_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_50_vsf_raman_532 = netcdf.defVar(ncID_raman, 'n_50_vsf_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_50_vsf_raman_1064 = netcdf.defVar(ncID_raman, 'n_50_vsf_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_250_vsf_raman_355 = netcdf.defVar(ncID_raman, 'n_250_vsf_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_250_vsf_raman_532 = netcdf.defVar(ncID_raman, 'n_250_vsf_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_250_vsf_raman_1064 = netcdf.defVar(ncID_raman, 'n_250_vsf_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_50_vsa_raman_355 = netcdf.defVar(ncID_raman, 'n_50_vsa_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_50_vsa_raman_532 = netcdf.defVar(ncID_raman, 'n_50_vsa_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_50_vsa_raman_1064 = netcdf.defVar(ncID_raman, 'n_50_vsa_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_250_vsa_raman_355 = netcdf.defVar(ncID_raman, 'n_250_vsa_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_250_vsa_raman_532 = netcdf.defVar(ncID_raman, 'n_250_vsa_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_250_vsa_raman_1064 = netcdf.defVar(ncID_raman, 'n_250_vsa_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_50_vst_raman_355 = netcdf.defVar(ncID_raman, 'n_50_vst_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_50_vst_raman_532 = netcdf.defVar(ncID_raman, 'n_50_vst_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_50_vst_raman_1064 = netcdf.defVar(ncID_raman, 'n_50_vst_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_250_vst_raman_355 = netcdf.defVar(ncID_raman, 'n_250_vst_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_250_vst_raman_532 = netcdf.defVar(ncID_raman, 'n_250_vst_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_250_vst_raman_1064 = netcdf.defVar(ncID_raman, 'n_250_vst_raman_1064', 'NC_FLOAT', dimID_height_raman);

% surface area concentrations
varID_sa_d_raman_355 = netcdf.defVar(ncID_raman, 'sa_d_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_sa_d_raman_532 = netcdf.defVar(ncID_raman, 'sa_d_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_sa_d_raman_1064 = netcdf.defVar(ncID_raman, 'sa_d_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_sa_c_raman_355 = netcdf.defVar(ncID_raman, 'sa_c_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_sa_c_raman_532 = netcdf.defVar(ncID_raman, 'sa_c_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_sa_c_raman_1064 = netcdf.defVar(ncID_raman, 'sa_c_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_sa_m_raman_355 = netcdf.defVar(ncID_raman, 'sa_m_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_sa_m_raman_532 = netcdf.defVar(ncID_raman, 'sa_m_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_sa_m_raman_1064 = netcdf.defVar(ncID_raman, 'sa_m_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_sa_bb_raman_355 = netcdf.defVar(ncID_raman, 'sa_bb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_sa_bb_raman_532 = netcdf.defVar(ncID_raman, 'sa_bb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_sa_bb_raman_1064 = netcdf.defVar(ncID_raman, 'sa_bb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_sa_vsf_raman_355 = netcdf.defVar(ncID_raman, 'sa_vsf_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_sa_vsf_raman_532 = netcdf.defVar(ncID_raman, 'sa_vsf_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_sa_vsf_raman_1064 = netcdf.defVar(ncID_raman, 'sa_vsf_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_sa_vsa_raman_355 = netcdf.defVar(ncID_raman, 'sa_vsa_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_sa_vsa_raman_532 = netcdf.defVar(ncID_raman, 'sa_vsa_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_sa_vsa_raman_1064 = netcdf.defVar(ncID_raman, 'sa_vsa_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_sa_vst_raman_355 = netcdf.defVar(ncID_raman, 'sa_vst_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_sa_vst_raman_532 = netcdf.defVar(ncID_raman, 'sa_vst_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_sa_vst_raman_1064 = netcdf.defVar(ncID_raman, 'sa_vst_raman_1064', 'NC_FLOAT', dimID_height_raman);

% errors
% extinction
varID_err_ext_d_raman_355 = netcdf.defVar(ncID_raman, 'err_ext_d_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_d_raman_532 = netcdf.defVar(ncID_raman, 'err_ext_d_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_d_raman_1064 = netcdf.defVar(ncID_raman, 'err_ext_d_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_cd_raman_355 = netcdf.defVar(ncID_raman, 'err_ext_cd_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_cd_raman_532 = netcdf.defVar(ncID_raman, 'err_ext_cd_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_cd_raman_1064 = netcdf.defVar(ncID_raman, 'err_ext_cd_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_fd_raman_355 = netcdf.defVar(ncID_raman, 'err_ext_fd_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_fd_raman_532 = netcdf.defVar(ncID_raman, 'err_ext_fd_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_fd_raman_1064 = netcdf.defVar(ncID_raman, 'err_ext_fd_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_ndm_raman_355 = netcdf.defVar(ncID_raman, 'err_ext_ndm_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_ndm_raman_532 = netcdf.defVar(ncID_raman, 'err_ext_ndm_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_ndm_raman_1064 = netcdf.defVar(ncID_raman, 'err_ext_ndm_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_nds_raman_355 = netcdf.defVar(ncID_raman, 'err_ext_nds_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_nds_raman_532 = netcdf.defVar(ncID_raman, 'err_ext_nds_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_nds_raman_1064 = netcdf.defVar(ncID_raman, 'err_ext_nds_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_bb_raman_355 = netcdf.defVar(ncID_raman, 'err_ext_bb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_bb_raman_532 = netcdf.defVar(ncID_raman, 'err_ext_bb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_bb_raman_1064 = netcdf.defVar(ncID_raman, 'err_ext_bb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_vsf_raman_355 = netcdf.defVar(ncID_raman, 'err_ext_vsf_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_vsf_raman_532 = netcdf.defVar(ncID_raman, 'err_ext_vsf_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_vsf_raman_1064 = netcdf.defVar(ncID_raman, 'err_ext_vsf_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_vsa_raman_355 = netcdf.defVar(ncID_raman, 'err_ext_vsa_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_vsa_raman_532 = netcdf.defVar(ncID_raman, 'err_ext_vsa_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_vsa_raman_1064 = netcdf.defVar(ncID_raman, 'err_ext_vsa_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_vst_raman_355 = netcdf.defVar(ncID_raman, 'err_ext_vst_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_vst_raman_532 = netcdf.defVar(ncID_raman, 'err_ext_vst_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_ext_vst_raman_1064 = netcdf.defVar(ncID_raman, 'err_ext_vst_raman_1064', 'NC_FLOAT', dimID_height_raman);

% mass
varID_err_m_d_raman_355 = netcdf.defVar(ncID_raman, 'err_m_d_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_m_d_raman_532 = netcdf.defVar(ncID_raman, 'err_m_d_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_m_d_raman_1064 = netcdf.defVar(ncID_raman, 'err_m_d_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_err_m_cd_raman_355 = netcdf.defVar(ncID_raman, 'err_m_cd_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_m_cd_raman_532 = netcdf.defVar(ncID_raman, 'err_m_cd_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_m_cd_raman_1064 = netcdf.defVar(ncID_raman, 'err_m_cd_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_err_m_fd_raman_355 = netcdf.defVar(ncID_raman, 'err_m_fd_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_m_fd_raman_532 = netcdf.defVar(ncID_raman, 'err_m_fd_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_m_fd_raman_1064 = netcdf.defVar(ncID_raman, 'err_m_fd_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_err_m_ndm_raman_355 = netcdf.defVar(ncID_raman, 'err_m_ndm_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_m_ndm_raman_532 = netcdf.defVar(ncID_raman, 'err_m_ndm_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_m_ndm_raman_1064 = netcdf.defVar(ncID_raman, 'err_m_ndm_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_err_m_nds_raman_355 = netcdf.defVar(ncID_raman, 'err_m_nds_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_m_nds_raman_532 = netcdf.defVar(ncID_raman, 'err_m_nds_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_m_nds_raman_1064 = netcdf.defVar(ncID_raman, 'err_m_nds_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_err_m_bb_raman_355 = netcdf.defVar(ncID_raman, 'err_m_bb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_m_bb_raman_532 = netcdf.defVar(ncID_raman, 'err_m_bb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_m_bb_raman_1064 = netcdf.defVar(ncID_raman, 'err_m_bb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_err_m_vsf_raman_355 = netcdf.defVar(ncID_raman, 'err_m_vsf_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_m_vsf_raman_532 = netcdf.defVar(ncID_raman, 'err_m_vsf_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_m_vsf_raman_1064 = netcdf.defVar(ncID_raman, 'err_m_vsf_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_err_m_vsa_raman_355 = netcdf.defVar(ncID_raman, 'err_m_vsa_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_m_vsa_raman_532 = netcdf.defVar(ncID_raman, 'err_m_vsa_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_m_vsa_raman_1064 = netcdf.defVar(ncID_raman, 'err_m_vsa_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_err_m_vst_raman_355 = netcdf.defVar(ncID_raman, 'err_m_vst_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_err_m_vst_raman_532 = netcdf.defVar(ncID_raman, 'err_m_vst_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_err_m_vst_raman_1064 = netcdf.defVar(ncID_raman, 'err_m_vst_raman_1064', 'NC_FLOAT', dimID_height_raman);

% CCN
varID_n_ccn_raman_355 = netcdf.defVar(ncID_raman, 'n_ccn_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_raman_532 = netcdf.defVar(ncID_raman, 'n_ccn_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_raman_1064 = netcdf.defVar(ncID_raman, 'n_ccn_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_d_raman_355 = netcdf.defVar(ncID_raman, 'n_ccn_d_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_d_raman_532 = netcdf.defVar(ncID_raman, 'n_ccn_d_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_d_raman_1064 = netcdf.defVar(ncID_raman, 'n_ccn_d_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_c_raman_355 = netcdf.defVar(ncID_raman, 'n_ccn_c_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_c_raman_532 = netcdf.defVar(ncID_raman, 'n_ccn_c_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_c_raman_1064 = netcdf.defVar(ncID_raman, 'n_ccn_c_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_m_raman_355 = netcdf.defVar(ncID_raman, 'n_ccn_m_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_m_raman_532 = netcdf.defVar(ncID_raman, 'n_ccn_m_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_m_raman_1064 = netcdf.defVar(ncID_raman, 'n_ccn_m_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_bb_raman_355 = netcdf.defVar(ncID_raman, 'n_ccn_bb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_bb_raman_532 = netcdf.defVar(ncID_raman, 'n_ccn_bb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_bb_raman_1064 = netcdf.defVar(ncID_raman, 'n_ccn_bb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_vsf_raman_355 = netcdf.defVar(ncID_raman, 'n_ccn_vsf_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_vsf_raman_532 = netcdf.defVar(ncID_raman, 'n_ccn_vsf_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_vsf_raman_1064 = netcdf.defVar(ncID_raman, 'n_ccn_vsf_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_vst_raman_355 = netcdf.defVar(ncID_raman, 'n_ccn_vst_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_vst_raman_532 = netcdf.defVar(ncID_raman, 'n_ccn_vst_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_vst_raman_1064 = netcdf.defVar(ncID_raman, 'n_ccn_vst_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_vsa_raman_355 = netcdf.defVar(ncID_raman, 'n_ccn_vsa_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_vsa_raman_532 = netcdf.defVar(ncID_raman, 'n_ccn_vsa_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_ccn_vsa_raman_1064 = netcdf.defVar(ncID_raman, 'n_ccn_vsa_raman_1064', 'NC_FLOAT', dimID_height_raman);

% INP
varID_n_inp_d_d10_amb_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_d10_amb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_d10_amb_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_d_d10_amb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_d10_amb_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_d_d10_amb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_d15_amb_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_d_d15_amb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_d15_amb_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_d_d15_amb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_d15_amb_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_d_d15_amb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_n12_amb_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_d_n12_amb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_n12_amb_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_d_n12_amb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_n12_amb_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_d_n12_amb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_s15_amb_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_d_s15_amb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_s15_amb_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_d_s15_amb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_s15_amb_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_d_s15_amb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_d10_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_d_d10_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_d10_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_d_d10_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_d10_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_d_d10_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_d15_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_d_d15_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_d15_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_d_d15_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_d15_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_d_d15_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_n12_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_d_n12_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_n12_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_d_n12_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_n12_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_d_n12_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_s15_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_d_s15_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_s15_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_d_s15_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_d_s15_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_d_s15_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_c_d10_amb_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_c_d10_amb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_c_d10_amb_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_c_d10_amb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_c_d10_amb_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_c_d10_amb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_c_d10_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_c_d10_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_c_d10_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_c_d10_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_c_d10_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_c_d10_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_m_d10_amb_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_m_d10_amb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_m_d10_amb_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_m_d10_amb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_m_d10_amb_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_m_d10_amb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_m_d10_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_m_d10_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_m_d10_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_m_d10_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_m_d10_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_m_d10_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_bb_d10_amb_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_bb_d10_amb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_bb_d10_amb_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_bb_d10_amb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_bb_d10_amb_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_bb_d10_amb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_bb_d10_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_bb_d10_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_bb_d10_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_bb_d10_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_bb_d10_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_bb_d10_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vsf_d10_amb_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_vsf_d10_amb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vsf_d10_amb_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_vsf_d10_amb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vsf_d10_amb_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_vsf_d10_amb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vsf_d10_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_vsf_d10_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vsf_d10_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_vsf_d10_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vsf_d10_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_vsf_d10_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vsa_d10_amb_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_vsa_d10_amb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vsa_d10_amb_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_vsa_d10_amb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vsa_d10_amb_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_vsa_d10_amb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vsa_d10_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_vsa_d10_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vsa_d10_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_vsa_d10_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vsa_d10_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_vsa_d10_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vst_d10_amb_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_vst_d10_amb_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vst_d10_amb_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_vst_d10_amb_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vst_d10_amb_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_vst_d10_amb_raman_1064', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vst_d10_raman_355 = netcdf.defVar(ncID_raman, 'n_inp_vst_d10_raman_355', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vst_d10_raman_532 = netcdf.defVar(ncID_raman, 'n_inp_vst_d10_raman_532', 'NC_FLOAT', dimID_height_raman);
varID_n_inp_vst_d10_raman_1064 = netcdf.defVar(ncID_raman, 'n_inp_vst_d10_raman_1064', 'NC_FLOAT', dimID_height_raman);

%% klett
varID_aerBsc355_klett_d2       = netcdf.defVar(ncID_klett, 'aerBsc355_klett_d2', 'NC_FLOAT', dimID_height_klett);
varID_err_aerBsc355_klett_d2   = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc355_klett_d2', 'NC_FLOAT', dimID_height_klett);
varID_aerBsc355_klett_dc2         = netcdf.defVar(ncID_klett, 'aerBsc355_klett_dc2', 'NC_FLOAT', dimID_height_klett);
varID_err_aerBsc355_klett_dc2     = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc355_klett_dc2', 'NC_FLOAT', dimID_height_klett);
varID_aerBsc355_klett_df2         = netcdf.defVar(ncID_klett, 'aerBsc355_klett_df2', 'NC_FLOAT', dimID_height_klett);
varID_err_aerBsc355_klett_df2     = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc355_klett_df2', 'NC_FLOAT', dimID_height_klett);
varID_aerBsc355_klett_nddf2       = netcdf.defVar(ncID_klett, 'aerBsc355_klett_nddf2', 'NC_FLOAT', dimID_height_klett);
varID_err_aerBsc355_klett_nddf2   = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc355_klett_nddf2', 'NC_FLOAT', dimID_height_klett);
varID_aerBsc355_klett_nd2      = netcdf.defVar(ncID_klett, 'aerBsc355_klett_nd2', 'NC_FLOAT', dimID_height_klett);
varID_err_aerBsc355_klett_nd2  = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc355_klett_nd2', 'NC_FLOAT', dimID_height_klett);


varID_aerBsc532_klett_d2       = netcdf.defVar(ncID_klett, 'aerBsc532_klett_d2', 'NC_FLOAT', dimID_height_klett);
varID_err_aerBsc532_klett_d2   = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc532_klett_d2', 'NC_FLOAT', dimID_height_klett);
varID_aerBsc532_klett_dc2         = netcdf.defVar(ncID_klett, 'aerBsc532_klett_dc2', 'NC_FLOAT', dimID_height_klett);
varID_err_aerBsc532_klett_dc2     = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc532_klett_dc2', 'NC_FLOAT', dimID_height_klett);
varID_aerBsc532_klett_df2         = netcdf.defVar(ncID_klett, 'aerBsc532_klett_df2', 'NC_FLOAT', dimID_height_klett);
varID_err_aerBsc532_klett_df2     = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc532_klett_df2', 'NC_FLOAT', dimID_height_klett);
varID_aerBsc532_klett_nddf2       = netcdf.defVar(ncID_klett, 'aerBsc532_klett_nddf2', 'NC_FLOAT', dimID_height_klett);
varID_err_aerBsc532_klett_nddf2   = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc532_klett_nddf2', 'NC_FLOAT', dimID_height_klett);
varID_aerBsc532_klett_nd2      = netcdf.defVar(ncID_klett, 'aerBsc532_klett_nd2', 'NC_FLOAT', dimID_height_klett);
varID_err_aerBsc532_klett_nd2  = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc532_klett_nd2', 'NC_FLOAT', dimID_height_klett);

varID_aerBsc1064_klett_d2       = netcdf.defVar(ncID_klett, 'aerBsc1064_klett_d2', 'NC_FLOAT', dimID_height_klett);
varID_err_aerBsc1064_klett_d2   = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc1064_klett_d2', 'NC_FLOAT', dimID_height_klett);
varID_aerBsc1064_klett_dc2         = netcdf.defVar(ncID_klett, 'aerBsc1064_klett_dc2', 'NC_FLOAT', dimID_height_klett);
varID_err_aerBsc1064_klett_dc2     = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc1064_klett_dc2', 'NC_FLOAT', dimID_height_klett);
varID_aerBsc1064_klett_df2         = netcdf.defVar(ncID_klett, 'aerBsc1064_klett_df2', 'NC_FLOAT', dimID_height_klett);
varID_err_aerBsc1064_klett_df2     = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc1064_klett_df2', 'NC_FLOAT', dimID_height_klett);
varID_aerBsc1064_klett_nddf2       = netcdf.defVar(ncID_klett, 'aerBsc1064_klett_nddf2', 'NC_FLOAT', dimID_height_klett);
varID_err_aerBsc1064_klett_nddf2   = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc1064_klett_nddf2', 'NC_FLOAT', dimID_height_klett);
varID_aerBsc1064_klett_nd2      = netcdf.defVar(ncID_klett, 'aerBsc1064_klett_nd2', 'NC_FLOAT', dimID_height_klett);
varID_err_aerBsc1064_klett_nd2  = netcdf.defVar(ncID_klett, 'uncertainty_aerBsc1064_klett_nd2', 'NC_FLOAT', dimID_height_klett);


% extinction coeffs
varID_ext_d_klett_355 = netcdf.defVar(ncID_klett, 'ext_d_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_ext_d_klett_532 = netcdf.defVar(ncID_klett, 'ext_d_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_ext_d_klett_1064 = netcdf.defVar(ncID_klett, 'ext_d_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_ext_cd_klett_355 = netcdf.defVar(ncID_klett, 'ext_cd_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_ext_cd_klett_532 = netcdf.defVar(ncID_klett, 'ext_cd_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_ext_cd_klett_1064 = netcdf.defVar(ncID_klett, 'ext_cd_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_ext_fd_klett_355 = netcdf.defVar(ncID_klett, 'ext_fd_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_ext_fd_klett_532 = netcdf.defVar(ncID_klett, 'ext_fd_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_ext_fd_klett_1064 = netcdf.defVar(ncID_klett, 'ext_fd_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_ext_ndm_klett_355 = netcdf.defVar(ncID_klett, 'ext_ndm1_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_ext_ndm_klett_532 = netcdf.defVar(ncID_klett, 'ext_ndm1_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_ext_ndm_klett_1064 = netcdf.defVar(ncID_klett, 'ext_ndm1_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_ext_nds_klett_355 = netcdf.defVar(ncID_klett, 'ext_nds1_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_ext_nds_klett_532 = netcdf.defVar(ncID_klett, 'ext_nds1_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_ext_nds_klett_1064 = netcdf.defVar(ncID_klett, 'ext_nds1_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_ext_bb_klett_355 = netcdf.defVar(ncID_klett, 'ext_bb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_ext_bb_klett_532 = netcdf.defVar(ncID_klett, 'ext_bb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_ext_bb_klett_1064 = netcdf.defVar(ncID_klett, 'ext_bb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_ext_vsf_klett_355 = netcdf.defVar(ncID_klett, 'ext_vsf_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_ext_vsf_klett_532 = netcdf.defVar(ncID_klett, 'ext_vsf_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_ext_vsf_klett_1064 = netcdf.defVar(ncID_klett, 'ext_vsf_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_ext_vsa_klett_355 = netcdf.defVar(ncID_klett, 'ext_vsa_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_ext_vsa_klett_532 = netcdf.defVar(ncID_klett, 'ext_vsa_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_ext_vsa_klett_1064 = netcdf.defVar(ncID_klett, 'ext_vsa_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_ext_vst_klett_355 = netcdf.defVar(ncID_klett, 'ext_vst_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_ext_vst_klett_532 = netcdf.defVar(ncID_klett, 'ext_vst_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_ext_vst_klett_1064 = netcdf.defVar(ncID_klett, 'ext_vst_klett_1064', 'NC_FLOAT', dimID_height_klett);

% mass concentrations
varID_m_d_klett_355 = netcdf.defVar(ncID_klett, 'm_d_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_m_d_klett_532 = netcdf.defVar(ncID_klett, 'm_d_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_m_d_klett_1064 = netcdf.defVar(ncID_klett, 'm_d_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_m_cd_klett_355 = netcdf.defVar(ncID_klett, 'm_cd_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_m_cd_klett_532 = netcdf.defVar(ncID_klett, 'm_cd_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_m_cd_klett_1064 = netcdf.defVar(ncID_klett, 'm_cd_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_m_fd_klett_355 = netcdf.defVar(ncID_klett, 'm_fd_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_m_fd_klett_532 = netcdf.defVar(ncID_klett, 'm_fd_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_m_fd_klett_1064 = netcdf.defVar(ncID_klett, 'm_fd_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_m_ndm_klett_355 = netcdf.defVar(ncID_klett, 'm_ndm_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_m_ndm_klett_532 = netcdf.defVar(ncID_klett, 'm_ndm_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_m_ndm_klett_1064 = netcdf.defVar(ncID_klett, 'm_ndm_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_m_nds_klett_355 = netcdf.defVar(ncID_klett, 'm_nds_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_m_nds_klett_532 = netcdf.defVar(ncID_klett, 'm_nds_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_m_nds_klett_1064 = netcdf.defVar(ncID_klett, 'm_nds_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_m_bb_klett_355 = netcdf.defVar(ncID_klett, 'm_bb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_m_bb_klett_532 = netcdf.defVar(ncID_klett, 'm_bb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_m_bb_klett_1064 = netcdf.defVar(ncID_klett, 'm_bb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_m_vsf_klett_355 = netcdf.defVar(ncID_klett, 'm_vsf_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_m_vsf_klett_532 = netcdf.defVar(ncID_klett, 'm_vsf_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_m_vsf_klett_1064 = netcdf.defVar(ncID_klett, 'm_vsf_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_m_vsa_klett_355 = netcdf.defVar(ncID_klett, 'm_vsa_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_m_vsa_klett_532 = netcdf.defVar(ncID_klett, 'm_vsa_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_m_vsa_klett_1064 = netcdf.defVar(ncID_klett, 'm_vsa_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_m_vst_klett_355 = netcdf.defVar(ncID_klett, 'm_vst_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_m_vst_klett_532 = netcdf.defVar(ncID_klett, 'm_vst_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_m_vst_klett_1064 = netcdf.defVar(ncID_klett, 'm_vst_klett_1064', 'NC_FLOAT', dimID_height_klett);

% number concentrations
varID_n_100_d_klett_355 = netcdf.defVar(ncID_klett, 'n_100_d_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_100_d_klett_532 = netcdf.defVar(ncID_klett, 'n_100_d_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_100_d_klett_1064 = netcdf.defVar(ncID_klett, 'n_100_d_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_250_d_klett_355 = netcdf.defVar(ncID_klett, 'n_250_d_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_250_d_klett_532 = netcdf.defVar(ncID_klett, 'n_250_d_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_250_d_klett_1064 = netcdf.defVar(ncID_klett, 'n_250_d_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_50_c_klett_355 = netcdf.defVar(ncID_klett, 'n_50_c_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_50_c_klett_532 = netcdf.defVar(ncID_klett, 'n_50_c_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_50_c_klett_1064 = netcdf.defVar(ncID_klett, 'n_50_c_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_250_c_klett_355 = netcdf.defVar(ncID_klett, 'n_250_c_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_250_c_klett_532 = netcdf.defVar(ncID_klett, 'n_250_c_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_250_c_klett_1064 = netcdf.defVar(ncID_klett, 'n_250_c_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_50_m_klett_355 = netcdf.defVar(ncID_klett, 'n_50_m_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_50_m_klett_532 = netcdf.defVar(ncID_klett, 'n_50_m_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_50_m_klett_1064 = netcdf.defVar(ncID_klett, 'n_50_m_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_250_m_klett_355 = netcdf.defVar(ncID_klett, 'n_250_m_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_250_m_klett_532 = netcdf.defVar(ncID_klett, 'n_250_m_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_250_m_klett_1064 = netcdf.defVar(ncID_klett, 'n_250_m_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_50_bb_klett_355 = netcdf.defVar(ncID_klett, 'n_50_bb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_50_bb_klett_532 = netcdf.defVar(ncID_klett, 'n_50_bb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_50_bb_klett_1064 = netcdf.defVar(ncID_klett, 'n_50_bb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_250_bb_klett_355 = netcdf.defVar(ncID_klett, 'n_250_bb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_250_bb_klett_532 = netcdf.defVar(ncID_klett, 'n_250_bb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_250_bb_klett_1064 = netcdf.defVar(ncID_klett, 'n_250_bb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_50_vsf_klett_355 = netcdf.defVar(ncID_klett, 'n_50_vsf_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_50_vsf_klett_532 = netcdf.defVar(ncID_klett, 'n_50_vsf_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_50_vsf_klett_1064 = netcdf.defVar(ncID_klett, 'n_50_vsf_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_250_vsf_klett_355 = netcdf.defVar(ncID_klett, 'n_250_vsf_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_250_vsf_klett_532 = netcdf.defVar(ncID_klett, 'n_250_vsf_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_250_vsf_klett_1064 = netcdf.defVar(ncID_klett, 'n_250_vsf_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_50_vsa_klett_355 = netcdf.defVar(ncID_klett, 'n_50_vsa_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_50_vsa_klett_532 = netcdf.defVar(ncID_klett, 'n_50_vsa_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_50_vsa_klett_1064 = netcdf.defVar(ncID_klett, 'n_50_vsa_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_250_vsa_klett_355 = netcdf.defVar(ncID_klett, 'n_250_vsa_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_250_vsa_klett_532 = netcdf.defVar(ncID_klett, 'n_250_vsa_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_250_vsa_klett_1064 = netcdf.defVar(ncID_klett, 'n_250_vsa_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_50_vst_klett_355 = netcdf.defVar(ncID_klett, 'n_50_vst_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_50_vst_klett_532 = netcdf.defVar(ncID_klett, 'n_50_vst_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_50_vst_klett_1064 = netcdf.defVar(ncID_klett, 'n_50_vst_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_250_vst_klett_355 = netcdf.defVar(ncID_klett, 'n_250_vst_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_250_vst_klett_532 = netcdf.defVar(ncID_klett, 'n_250_vst_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_250_vst_klett_1064 = netcdf.defVar(ncID_klett, 'n_250_vst_klett_1064', 'NC_FLOAT', dimID_height_klett);

% surface area concentrations
varID_sa_d_klett_355 = netcdf.defVar(ncID_klett, 'sa_d_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_sa_d_klett_532 = netcdf.defVar(ncID_klett, 'sa_d_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_sa_d_klett_1064 = netcdf.defVar(ncID_klett, 'sa_d_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_sa_c_klett_355 = netcdf.defVar(ncID_klett, 'sa_c_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_sa_c_klett_532 = netcdf.defVar(ncID_klett, 'sa_c_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_sa_c_klett_1064 = netcdf.defVar(ncID_klett, 'sa_c_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_sa_m_klett_355 = netcdf.defVar(ncID_klett, 'sa_m_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_sa_m_klett_532 = netcdf.defVar(ncID_klett, 'sa_m_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_sa_m_klett_1064 = netcdf.defVar(ncID_klett, 'sa_m_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_sa_bb_klett_355 = netcdf.defVar(ncID_klett, 'sa_bb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_sa_bb_klett_532 = netcdf.defVar(ncID_klett, 'sa_bb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_sa_bb_klett_1064 = netcdf.defVar(ncID_klett, 'sa_bb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_sa_vsf_klett_355 = netcdf.defVar(ncID_klett, 'sa_vsf_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_sa_vsf_klett_532 = netcdf.defVar(ncID_klett, 'sa_vsf_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_sa_vsf_klett_1064 = netcdf.defVar(ncID_klett, 'sa_vsf_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_sa_vsa_klett_355 = netcdf.defVar(ncID_klett, 'sa_vsa_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_sa_vsa_klett_532 = netcdf.defVar(ncID_klett, 'sa_vsa_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_sa_vsa_klett_1064 = netcdf.defVar(ncID_klett, 'sa_vsa_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_sa_vst_klett_355 = netcdf.defVar(ncID_klett, 'sa_vst_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_sa_vst_klett_532 = netcdf.defVar(ncID_klett, 'sa_vst_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_sa_vst_klett_1064 = netcdf.defVar(ncID_klett, 'sa_vst_klett_1064', 'NC_FLOAT', dimID_height_klett);

% errors
% extinction
varID_err_ext_d_klett_355 = netcdf.defVar(ncID_klett, 'err_ext_d_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_d_klett_532 = netcdf.defVar(ncID_klett, 'err_ext_d_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_d_klett_1064 = netcdf.defVar(ncID_klett, 'err_ext_d_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_cd_klett_355 = netcdf.defVar(ncID_klett, 'err_ext_cd_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_cd_klett_532 = netcdf.defVar(ncID_klett, 'err_ext_cd_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_cd_klett_1064 = netcdf.defVar(ncID_klett, 'err_ext_cd_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_fd_klett_355 = netcdf.defVar(ncID_klett, 'err_ext_fd_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_fd_klett_532 = netcdf.defVar(ncID_klett, 'err_ext_fd_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_fd_klett_1064 = netcdf.defVar(ncID_klett, 'err_ext_fd_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_ndm_klett_355 = netcdf.defVar(ncID_klett, 'err_ext_ndm_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_ndm_klett_532 = netcdf.defVar(ncID_klett, 'err_ext_ndm_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_ndm_klett_1064 = netcdf.defVar(ncID_klett, 'err_ext_ndm_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_nds_klett_355 = netcdf.defVar(ncID_klett, 'err_ext_nds_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_nds_klett_532 = netcdf.defVar(ncID_klett, 'err_ext_nds_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_nds_klett_1064 = netcdf.defVar(ncID_klett, 'err_ext_nds_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_bb_klett_355 = netcdf.defVar(ncID_klett, 'err_ext_bb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_bb_klett_532 = netcdf.defVar(ncID_klett, 'err_ext_bb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_bb_klett_1064 = netcdf.defVar(ncID_klett, 'err_ext_bb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_vsf_klett_355 = netcdf.defVar(ncID_klett, 'err_ext_vsf_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_vsf_klett_532 = netcdf.defVar(ncID_klett, 'err_ext_vsf_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_vsf_klett_1064 = netcdf.defVar(ncID_klett, 'err_ext_vsf_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_vsa_klett_355 = netcdf.defVar(ncID_klett, 'err_ext_vsa_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_vsa_klett_532 = netcdf.defVar(ncID_klett, 'err_ext_vsa_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_vsa_klett_1064 = netcdf.defVar(ncID_klett, 'err_ext_vsa_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_vst_klett_355 = netcdf.defVar(ncID_klett, 'err_ext_vst_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_vst_klett_532 = netcdf.defVar(ncID_klett, 'err_ext_vst_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_ext_vst_klett_1064 = netcdf.defVar(ncID_klett, 'err_ext_vst_klett_1064', 'NC_FLOAT', dimID_height_klett);

% mass
varID_err_m_d_klett_355 = netcdf.defVar(ncID_klett, 'err_m_d_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_m_d_klett_532 = netcdf.defVar(ncID_klett, 'err_m_d_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_m_d_klett_1064 = netcdf.defVar(ncID_klett, 'err_m_d_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_err_m_cd_klett_355 = netcdf.defVar(ncID_klett, 'err_m_cd_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_m_cd_klett_532 = netcdf.defVar(ncID_klett, 'err_m_cd_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_m_cd_klett_1064 = netcdf.defVar(ncID_klett, 'err_m_cd_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_err_m_fd_klett_355 = netcdf.defVar(ncID_klett, 'err_m_fd_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_m_fd_klett_532 = netcdf.defVar(ncID_klett, 'err_m_fd_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_m_fd_klett_1064 = netcdf.defVar(ncID_klett, 'err_m_fd_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_err_m_ndm_klett_355 = netcdf.defVar(ncID_klett, 'err_m_ndm_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_m_ndm_klett_532 = netcdf.defVar(ncID_klett, 'err_m_ndm_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_m_ndm_klett_1064 = netcdf.defVar(ncID_klett, 'err_m_ndm_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_err_m_nds_klett_355 = netcdf.defVar(ncID_klett, 'err_m_nds_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_m_nds_klett_532 = netcdf.defVar(ncID_klett, 'err_m_nds_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_m_nds_klett_1064 = netcdf.defVar(ncID_klett, 'err_m_nds_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_err_m_bb_klett_355 = netcdf.defVar(ncID_klett, 'err_m_bb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_m_bb_klett_532 = netcdf.defVar(ncID_klett, 'err_m_bb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_m_bb_klett_1064 = netcdf.defVar(ncID_klett, 'err_m_bb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_err_m_vsf_klett_355 = netcdf.defVar(ncID_klett, 'err_m_vsf_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_m_vsf_klett_532 = netcdf.defVar(ncID_klett, 'err_m_vsf_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_m_vsf_klett_1064 = netcdf.defVar(ncID_klett, 'err_m_vsf_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_err_m_vsa_klett_355 = netcdf.defVar(ncID_klett, 'err_m_vsa_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_m_vsa_klett_532 = netcdf.defVar(ncID_klett, 'err_m_vsa_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_m_vsa_klett_1064 = netcdf.defVar(ncID_klett, 'err_m_vsa_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_err_m_vst_klett_355 = netcdf.defVar(ncID_klett, 'err_m_vst_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_err_m_vst_klett_532 = netcdf.defVar(ncID_klett, 'err_m_vst_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_err_m_vst_klett_1064 = netcdf.defVar(ncID_klett, 'err_m_vst_klett_1064', 'NC_FLOAT', dimID_height_klett);

% CCN
varID_n_ccn_klett_355 = netcdf.defVar(ncID_klett, 'n_ccn_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_klett_532 = netcdf.defVar(ncID_klett, 'n_ccn_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_klett_1064 = netcdf.defVar(ncID_klett, 'n_ccn_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_d_klett_355 = netcdf.defVar(ncID_klett, 'n_ccn_d_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_d_klett_532 = netcdf.defVar(ncID_klett, 'n_ccn_d_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_d_klett_1064 = netcdf.defVar(ncID_klett, 'n_ccn_d_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_c_klett_355 = netcdf.defVar(ncID_klett, 'n_ccn_c_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_c_klett_532 = netcdf.defVar(ncID_klett, 'n_ccn_c_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_c_klett_1064 = netcdf.defVar(ncID_klett, 'n_ccn_c_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_m_klett_355 = netcdf.defVar(ncID_klett, 'n_ccn_m_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_m_klett_532 = netcdf.defVar(ncID_klett, 'n_ccn_m_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_m_klett_1064 = netcdf.defVar(ncID_klett, 'n_ccn_m_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_bb_klett_355 = netcdf.defVar(ncID_klett, 'n_ccn_bb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_bb_klett_532 = netcdf.defVar(ncID_klett, 'n_ccn_bb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_bb_klett_1064 = netcdf.defVar(ncID_klett, 'n_ccn_bb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_vsf_klett_355 = netcdf.defVar(ncID_klett, 'n_ccn_vsf_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_vsf_klett_532 = netcdf.defVar(ncID_klett, 'n_ccn_vsf_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_vsf_klett_1064 = netcdf.defVar(ncID_klett, 'n_ccn_vsf_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_vst_klett_355 = netcdf.defVar(ncID_klett, 'n_ccn_vst_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_vst_klett_532 = netcdf.defVar(ncID_klett, 'n_ccn_vst_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_vst_klett_1064 = netcdf.defVar(ncID_klett, 'n_ccn_vst_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_vsa_klett_355 = netcdf.defVar(ncID_klett, 'n_ccn_vsa_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_vsa_klett_532 = netcdf.defVar(ncID_klett, 'n_ccn_vsa_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_ccn_vsa_klett_1064 = netcdf.defVar(ncID_klett, 'n_ccn_vsa_klett_1064', 'NC_FLOAT', dimID_height_klett);

% INP
varID_n_inp_d_d10_amb_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_d_d10_amb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_d10_amb_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_d_d10_amb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_d10_amb_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_d_d10_amb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_d15_amb_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_d_d15_amb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_d15_amb_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_d_d15_amb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_d15_amb_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_d_d15_amb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_n12_amb_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_d_n12_amb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_n12_amb_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_d_n12_amb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_n12_amb_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_d_n12_amb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_s15_amb_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_d_s15_amb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_s15_amb_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_d_s15_amb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_s15_amb_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_d_s15_amb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_d10_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_d_d10_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_d10_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_d_d10_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_d10_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_d_d10_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_d15_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_d_d15_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_d15_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_d_d15_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_d15_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_d_d15_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_n12_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_d_n12_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_n12_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_d_n12_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_n12_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_d_n12_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_s15_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_d_s15_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_s15_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_d_s15_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_d_s15_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_d_s15_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_c_d10_amb_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_c_d10_amb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_c_d10_amb_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_c_d10_amb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_c_d10_amb_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_c_d10_amb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_c_d10_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_c_d10_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_c_d10_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_c_d10_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_c_d10_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_c_d10_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_m_d10_amb_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_m_d10_amb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_m_d10_amb_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_m_d10_amb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_m_d10_amb_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_m_d10_amb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_m_d10_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_m_d10_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_m_d10_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_m_d10_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_m_d10_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_m_d10_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_bb_d10_amb_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_bb_d10_amb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_bb_d10_amb_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_bb_d10_amb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_bb_d10_amb_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_bb_d10_amb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_bb_d10_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_bb_d10_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_bb_d10_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_bb_d10_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_bb_d10_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_bb_d10_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vsf_d10_amb_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_vsf_d10_amb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vsf_d10_amb_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_vsf_d10_amb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vsf_d10_amb_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_vsf_d10_amb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vsf_d10_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_vsf_d10_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vsf_d10_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_vsf_d10_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vsf_d10_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_vsf_d10_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vsa_d10_amb_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_vsa_d10_amb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vsa_d10_amb_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_vsa_d10_amb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vsa_d10_amb_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_vsa_d10_amb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vsa_d10_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_vsa_d10_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vsa_d10_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_vsa_d10_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vsa_d10_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_vsa_d10_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vst_d10_amb_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_vst_d10_amb_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vst_d10_amb_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_vst_d10_amb_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vst_d10_amb_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_vst_d10_amb_klett_1064', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vst_d10_klett_355 = netcdf.defVar(ncID_klett, 'n_inp_vst_d10_klett_355', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vst_d10_klett_532 = netcdf.defVar(ncID_klett, 'n_inp_vst_d10_klett_532', 'NC_FLOAT', dimID_height_klett);
varID_n_inp_vst_d10_klett_1064 = netcdf.defVar(ncID_klett, 'n_inp_vst_d10_klett_1064', 'NC_FLOAT', dimID_height_klett);

% define the filling value
netcdf.defVarFill(ncID_raman, varID_beta_dc_raman, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_beta_dc_klett, false, missing_value);

% klett
netcdf.defVarFill(ncID_klett, varID_aerBsc_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBscStd_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBsc355_klett_d2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_aerBsc355_klett_d2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBsc355_klett_dc2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_aerBsc355_klett_dc2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBsc355_klett_df2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_aerBsc355_klett_df2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBsc355_klett_nddf2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_aerBsc355_klett_nddf2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBsc355_klett_nd2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_aerBsc355_klett_nd2, false, missing_value);

netcdf.defVarFill(ncID_klett, varID_aerBsc_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBscStd_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBsc532_klett_d2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_aerBsc532_klett_d2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBsc532_klett_dc2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_aerBsc532_klett_dc2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBsc532_klett_df2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_aerBsc532_klett_df2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBsc532_klett_nddf2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_aerBsc532_klett_nddf2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBsc532_klett_nd2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_aerBsc532_klett_nd2, false, missing_value);

netcdf.defVarFill(ncID_klett, varID_aerBsc_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBscStd_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBsc1064_klett_d2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_aerBsc1064_klett_d2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBsc1064_klett_dc2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_aerBsc1064_klett_dc2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBsc1064_klett_df2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_aerBsc1064_klett_df2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBsc1064_klett_nddf2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_aerBsc1064_klett_nddf2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_aerBsc1064_klett_nd2, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_aerBsc1064_klett_nd2, false, missing_value);

% extinction fill values
netcdf.defVarFill(ncID_klett, varID_ext_d_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_d_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_d_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_cd_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_cd_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_cd_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_fd_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_fd_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_fd_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_ndm_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_ndm_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_ndm_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_nds_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_nds_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_nds_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_bb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_bb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_bb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_vsf_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_vsf_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_vsf_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_vsa_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_vsa_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_vsa_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_vst_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_vst_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_ext_vst_klett_1064, false, missing_value);

% mass fill values
netcdf.defVarFill(ncID_klett, varID_m_d_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_d_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_d_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_cd_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_cd_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_cd_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_fd_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_fd_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_fd_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_ndm_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_ndm_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_ndm_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_nds_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_nds_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_nds_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_bb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_bb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_bb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_vsf_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_vsf_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_vsf_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_vsa_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_vsa_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_vsa_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_vst_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_vst_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_m_vst_klett_1064, false, missing_value);

% nmber fill values
netcdf.defVarFill(ncID_klett, varID_n_100_d_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_100_d_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_100_d_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_d_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_d_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_d_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_c_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_c_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_c_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_c_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_c_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_c_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_m_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_m_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_m_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_m_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_m_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_m_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_bb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_bb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_bb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_bb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_bb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_bb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_vsf_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_vsf_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_vsf_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_vsf_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_vsf_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_vsf_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_vsa_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_vsa_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_vsa_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_vsa_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_vsa_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_vsa_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_vst_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_vst_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_50_vst_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_vst_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_vst_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_250_vst_klett_1064, false, missing_value);

% surface area fill values
netcdf.defVarFill(ncID_klett, varID_sa_d_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_d_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_d_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_c_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_c_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_c_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_m_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_m_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_m_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_bb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_bb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_bb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_vsf_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_vsf_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_vsf_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_vsa_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_vsa_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_vsa_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_vst_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_vst_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_sa_vst_klett_1064, false, missing_value);

% error (extinction) fill values
netcdf.defVarFill(ncID_klett, varID_err_ext_d_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_d_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_d_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_cd_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_cd_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_cd_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_fd_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_fd_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_fd_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_ndm_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_ndm_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_ndm_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_nds_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_nds_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_nds_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_bb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_bb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_bb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_vsf_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_vsf_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_vsf_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_vsa_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_vsa_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_vsa_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_vst_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_vst_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_ext_vst_klett_1064, false, missing_value);

% error (mass) fill values
netcdf.defVarFill(ncID_klett, varID_err_m_d_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_d_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_d_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_cd_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_cd_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_cd_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_fd_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_fd_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_fd_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_ndm_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_ndm_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_ndm_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_nds_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_nds_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_nds_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_bb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_bb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_bb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_vsf_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_vsf_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_vsf_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_vsa_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_vsa_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_vsa_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_vst_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_vst_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_err_m_vst_klett_1064, false, missing_value);

% CCN fill values
netcdf.defVarFill(ncID_klett, varID_n_ccn_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_d_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_d_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_d_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_c_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_c_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_c_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_m_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_m_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_m_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_bb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_bb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_bb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_vsf_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_vsf_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_vsf_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_vst_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_vst_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_vst_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_vsa_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_vsa_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_ccn_vsa_klett_1064, false, missing_value);

% INP fill values
netcdf.defVarFill(ncID_klett, varID_n_inp_d_d10_amb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_d10_amb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_d10_amb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_d15_amb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_d15_amb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_d15_amb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_n12_amb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_n12_amb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_n12_amb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_s15_amb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_s15_amb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_s15_amb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_d10_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_d10_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_d10_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_d15_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_d15_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_d15_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_n12_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_n12_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_n12_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_s15_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_s15_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_d_s15_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_c_d10_amb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_c_d10_amb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_c_d10_amb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_c_d10_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_c_d10_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_c_d10_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_m_d10_amb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_m_d10_amb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_m_d10_amb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_m_d10_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_m_d10_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_m_d10_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_bb_d10_amb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_bb_d10_amb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_bb_d10_amb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_bb_d10_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_bb_d10_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_bb_d10_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vsf_d10_amb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vsf_d10_amb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vsf_d10_amb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vsf_d10_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vsf_d10_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vsf_d10_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vsa_d10_amb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vsa_d10_amb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vsa_d10_amb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vsa_d10_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vsa_d10_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vsa_d10_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vst_d10_amb_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vst_d10_amb_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vst_d10_amb_klett_1064, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vst_d10_klett_355, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vst_d10_klett_532, false, missing_value);
netcdf.defVarFill(ncID_klett, varID_n_inp_vst_d10_klett_1064, false, missing_value);


% raman
netcdf.defVarFill(ncID_raman, varID_aerBsc_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBscStd_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBsc355_raman_d2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_aerBsc355_raman_d2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBsc355_raman_dc2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_aerBsc355_raman_dc2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBsc355_raman_df2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_aerBsc355_raman_df2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBsc355_raman_nddf2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_aerBsc355_raman_nddf2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBsc355_raman_nd2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_aerBsc355_raman_nd2, false, missing_value);

netcdf.defVarFill(ncID_raman, varID_aerBsc_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBscStd_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBsc532_raman_d2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_aerBsc532_raman_d2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBsc532_raman_dc2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_aerBsc532_raman_dc2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBsc532_raman_df2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_aerBsc532_raman_df2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBsc532_raman_nddf2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_aerBsc532_raman_nddf2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBsc532_raman_nd2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_aerBsc532_raman_nd2, false, missing_value);

netcdf.defVarFill(ncID_raman, varID_aerBsc_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBscStd_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBsc1064_raman_d2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_aerBsc1064_raman_d2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBsc1064_raman_dc2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_aerBsc1064_raman_dc2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBsc1064_raman_df2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_aerBsc1064_raman_df2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBsc1064_raman_nddf2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_aerBsc1064_raman_nddf2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_aerBsc1064_raman_nd2, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_aerBsc1064_raman_nd2, false, missing_value); 

% extinction fill values
netcdf.defVarFill(ncID_raman, varID_ext_d_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_d_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_d_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_cd_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_cd_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_cd_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_fd_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_fd_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_fd_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_ndm_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_ndm_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_ndm_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_nds_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_nds_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_nds_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_bb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_bb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_bb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_vsf_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_vsf_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_vsf_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_vsa_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_vsa_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_vsa_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_vst_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_vst_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_ext_vst_raman_1064, false, missing_value);

% mass fill values
netcdf.defVarFill(ncID_raman, varID_m_d_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_d_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_d_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_cd_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_cd_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_cd_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_fd_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_fd_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_fd_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_ndm_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_ndm_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_ndm_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_nds_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_nds_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_nds_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_bb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_bb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_bb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_vsf_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_vsf_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_vsf_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_vsa_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_vsa_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_vsa_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_vst_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_vst_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_m_vst_raman_1064, false, missing_value);

% number fill values
netcdf.defVarFill(ncID_raman, varID_n_100_d_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_100_d_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_100_d_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_d_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_d_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_d_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_c_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_c_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_c_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_c_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_c_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_c_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_m_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_m_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_m_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_m_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_m_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_m_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_bb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_bb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_bb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_bb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_bb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_bb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_vsf_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_vsf_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_vsf_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_vsf_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_vsf_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_vsf_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_vsa_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_vsa_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_vsa_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_vsa_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_vsa_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_vsa_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_vst_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_vst_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_50_vst_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_vst_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_vst_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_250_vst_raman_1064, false, missing_value);

% surface area fill values
netcdf.defVarFill(ncID_raman, varID_sa_d_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_d_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_d_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_c_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_c_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_c_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_m_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_m_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_m_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_bb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_bb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_bb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_vsf_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_vsf_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_vsf_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_vsa_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_vsa_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_vsa_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_vst_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_vst_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_sa_vst_raman_1064, false, missing_value);

% error (extinction) fill values
netcdf.defVarFill(ncID_raman, varID_err_ext_d_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_d_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_d_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_cd_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_cd_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_cd_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_fd_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_fd_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_fd_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_ndm_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_ndm_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_ndm_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_nds_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_nds_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_nds_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_bb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_bb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_bb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_vsf_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_vsf_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_vsf_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_vsa_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_vsa_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_vsa_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_vst_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_vst_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_ext_vst_raman_1064, false, missing_value);

% error (mass) fill values
netcdf.defVarFill(ncID_raman, varID_err_m_d_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_d_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_d_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_cd_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_cd_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_cd_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_fd_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_fd_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_fd_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_ndm_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_ndm_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_ndm_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_nds_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_nds_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_nds_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_bb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_bb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_bb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_vsf_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_vsf_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_vsf_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_vsa_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_vsa_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_vsa_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_vst_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_vst_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_err_m_vst_raman_1064, false, missing_value);

% CCN fill values
netcdf.defVarFill(ncID_raman, varID_n_ccn_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_d_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_d_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_d_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_c_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_c_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_c_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_m_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_m_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_m_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_bb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_bb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_bb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_vsf_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_vsf_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_vsf_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_vst_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_vst_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_vst_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_vsa_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_vsa_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_ccn_vsa_raman_1064, false, missing_value);

% INP fill values
netcdf.defVarFill(ncID_raman, varID_n_inp_d_d10_amb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_d10_amb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_d10_amb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_d15_amb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_d15_amb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_d15_amb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_n12_amb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_n12_amb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_n12_amb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_s15_amb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_s15_amb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_s15_amb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_d10_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_d10_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_d10_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_d15_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_d15_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_d15_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_n12_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_n12_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_n12_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_s15_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_s15_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_d_s15_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_c_d10_amb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_c_d10_amb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_c_d10_amb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_c_d10_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_c_d10_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_c_d10_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_m_d10_amb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_m_d10_amb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_m_d10_amb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_m_d10_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_m_d10_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_m_d10_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_bb_d10_amb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_bb_d10_amb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_bb_d10_amb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_bb_d10_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_bb_d10_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_bb_d10_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vsf_d10_amb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vsf_d10_amb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vsf_d10_amb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vsf_d10_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vsf_d10_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vsf_d10_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vsa_d10_amb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vsa_d10_amb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vsa_d10_amb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vsa_d10_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vsa_d10_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vsa_d10_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vst_d10_amb_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vst_d10_amb_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vst_d10_amb_raman_1064, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vst_d10_raman_355, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vst_d10_raman_532, false, missing_value);
netcdf.defVarFill(ncID_raman, varID_n_inp_vst_d10_raman_1064, false, missing_value);


% define the data compression

netcdf.defVarDeflate(ncID_raman, varID_beta_dc_raman, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_beta_dc_klett, true, true, 5);

%% klett
netcdf.defVarDeflate(ncID_klett, varID_aerBsc_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBscStd_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBsc355_klett_d2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_aerBsc355_klett_d2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBsc355_klett_dc2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_aerBsc355_klett_dc2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBsc355_klett_df2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_aerBsc355_klett_df2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBsc355_klett_nddf2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_aerBsc355_klett_nddf2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBsc355_klett_nd2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_aerBsc355_klett_nd2, true, true, 5);

netcdf.defVarDeflate(ncID_klett, varID_aerBsc_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBscStd_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBsc532_klett_d2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_aerBsc532_klett_d2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBsc532_klett_dc2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_aerBsc532_klett_dc2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBsc532_klett_df2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_aerBsc532_klett_df2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBsc532_klett_nddf2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_aerBsc532_klett_nddf2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBsc532_klett_nd2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_aerBsc532_klett_nd2, true, true, 5);

netcdf.defVarDeflate(ncID_klett, varID_aerBsc_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBscStd_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBsc1064_klett_d2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_aerBsc1064_klett_d2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBsc1064_klett_dc2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_aerBsc1064_klett_dc2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBsc1064_klett_df2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_aerBsc1064_klett_df2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBsc1064_klett_nddf2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_aerBsc1064_klett_nddf2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_aerBsc1064_klett_nd2, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_aerBsc1064_klett_nd2, true, true, 5);

% Extinction deflation
netcdf.defVarDeflate(ncID_klett, varID_ext_d_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_d_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_d_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_cd_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_cd_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_cd_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_fd_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_fd_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_fd_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_ndm_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_ndm_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_ndm_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_nds_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_nds_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_nds_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_bb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_bb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_bb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_vsf_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_vsf_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_vsf_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_vsa_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_vsa_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_vsa_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_vst_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_vst_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_ext_vst_klett_1064, true, true, 5);

% Mass deflation
netcdf.defVarDeflate(ncID_klett, varID_m_d_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_d_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_d_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_cd_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_cd_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_cd_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_fd_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_fd_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_fd_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_ndm_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_ndm_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_ndm_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_nds_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_nds_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_nds_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_bb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_bb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_bb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_vsf_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_vsf_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_vsf_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_vsa_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_vsa_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_vsa_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_vst_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_vst_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_m_vst_klett_1064, true, true, 5);

% Number deflation
netcdf.defVarDeflate(ncID_klett, varID_n_100_d_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_100_d_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_100_d_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_d_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_d_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_d_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_c_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_c_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_c_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_c_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_c_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_c_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_m_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_m_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_m_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_m_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_m_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_m_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_bb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_bb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_bb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_bb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_bb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_bb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_vsf_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_vsf_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_vsf_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_vsf_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_vsf_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_vsf_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_vsa_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_vsa_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_vsa_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_vsa_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_vsa_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_vsa_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_vst_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_vst_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_50_vst_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_vst_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_vst_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_250_vst_klett_1064, true, true, 5);

% Surface area deflation
netcdf.defVarDeflate(ncID_klett, varID_sa_d_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_d_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_d_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_c_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_c_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_c_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_m_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_m_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_m_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_bb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_bb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_bb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_vsf_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_vsf_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_vsf_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_vsa_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_vsa_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_vsa_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_vst_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_vst_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_sa_vst_klett_1064, true, true, 5);

% Error (extinction) deflation
netcdf.defVarDeflate(ncID_klett, varID_err_ext_d_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_d_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_d_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_cd_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_cd_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_cd_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_fd_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_fd_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_fd_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_ndm_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_ndm_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_ndm_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_nds_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_nds_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_nds_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_bb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_bb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_bb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_vsf_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_vsf_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_vsf_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_vsa_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_vsa_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_vsa_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_vst_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_vst_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_ext_vst_klett_1064, true, true, 5);

% Error (mass) deflation
netcdf.defVarDeflate(ncID_klett, varID_err_m_d_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_d_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_d_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_cd_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_cd_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_cd_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_fd_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_fd_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_fd_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_ndm_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_ndm_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_ndm_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_nds_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_nds_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_nds_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_bb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_bb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_bb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_vsf_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_vsf_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_vsf_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_vsa_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_vsa_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_vsa_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_vst_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_vst_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_err_m_vst_klett_1064, true, true, 5);

% CCN deflation
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_d_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_d_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_d_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_c_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_c_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_c_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_m_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_m_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_m_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_bb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_bb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_bb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_vsf_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_vsf_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_vsf_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_vst_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_vst_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_vst_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_vsa_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_vsa_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_ccn_vsa_klett_1064, true, true, 5);

% INP deflation
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_d10_amb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_d10_amb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_d10_amb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_d15_amb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_d15_amb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_d15_amb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_n12_amb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_n12_amb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_n12_amb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_s15_amb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_s15_amb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_s15_amb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_d10_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_d10_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_d10_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_d15_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_d15_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_d15_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_n12_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_n12_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_n12_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_s15_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_s15_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_d_s15_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_c_d10_amb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_c_d10_amb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_c_d10_amb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_c_d10_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_c_d10_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_c_d10_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_m_d10_amb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_m_d10_amb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_m_d10_amb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_m_d10_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_m_d10_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_m_d10_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_bb_d10_amb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_bb_d10_amb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_bb_d10_amb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_bb_d10_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_bb_d10_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_bb_d10_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vsf_d10_amb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vsf_d10_amb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vsf_d10_amb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vsf_d10_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vsf_d10_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vsf_d10_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vsa_d10_amb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vsa_d10_amb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vsa_d10_amb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vsa_d10_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vsa_d10_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vsa_d10_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vst_d10_amb_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vst_d10_amb_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vst_d10_amb_klett_1064, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vst_d10_klett_355, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vst_d10_klett_532, true, true, 5);
netcdf.defVarDeflate(ncID_klett, varID_n_inp_vst_d10_klett_1064, true, true, 5);

%% raman
netcdf.defVarDeflate(ncID_raman, varID_aerBsc_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBscStd_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBsc355_raman_d2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_aerBsc355_raman_d2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBsc355_raman_dc2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_aerBsc355_raman_dc2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBsc355_raman_df2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_aerBsc355_raman_df2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBsc355_raman_nddf2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_aerBsc355_raman_nddf2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBsc355_raman_nd2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_aerBsc355_raman_nd2, true, true, 5);

netcdf.defVarDeflate(ncID_raman, varID_aerBsc_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBscStd_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBsc532_raman_d2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_aerBsc532_raman_d2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBsc532_raman_dc2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_aerBsc532_raman_dc2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBsc532_raman_df2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_aerBsc532_raman_df2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBsc532_raman_nddf2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_aerBsc532_raman_nddf2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBsc532_raman_nd2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_aerBsc532_raman_nd2, true, true, 5);

netcdf.defVarDeflate(ncID_raman, varID_aerBsc_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBscStd_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBsc1064_raman_d2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_aerBsc1064_raman_d2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBsc1064_raman_dc2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_aerBsc1064_raman_dc2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBsc1064_raman_df2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_aerBsc1064_raman_df2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBsc1064_raman_nddf2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_aerBsc1064_raman_nddf2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_aerBsc1064_raman_nd2, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_aerBsc1064_raman_nd2, true, true, 5);

% extinction deflation
netcdf.defVarDeflate(ncID_raman, varID_ext_d_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_d_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_d_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_cd_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_cd_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_cd_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_fd_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_fd_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_fd_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_ndm_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_ndm_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_ndm_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_nds_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_nds_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_nds_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_bb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_bb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_bb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_vsf_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_vsf_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_vsf_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_vsa_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_vsa_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_vsa_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_vst_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_vst_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_ext_vst_raman_1064, true, true, 5);

% mass deflation
netcdf.defVarDeflate(ncID_raman, varID_m_d_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_d_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_d_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_cd_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_cd_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_cd_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_fd_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_fd_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_fd_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_ndm_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_ndm_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_ndm_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_nds_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_nds_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_nds_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_bb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_bb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_bb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_vsf_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_vsf_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_vsf_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_vsa_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_vsa_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_vsa_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_vst_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_vst_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_m_vst_raman_1064, true, true, 5);

% number deflation
netcdf.defVarDeflate(ncID_raman, varID_n_100_d_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_100_d_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_100_d_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_d_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_d_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_d_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_c_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_c_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_c_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_c_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_c_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_c_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_m_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_m_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_m_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_m_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_m_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_m_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_bb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_bb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_bb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_bb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_bb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_bb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_vsf_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_vsf_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_vsf_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_vsf_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_vsf_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_vsf_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_vsa_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_vsa_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_vsa_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_vsa_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_vsa_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_vsa_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_vst_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_vst_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_50_vst_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_vst_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_vst_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_250_vst_raman_1064, true, true, 5);

% eurface area deflation
netcdf.defVarDeflate(ncID_raman, varID_sa_d_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_d_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_d_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_c_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_c_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_c_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_m_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_m_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_m_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_bb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_bb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_bb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_vsf_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_vsf_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_vsf_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_vsa_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_vsa_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_vsa_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_vst_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_vst_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_sa_vst_raman_1064, true, true, 5);

% error 
% extinction deflation
netcdf.defVarDeflate(ncID_raman, varID_err_ext_d_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_d_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_d_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_cd_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_cd_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_cd_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_fd_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_fd_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_fd_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_ndm_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_ndm_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_ndm_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_nds_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_nds_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_nds_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_bb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_bb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_bb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_vsf_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_vsf_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_vsf_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_vsa_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_vsa_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_vsa_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_vst_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_vst_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_ext_vst_raman_1064, true, true, 5);

% mass deflation 
netcdf.defVarDeflate(ncID_raman, varID_err_m_d_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_d_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_d_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_cd_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_cd_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_cd_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_fd_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_fd_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_fd_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_ndm_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_ndm_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_ndm_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_nds_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_nds_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_nds_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_bb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_bb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_bb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_vsf_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_vsf_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_vsf_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_vsa_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_vsa_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_vsa_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_vst_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_vst_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_err_m_vst_raman_1064, true, true, 5);

% CCN deflation
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_d_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_d_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_d_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_c_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_c_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_c_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_m_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_m_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_m_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_bb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_bb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_bb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_vsf_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_vsf_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_vsf_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_vst_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_vst_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_vst_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_vsa_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_vsa_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_ccn_vsa_raman_1064, true, true, 5);

% INP deflation
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_d10_amb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_d10_amb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_d10_amb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_d15_amb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_d15_amb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_d15_amb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_n12_amb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_n12_amb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_n12_amb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_s15_amb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_s15_amb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_s15_amb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_d10_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_d10_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_d10_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_d15_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_d15_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_d15_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_n12_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_n12_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_n12_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_s15_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_s15_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_d_s15_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_c_d10_amb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_c_d10_amb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_c_d10_amb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_c_d10_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_c_d10_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_c_d10_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_m_d10_amb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_m_d10_amb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_m_d10_amb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_m_d10_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_m_d10_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_m_d10_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_bb_d10_amb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_bb_d10_amb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_bb_d10_amb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_bb_d10_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_bb_d10_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_bb_d10_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vsf_d10_amb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vsf_d10_amb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vsf_d10_amb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vsf_d10_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vsf_d10_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vsf_d10_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vsa_d10_amb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vsa_d10_amb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vsa_d10_amb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vsa_d10_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vsa_d10_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vsa_d10_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vst_d10_amb_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vst_d10_amb_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vst_d10_amb_raman_1064, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vst_d10_raman_355, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vst_d10_raman_532, true, true, 5);
netcdf.defVarDeflate(ncID_raman, varID_n_inp_vst_d10_raman_1064, true, true, 5);

% leave define mode
netcdf.endDef(ncID_raman);
netcdf.endDef(ncID_klett);

% write data to .nc file
netcdf.putVar(ncID_raman, varID_altitude_raman, single(data.alt0));
netcdf.putVar(ncID_raman, varID_longitude_raman, single(data.lon));
netcdf.putVar(ncID_raman, varID_latitude_raman, single(data.lat));
netcdf.putVar(ncID_raman, varID_startTime_raman, datenum_2_unix_timestamp(startTime));
netcdf.putVar(ncID_raman, varID_endTime_raman, datenum_2_unix_timestamp(endTime));
netcdf.putVar(ncID_raman, varID_height_raman, single(data.height));
netcdf.putVar(ncID_raman, varID_time_raman, datenum_2_unix_timestamp(data.mTime));

netcdf.putVar(ncID_klett, varID_altitude_klett, single(data.alt0));
netcdf.putVar(ncID_klett, varID_longitude_klett, single(data.lon));
netcdf.putVar(ncID_klett, varID_latitude_klett, single(data.lat));
netcdf.putVar(ncID_klett, varID_startTime_klett, datenum_2_unix_timestamp(startTime));
netcdf.putVar(ncID_klett, varID_endTime_klett, datenum_2_unix_timestamp(endTime));
netcdf.putVar(ncID_klett, varID_height_klett, single(data.height));
netcdf.putVar(ncID_klett, varID_time_klett, datenum_2_unix_timestamp(data.mTime));

%% raman
netcdf.putVar(ncID_raman, varID_aerBsc_raman_355, single(fillmissing(data.aerBsc355_raman(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_aerBscStd_raman_355, single(fillmissing(data.aerBscStd355_raman(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_aerBsc355_raman_d2, single(fillmissing(POLIPHON2.aerBsc355_raman_d2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_err_aerBsc355_raman_d2, single(fillmissing(POLIPHON2.err_aerBsc355_raman_d2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_aerBsc355_raman_dc2, single(fillmissing(POLIPHON2.aerBsc355_raman_dc2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_err_aerBsc355_raman_dc2, single(fillmissing(POLIPHON2.err_aerBsc355_raman_dc2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_aerBsc355_raman_df2, single(fillmissing(POLIPHON2.aerBsc355_raman_df2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_err_aerBsc355_raman_df2, single(fillmissing(POLIPHON2.err_aerBsc355_raman_df2(iGrp, :), missing_value)));
%netcdf.putVar(ncID_raman, varID_aerBsc355_raman_nddf2, single(fillmissing(POLIPHON2.aerBsc355_raman_nddf2(iGrp, :), missing_value)));
%netcdf.putVar(ncID_raman, varID_err_aerBsc355_raman_nddf2, single(fillmissing(POLIPHON2.err_aerBsc355_raman_nddf2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_aerBsc355_raman_nd2, single(fillmissing(POLIPHON2.aerBsc355_raman_nd2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_err_aerBsc355_raman_nd2, single(fillmissing(POLIPHON2.err_aerBsc355_raman_nd2(iGrp, :), missing_value)));

netcdf.putVar(ncID_raman, varID_aerBsc_raman_532, single(fillmissing(data.aerBsc532_raman(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_aerBscStd_raman_532, single(fillmissing(data.aerBscStd532_raman(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_aerBsc532_raman_d2, single(fillmissing(POLIPHON2.aerBsc532_raman_d2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_err_aerBsc532_raman_d2, single(fillmissing(POLIPHON2.err_aerBsc532_raman_d2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_aerBsc532_raman_dc2, single(fillmissing(POLIPHON2.aerBsc532_raman_dc2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_err_aerBsc532_raman_dc2, single(fillmissing(POLIPHON2.err_aerBsc532_raman_dc2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_aerBsc532_raman_df2, single(fillmissing(POLIPHON2.aerBsc532_raman_df2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_err_aerBsc532_raman_df2, single(fillmissing(POLIPHON2.err_aerBsc532_raman_df2(iGrp, :), missing_value)));
%netcdf.putVar(ncID_raman, varID_aerBsc532_raman_nddf2, single(fillmissing(POLIPHON2.aerBsc532_raman_nddf2(iGrp, :), missing_value)));
%netcdf.putVar(ncID_raman, varID_err_aerBsc532_raman_nddf2, single(fillmissing(POLIPHON2.err_aerBsc532_raman_nddf2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_aerBsc532_raman_nd2, single(fillmissing(POLIPHON2.aerBsc532_raman_nd2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_err_aerBsc532_raman_nd2, single(fillmissing(POLIPHON2.err_aerBsc532_raman_nd2(iGrp, :), missing_value)));

netcdf.putVar(ncID_raman, varID_aerBsc_raman_1064, single(fillmissing(data.aerBsc1064_raman(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_aerBscStd_raman_1064, single(fillmissing(data.aerBscStd1064_raman(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_aerBsc1064_raman_d2, single(fillmissing(POLIPHON2.aerBsc1064_raman_d2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_err_aerBsc1064_raman_d2, single(fillmissing(POLIPHON2.err_aerBsc1064_raman_d2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_aerBsc1064_raman_dc2, single(fillmissing(POLIPHON2.aerBsc1064_raman_dc2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_err_aerBsc1064_raman_dc2, single(fillmissing(POLIPHON2.err_aerBsc1064_raman_dc2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_aerBsc1064_raman_df2, single(fillmissing(POLIPHON2.aerBsc1064_raman_df2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_err_aerBsc1064_raman_df2, single(fillmissing(POLIPHON2.err_aerBsc1064_raman_df2(iGrp, :), missing_value)));
%netcdf.putVar(ncID_raman, varID_aerBsc1064_raman_nddf2, single(fillmissing(POLIPHON2.aerBsc1064_raman_nddf2(iGrp, :), missing_value)));
%netcdf.putVar(ncID_raman, varID_err_aerBsc1064_raman_nddf2, single(fillmissing(POLIPHON2.err_aerBsc1064_raman_nddf2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_aerBsc1064_raman_nd2, single(fillmissing(POLIPHON2.aerBsc1064_raman_nd2(iGrp, :), missing_value)));
netcdf.putVar(ncID_raman, varID_err_aerBsc1064_raman_nd2, single(fillmissing(POLIPHON2.err_aerBsc1064_raman_nd2(iGrp, :), missing_value)));

% extinction coeffs
netcdf.putVar(ncID_raman, varID_ext_d_raman_355, single(fillmissing(POLIPHON2.ext_d_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_d_raman_532, single(fillmissing(POLIPHON2.ext_d_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_d_raman_1064, single(fillmissing(POLIPHON2.ext_d_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_cd_raman_355, single(fillmissing(POLIPHON2.ext_cd_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_cd_raman_532, single(fillmissing(POLIPHON2.ext_cd_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_cd_raman_1064, single(fillmissing(POLIPHON2.ext_cd_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_fd_raman_355, single(fillmissing(POLIPHON2.ext_fd_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_fd_raman_532, single(fillmissing(POLIPHON2.ext_fd_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_fd_raman_1064, single(fillmissing(POLIPHON2.ext_fd_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_ndm_raman_355, single(fillmissing(POLIPHON2.ext_ndm_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_ndm_raman_532, single(fillmissing(POLIPHON2.ext_ndm_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_ndm_raman_1064, single(fillmissing(POLIPHON2.ext_ndm_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_nds_raman_355, single(fillmissing(POLIPHON2.ext_nds_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_nds_raman_532, single(fillmissing(POLIPHON2.ext_nds_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_nds_raman_1064, single(fillmissing(POLIPHON2.ext_nds_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_bb_raman_355, single(fillmissing(POLIPHON2.ext_bb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_bb_raman_532, single(fillmissing(POLIPHON2.ext_bb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_bb_raman_1064, single(fillmissing(POLIPHON2.ext_bb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_vsf_raman_355, single(fillmissing(POLIPHON2.ext_vsf_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_vsf_raman_532, single(fillmissing(POLIPHON2.ext_vsf_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_vsf_raman_1064, single(fillmissing(POLIPHON2.ext_vsf_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_vsa_raman_355, single(fillmissing(POLIPHON2.ext_vsa_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_vsa_raman_532, single(fillmissing(POLIPHON2.ext_vsa_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_vsa_raman_1064, single(fillmissing(POLIPHON2.ext_vsa_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_vst_raman_355, single(fillmissing(POLIPHON2.ext_vst_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_vst_raman_532, single(fillmissing(POLIPHON2.ext_vst_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_ext_vst_raman_1064, single(fillmissing(POLIPHON2.ext_vst_raman_1064(:, 1), missing_value)));

% mass concentrations
netcdf.putVar(ncID_raman, varID_m_d_raman_355, single(fillmissing(POLIPHON2.m_d_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_d_raman_532, single(fillmissing(POLIPHON2.m_d_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_d_raman_1064, single(fillmissing(POLIPHON2.m_d_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_cd_raman_355, single(fillmissing(POLIPHON2.m_cd_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_cd_raman_532, single(fillmissing(POLIPHON2.m_cd_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_cd_raman_1064, single(fillmissing(POLIPHON2.m_cd_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_fd_raman_355, single(fillmissing(POLIPHON2.m_fd_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_fd_raman_532, single(fillmissing(POLIPHON2.m_fd_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_fd_raman_1064, single(fillmissing(POLIPHON2.m_fd_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_ndm_raman_355, single(fillmissing(POLIPHON2.m_ndm_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_ndm_raman_532, single(fillmissing(POLIPHON2.m_ndm_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_ndm_raman_1064, single(fillmissing(POLIPHON2.m_ndm_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_nds_raman_355, single(fillmissing(POLIPHON2.m_nds_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_nds_raman_532, single(fillmissing(POLIPHON2.m_nds_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_nds_raman_1064, single(fillmissing(POLIPHON2.m_nds_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_bb_raman_355, single(fillmissing(POLIPHON2.m_bb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_bb_raman_532, single(fillmissing(POLIPHON2.m_bb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_bb_raman_1064, single(fillmissing(POLIPHON2.m_bb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_vsf_raman_355, single(fillmissing(POLIPHON2.m_vsf_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_vsf_raman_532, single(fillmissing(POLIPHON2.m_vsf_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_vsf_raman_1064, single(fillmissing(POLIPHON2.m_vsf_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_vsa_raman_355, single(fillmissing(POLIPHON2.m_vsa_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_vsa_raman_532, single(fillmissing(POLIPHON2.m_vsa_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_vsa_raman_1064, single(fillmissing(POLIPHON2.m_vsa_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_vst_raman_355, single(fillmissing(POLIPHON2.m_vst_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_vst_raman_532, single(fillmissing(POLIPHON2.m_vst_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_m_vst_raman_1064, single(fillmissing(POLIPHON2.m_vst_raman_1064(:, 1), missing_value)));

% number concentrations
netcdf.putVar(ncID_raman, varID_n_100_d_raman_355, single(fillmissing(POLIPHON2.n_100_d_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_100_d_raman_532, single(fillmissing(POLIPHON2.n_100_d_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_100_d_raman_1064, single(fillmissing(POLIPHON2.n_100_d_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_d_raman_355, single(fillmissing(POLIPHON2.n_250_d_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_d_raman_532, single(fillmissing(POLIPHON2.n_250_d_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_d_raman_1064, single(fillmissing(POLIPHON2.n_250_d_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_c_raman_355, single(fillmissing(POLIPHON2.n_50_c_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_c_raman_532, single(fillmissing(POLIPHON2.n_50_c_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_c_raman_1064, single(fillmissing(POLIPHON2.n_50_c_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_c_raman_355, single(fillmissing(POLIPHON2.n_250_c_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_c_raman_532, single(fillmissing(POLIPHON2.n_250_c_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_c_raman_1064, single(fillmissing(POLIPHON2.n_250_c_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_m_raman_355, single(fillmissing(POLIPHON2.n_50_m_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_m_raman_532, single(fillmissing(POLIPHON2.n_50_m_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_m_raman_1064, single(fillmissing(POLIPHON2.n_50_m_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_m_raman_355, single(fillmissing(POLIPHON2.n_250_m_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_m_raman_532, single(fillmissing(POLIPHON2.n_250_m_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_m_raman_1064, single(fillmissing(POLIPHON2.n_250_m_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_bb_raman_355, single(fillmissing(POLIPHON2.n_50_bb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_bb_raman_532, single(fillmissing(POLIPHON2.n_50_bb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_bb_raman_1064, single(fillmissing(POLIPHON2.n_50_bb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_bb_raman_355, single(fillmissing(POLIPHON2.n_250_bb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_bb_raman_532, single(fillmissing(POLIPHON2.n_250_bb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_bb_raman_1064, single(fillmissing(POLIPHON2.n_250_bb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_vsf_raman_355, single(fillmissing(POLIPHON2.n_50_vsf_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_vsf_raman_532, single(fillmissing(POLIPHON2.n_50_vsf_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_vsf_raman_1064, single(fillmissing(POLIPHON2.n_50_vsf_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_vsf_raman_355, single(fillmissing(POLIPHON2.n_250_vsf_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_vsf_raman_532, single(fillmissing(POLIPHON2.n_250_vsf_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_vsf_raman_1064, single(fillmissing(POLIPHON2.n_250_vsf_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_vsa_raman_355, single(fillmissing(POLIPHON2.n_50_vsa_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_vsa_raman_532, single(fillmissing(POLIPHON2.n_50_vsa_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_vsa_raman_1064, single(fillmissing(POLIPHON2.n_50_vsa_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_vsa_raman_355, single(fillmissing(POLIPHON2.n_250_vsa_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_vsa_raman_532, single(fillmissing(POLIPHON2.n_250_vsa_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_vsa_raman_1064, single(fillmissing(POLIPHON2.n_250_vsa_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_vst_raman_355, single(fillmissing(POLIPHON2.n_50_vst_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_vst_raman_532, single(fillmissing(POLIPHON2.n_50_vst_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_50_vst_raman_1064, single(fillmissing(POLIPHON2.n_50_vst_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_vst_raman_355, single(fillmissing(POLIPHON2.n_250_vst_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_vst_raman_532, single(fillmissing(POLIPHON2.n_250_vst_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_250_vst_raman_1064, single(fillmissing(POLIPHON2.n_250_vst_raman_1064(:, 1), missing_value)));

% surface area concentrations
netcdf.putVar(ncID_raman, varID_sa_d_raman_355, single(fillmissing(POLIPHON2.sa_d_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_d_raman_532, single(fillmissing(POLIPHON2.sa_d_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_d_raman_1064, single(fillmissing(POLIPHON2.sa_d_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_c_raman_355, single(fillmissing(POLIPHON2.sa_c_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_c_raman_532, single(fillmissing(POLIPHON2.sa_c_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_c_raman_1064, single(fillmissing(POLIPHON2.sa_c_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_m_raman_355, single(fillmissing(POLIPHON2.sa_m_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_m_raman_532, single(fillmissing(POLIPHON2.sa_m_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_m_raman_1064, single(fillmissing(POLIPHON2.sa_m_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_bb_raman_355, single(fillmissing(POLIPHON2.sa_bb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_bb_raman_532, single(fillmissing(POLIPHON2.sa_bb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_bb_raman_1064, single(fillmissing(POLIPHON2.sa_bb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_vsf_raman_355, single(fillmissing(POLIPHON2.sa_vsf_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_vsf_raman_532, single(fillmissing(POLIPHON2.sa_vsf_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_vsf_raman_1064, single(fillmissing(POLIPHON2.sa_vsf_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_vsa_raman_355, single(fillmissing(POLIPHON2.sa_vsa_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_vsa_raman_532, single(fillmissing(POLIPHON2.sa_vsa_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_vsa_raman_1064, single(fillmissing(POLIPHON2.sa_vsa_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_vst_raman_355, single(fillmissing(POLIPHON2.sa_vst_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_vst_raman_532, single(fillmissing(POLIPHON2.sa_vst_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_sa_vst_raman_1064, single(fillmissing(POLIPHON2.sa_vst_raman_1064(:, 1), missing_value)));

% errors extinction
netcdf.putVar(ncID_raman, varID_err_ext_d_raman_355, single(fillmissing(POLIPHON2.err_ext_d_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_d_raman_532, single(fillmissing(POLIPHON2.err_ext_d_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_d_raman_1064, single(fillmissing(POLIPHON2.err_ext_d_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_cd_raman_355, single(fillmissing(POLIPHON2.err_ext_cd_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_cd_raman_532, single(fillmissing(POLIPHON2.err_ext_cd_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_cd_raman_1064, single(fillmissing(POLIPHON2.err_ext_cd_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_fd_raman_355, single(fillmissing(POLIPHON2.err_ext_fd_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_fd_raman_532, single(fillmissing(POLIPHON2.err_ext_fd_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_fd_raman_1064, single(fillmissing(POLIPHON2.err_ext_fd_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_ndm_raman_355, single(fillmissing(POLIPHON2.err_ext_ndm_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_ndm_raman_532, single(fillmissing(POLIPHON2.err_ext_ndm_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_ndm_raman_1064, single(fillmissing(POLIPHON2.err_ext_ndm_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_nds_raman_355, single(fillmissing(POLIPHON2.err_ext_nds_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_nds_raman_532, single(fillmissing(POLIPHON2.err_ext_nds_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_nds_raman_1064, single(fillmissing(POLIPHON2.err_ext_nds_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_bb_raman_355, single(fillmissing(POLIPHON2.err_ext_bb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_bb_raman_532, single(fillmissing(POLIPHON2.err_ext_bb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_bb_raman_1064, single(fillmissing(POLIPHON2.err_ext_bb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_vsf_raman_355, single(fillmissing(POLIPHON2.err_ext_vsf_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_vsf_raman_532, single(fillmissing(POLIPHON2.err_ext_vsf_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_vsf_raman_1064, single(fillmissing(POLIPHON2.err_ext_vsf_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_vsa_raman_355, single(fillmissing(POLIPHON2.err_ext_vsa_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_vsa_raman_532, single(fillmissing(POLIPHON2.err_ext_vsa_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_vsa_raman_1064, single(fillmissing(POLIPHON2.err_ext_vsa_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_vst_raman_355, single(fillmissing(POLIPHON2.err_ext_vst_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_vst_raman_532, single(fillmissing(POLIPHON2.err_ext_vst_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_ext_vst_raman_1064, single(fillmissing(POLIPHON2.err_ext_vst_raman_1064(:, 1), missing_value)));

% errors mass
netcdf.putVar(ncID_raman, varID_err_m_d_raman_355, single(fillmissing(POLIPHON2.err_m_d_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_d_raman_532, single(fillmissing(POLIPHON2.err_m_d_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_d_raman_1064, single(fillmissing(POLIPHON2.err_m_d_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_cd_raman_355, single(fillmissing(POLIPHON2.err_m_cd_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_cd_raman_532, single(fillmissing(POLIPHON2.err_m_cd_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_cd_raman_1064, single(fillmissing(POLIPHON2.err_m_cd_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_fd_raman_355, single(fillmissing(POLIPHON2.err_m_fd_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_fd_raman_532, single(fillmissing(POLIPHON2.err_m_fd_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_fd_raman_1064, single(fillmissing(POLIPHON2.err_m_fd_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_ndm_raman_355, single(fillmissing(POLIPHON2.err_m_ndm_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_ndm_raman_532, single(fillmissing(POLIPHON2.err_m_ndm_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_ndm_raman_1064, single(fillmissing(POLIPHON2.err_m_ndm_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_nds_raman_355, single(fillmissing(POLIPHON2.err_m_nds_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_nds_raman_532, single(fillmissing(POLIPHON2.err_m_nds_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_nds_raman_1064, single(fillmissing(POLIPHON2.err_m_nds_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_bb_raman_355, single(fillmissing(POLIPHON2.err_m_bb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_bb_raman_532, single(fillmissing(POLIPHON2.err_m_bb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_bb_raman_1064, single(fillmissing(POLIPHON2.err_m_bb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_vsf_raman_355, single(fillmissing(POLIPHON2.err_m_vsf_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_vsf_raman_532, single(fillmissing(POLIPHON2.err_m_vsf_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_vsf_raman_1064, single(fillmissing(POLIPHON2.err_m_vsf_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_vsa_raman_355, single(fillmissing(POLIPHON2.err_m_vsa_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_vsa_raman_532, single(fillmissing(POLIPHON2.err_m_vsa_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_vsa_raman_1064, single(fillmissing(POLIPHON2.err_m_vsa_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_vst_raman_355, single(fillmissing(POLIPHON2.err_m_vst_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_vst_raman_532, single(fillmissing(POLIPHON2.err_m_vst_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_err_m_vst_raman_1064, single(fillmissing(POLIPHON2.err_m_vst_raman_1064(:, 1), missing_value)));

% ccn
netcdf.putVar(ncID_raman, varID_n_ccn_raman_355, single(fillmissing(POLIPHON2.n_ccn_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_raman_532, single(fillmissing(POLIPHON2.n_ccn_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_raman_1064, single(fillmissing(POLIPHON2.n_ccn_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_d_raman_355, single(fillmissing(POLIPHON2.n_ccn_d_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_d_raman_532, single(fillmissing(POLIPHON2.n_ccn_d_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_d_raman_1064, single(fillmissing(POLIPHON2.n_ccn_d_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_c_raman_355, single(fillmissing(POLIPHON2.n_ccn_c_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_c_raman_532, single(fillmissing(POLIPHON2.n_ccn_c_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_c_raman_1064, single(fillmissing(POLIPHON2.n_ccn_c_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_m_raman_355, single(fillmissing(POLIPHON2.n_ccn_m_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_m_raman_532, single(fillmissing(POLIPHON2.n_ccn_m_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_m_raman_1064, single(fillmissing(POLIPHON2.n_ccn_m_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_bb_raman_355, single(fillmissing(POLIPHON2.n_ccn_bb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_bb_raman_532, single(fillmissing(POLIPHON2.n_ccn_bb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_bb_raman_1064, single(fillmissing(POLIPHON2.n_ccn_bb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_vsf_raman_355, single(fillmissing(POLIPHON2.n_ccn_vsf_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_vsf_raman_532, single(fillmissing(POLIPHON2.n_ccn_vsf_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_vsf_raman_1064, single(fillmissing(POLIPHON2.n_ccn_vsf_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_vst_raman_355, single(fillmissing(POLIPHON2.n_ccn_vst_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_vst_raman_532, single(fillmissing(POLIPHON2.n_ccn_vst_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_vst_raman_1064, single(fillmissing(POLIPHON2.n_ccn_vst_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_vsa_raman_355, single(fillmissing(POLIPHON2.n_ccn_vsa_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_vsa_raman_532, single(fillmissing(POLIPHON2.n_ccn_vsa_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_ccn_vsa_raman_1064, single(fillmissing(POLIPHON2.n_ccn_vsa_raman_1064(:, 1), missing_value)));

% inp
netcdf.putVar(ncID_raman, varID_n_inp_d_d10_amb_raman_355, single(fillmissing(POLIPHON2.n_inp_d_d10_amb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_d10_amb_raman_532, single(fillmissing(POLIPHON2.n_inp_d_d10_amb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_d10_amb_raman_1064, single(fillmissing(POLIPHON2.n_inp_d_d10_amb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_d15_amb_raman_355, single(fillmissing(POLIPHON2.n_inp_d_d15_amb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_d15_amb_raman_532, single(fillmissing(POLIPHON2.n_inp_d_d15_amb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_d15_amb_raman_1064, single(fillmissing(POLIPHON2.n_inp_d_d15_amb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_n12_amb_raman_355, single(fillmissing(POLIPHON2.n_inp_d_n12_amb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_n12_amb_raman_532, single(fillmissing(POLIPHON2.n_inp_d_n12_amb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_n12_amb_raman_1064, single(fillmissing(POLIPHON2.n_inp_d_n12_amb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_s15_amb_raman_355, single(fillmissing(POLIPHON2.n_inp_d_s15_amb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_s15_amb_raman_532, single(fillmissing(POLIPHON2.n_inp_d_s15_amb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_s15_amb_raman_1064, single(fillmissing(POLIPHON2.n_inp_d_s15_amb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_d10_raman_355, single(fillmissing(POLIPHON2.n_inp_d_d10_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_d10_raman_532, single(fillmissing(POLIPHON2.n_inp_d_d10_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_d10_raman_1064, single(fillmissing(POLIPHON2.n_inp_d_d10_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_d15_raman_355, single(fillmissing(POLIPHON2.n_inp_d_d15_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_d15_raman_532, single(fillmissing(POLIPHON2.n_inp_d_d15_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_d15_raman_1064, single(fillmissing(POLIPHON2.n_inp_d_d15_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_n12_raman_355, single(fillmissing(POLIPHON2.n_inp_d_n12_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_n12_raman_532, single(fillmissing(POLIPHON2.n_inp_d_n12_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_n12_raman_1064, single(fillmissing(POLIPHON2.n_inp_d_n12_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_s15_raman_355, single(fillmissing(POLIPHON2.n_inp_d_s15_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_s15_raman_532, single(fillmissing(POLIPHON2.n_inp_d_s15_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_d_s15_raman_1064, single(fillmissing(POLIPHON2.n_inp_d_s15_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_c_d10_amb_raman_355, single(fillmissing(POLIPHON2.n_inp_c_d10_amb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_c_d10_amb_raman_532, single(fillmissing(POLIPHON2.n_inp_c_d10_amb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_c_d10_amb_raman_1064, single(fillmissing(POLIPHON2.n_inp_c_d10_amb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_c_d10_raman_355, single(fillmissing(POLIPHON2.n_inp_c_d10_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_c_d10_raman_532, single(fillmissing(POLIPHON2.n_inp_c_d10_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_c_d10_raman_1064, single(fillmissing(POLIPHON2.n_inp_c_d10_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_m_d10_amb_raman_355, single(fillmissing(POLIPHON2.n_inp_m_d10_amb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_m_d10_amb_raman_532, single(fillmissing(POLIPHON2.n_inp_m_d10_amb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_m_d10_amb_raman_1064, single(fillmissing(POLIPHON2.n_inp_m_d10_amb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_m_d10_raman_355, single(fillmissing(POLIPHON2.n_inp_m_d10_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_m_d10_raman_532, single(fillmissing(POLIPHON2.n_inp_m_d10_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_m_d10_raman_1064, single(fillmissing(POLIPHON2.n_inp_m_d10_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_bb_d10_amb_raman_355, single(fillmissing(POLIPHON2.n_inp_bb_d10_amb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_bb_d10_amb_raman_532, single(fillmissing(POLIPHON2.n_inp_bb_d10_amb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_bb_d10_amb_raman_1064, single(fillmissing(POLIPHON2.n_inp_bb_d10_amb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_bb_d10_raman_355, single(fillmissing(POLIPHON2.n_inp_bb_d10_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_bb_d10_raman_532, single(fillmissing(POLIPHON2.n_inp_bb_d10_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_bb_d10_raman_1064, single(fillmissing(POLIPHON2.n_inp_bb_d10_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vsf_d10_amb_raman_355, single(fillmissing(POLIPHON2.n_inp_vsf_d10_amb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vsf_d10_amb_raman_532, single(fillmissing(POLIPHON2.n_inp_vsf_d10_amb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vsf_d10_amb_raman_1064, single(fillmissing(POLIPHON2.n_inp_vsf_d10_amb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vsf_d10_raman_355, single(fillmissing(POLIPHON2.n_inp_vsf_d10_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vsf_d10_raman_532, single(fillmissing(POLIPHON2.n_inp_vsf_d10_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vsf_d10_raman_1064, single(fillmissing(POLIPHON2.n_inp_vsf_d10_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vsa_d10_amb_raman_355, single(fillmissing(POLIPHON2.n_inp_vsa_d10_amb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vsa_d10_amb_raman_532, single(fillmissing(POLIPHON2.n_inp_vsa_d10_amb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vsa_d10_amb_raman_1064, single(fillmissing(POLIPHON2.n_inp_vsa_d10_amb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vsa_d10_raman_355, single(fillmissing(POLIPHON2.n_inp_vsa_d10_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vsa_d10_raman_532, single(fillmissing(POLIPHON2.n_inp_vsa_d10_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vsa_d10_raman_1064, single(fillmissing(POLIPHON2.n_inp_vsa_d10_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vst_d10_amb_raman_355, single(fillmissing(POLIPHON2.n_inp_vst_d10_amb_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vst_d10_amb_raman_532, single(fillmissing(POLIPHON2.n_inp_vst_d10_amb_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vst_d10_amb_raman_1064, single(fillmissing(POLIPHON2.n_inp_vst_d10_amb_raman_1064(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vst_d10_raman_355, single(fillmissing(POLIPHON2.n_inp_vst_d10_raman_355(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vst_d10_raman_532, single(fillmissing(POLIPHON2.n_inp_vst_d10_raman_532(:, 1), missing_value)));
netcdf.putVar(ncID_raman, varID_n_inp_vst_d10_raman_1064, single(fillmissing(POLIPHON2.n_inp_vst_d10_raman_1064(:, 1), missing_value)));



%% klett
netcdf.putVar(ncID_klett, varID_aerBsc_klett_355, single(fillmissing(data.aerBsc355_klett(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_aerBscStd_klett_355, single(fillmissing(data.aerBscStd355_klett(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_aerBsc355_klett_d2, single(fillmissing(POLIPHON2.aerBsc355_klett_d2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_err_aerBsc355_klett_d2, single(fillmissing(POLIPHON2.err_aerBsc355_klett_d2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_aerBsc355_klett_dc2, single(fillmissing(POLIPHON2.aerBsc355_klett_dc2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_err_aerBsc355_klett_dc2, single(fillmissing(POLIPHON2.err_aerBsc355_klett_dc2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_aerBsc355_klett_df2, single(fillmissing(POLIPHON2.aerBsc355_klett_df2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_err_aerBsc355_klett_df2, single(fillmissing(POLIPHON2.err_aerBsc355_klett_df2(iGrp, :), missing_value)));
%netcdf.putVar(ncID_klett, varID_aerBsc355_klett_nddf2, single(fillmissing(POLIPHON2.aerBsc355_klett_nddf2(iGrp, :), missing_value)));
%netcdf.putVar(ncID_klett, varID_err_aerBsc355_klett_nddf2, single(fillmissing(POLIPHON2.err_aerBsc355_klett_nddf2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_aerBsc355_klett_nd2, single(fillmissing(POLIPHON2.aerBsc355_klett_nd2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_err_aerBsc355_klett_nd2, single(fillmissing(POLIPHON2.err_aerBsc355_klett_nd2(iGrp, :), missing_value)));

netcdf.putVar(ncID_klett, varID_aerBsc_klett_532, single(fillmissing(data.aerBsc532_klett(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_aerBscStd_klett_532, single(fillmissing(data.aerBscStd532_klett(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_aerBsc532_klett_d2, single(fillmissing(POLIPHON2.aerBsc532_klett_d2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_err_aerBsc532_klett_d2, single(fillmissing(POLIPHON2.err_aerBsc532_klett_d2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_aerBsc532_klett_dc2, single(fillmissing(POLIPHON2.aerBsc532_klett_dc2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_err_aerBsc532_klett_dc2, single(fillmissing(POLIPHON2.err_aerBsc532_klett_dc2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_aerBsc532_klett_df2, single(fillmissing(POLIPHON2.aerBsc532_klett_df2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_err_aerBsc532_klett_df2, single(fillmissing(POLIPHON2.err_aerBsc532_klett_df2(iGrp, :), missing_value)));
%netcdf.putVar(ncID_klett, varID_aerBsc532_klett_nddf2, single(fillmissing(POLIPHON2.aerBsc532_klett_nddf2(iGrp, :), missing_value)));
%netcdf.putVar(ncID_klett, varID_err_aerBsc532_klett_nddf2, single(fillmissing(POLIPHON2.err_aerBsc532_klett_nddf2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_aerBsc532_klett_nd2, single(fillmissing(POLIPHON2.aerBsc532_klett_nd2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_err_aerBsc532_klett_nd2, single(fillmissing(POLIPHON2.err_aerBsc532_klett_nd2(iGrp, :), missing_value)));

netcdf.putVar(ncID_klett, varID_aerBsc_klett_1064, single(fillmissing(data.aerBsc1064_klett(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_aerBscStd_klett_1064, single(fillmissing(data.aerBscStd1064_klett(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_aerBsc1064_klett_d2, single(fillmissing(POLIPHON2.aerBsc1064_klett_d2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_err_aerBsc1064_klett_d2, single(fillmissing(POLIPHON2.err_aerBsc1064_klett_d2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_aerBsc1064_klett_dc2, single(fillmissing(POLIPHON2.aerBsc1064_klett_dc2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_err_aerBsc1064_klett_dc2, single(fillmissing(POLIPHON2.err_aerBsc1064_klett_dc2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_aerBsc1064_klett_df2, single(fillmissing(POLIPHON2.aerBsc1064_klett_df2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_err_aerBsc1064_klett_df2, single(fillmissing(POLIPHON2.err_aerBsc1064_klett_df2(iGrp, :), missing_value)));
%netcdf.putVar(ncID_klett, varID_aerBsc1064_klett_nddf2, single(fillmissing(POLIPHON2.aerBsc1064_klett_nddf2(iGrp, :), missing_value)));
%netcdf.putVar(ncID_klett, varID_err_aerBsc1064_klett_nddf2, single(fillmissing(POLIPHON2.err_aerBsc1064_klett_nddf2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_aerBsc1064_klett_nd2, single(fillmissing(POLIPHON2.aerBsc1064_klett_nd2(iGrp, :), missing_value)));
netcdf.putVar(ncID_klett, varID_err_aerBsc1064_klett_nd2, single(fillmissing(POLIPHON2.err_aerBsc1064_klett_nd2(iGrp, :), missing_value)));

% extinction coeffs
netcdf.putVar(ncID_klett, varID_ext_d_klett_355, single(fillmissing(POLIPHON2.ext_d_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_d_klett_532, single(fillmissing(POLIPHON2.ext_d_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_d_klett_1064, single(fillmissing(POLIPHON2.ext_d_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_cd_klett_355, single(fillmissing(POLIPHON2.ext_cd_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_cd_klett_532, single(fillmissing(POLIPHON2.ext_cd_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_cd_klett_1064, single(fillmissing(POLIPHON2.ext_cd_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_fd_klett_355, single(fillmissing(POLIPHON2.ext_fd_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_fd_klett_532, single(fillmissing(POLIPHON2.ext_fd_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_fd_klett_1064, single(fillmissing(POLIPHON2.ext_fd_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_ndm_klett_355, single(fillmissing(POLIPHON2.ext_ndm_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_ndm_klett_532, single(fillmissing(POLIPHON2.ext_ndm_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_ndm_klett_1064, single(fillmissing(POLIPHON2.ext_ndm_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_nds_klett_355, single(fillmissing(POLIPHON2.ext_nds_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_nds_klett_532, single(fillmissing(POLIPHON2.ext_nds_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_nds_klett_1064, single(fillmissing(POLIPHON2.ext_nds_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_bb_klett_355, single(fillmissing(POLIPHON2.ext_bb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_bb_klett_532, single(fillmissing(POLIPHON2.ext_bb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_bb_klett_1064, single(fillmissing(POLIPHON2.ext_bb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_vsf_klett_355, single(fillmissing(POLIPHON2.ext_vsf_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_vsf_klett_532, single(fillmissing(POLIPHON2.ext_vsf_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_vsf_klett_1064, single(fillmissing(POLIPHON2.ext_vsf_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_vsa_klett_355, single(fillmissing(POLIPHON2.ext_vsa_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_vsa_klett_532, single(fillmissing(POLIPHON2.ext_vsa_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_vsa_klett_1064, single(fillmissing(POLIPHON2.ext_vsa_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_vst_klett_355, single(fillmissing(POLIPHON2.ext_vst_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_vst_klett_532, single(fillmissing(POLIPHON2.ext_vst_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_ext_vst_klett_1064, single(fillmissing(POLIPHON2.ext_vst_klett_1064(:, 1), missing_value)));

% mass concentrations
netcdf.putVar(ncID_klett, varID_m_d_klett_355, single(fillmissing(POLIPHON2.m_d_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_d_klett_532, single(fillmissing(POLIPHON2.m_d_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_d_klett_1064, single(fillmissing(POLIPHON2.m_d_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_cd_klett_355, single(fillmissing(POLIPHON2.m_cd_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_cd_klett_532, single(fillmissing(POLIPHON2.m_cd_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_cd_klett_1064, single(fillmissing(POLIPHON2.m_cd_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_fd_klett_355, single(fillmissing(POLIPHON2.m_fd_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_fd_klett_532, single(fillmissing(POLIPHON2.m_fd_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_fd_klett_1064, single(fillmissing(POLIPHON2.m_fd_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_ndm_klett_355, single(fillmissing(POLIPHON2.m_ndm_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_ndm_klett_532, single(fillmissing(POLIPHON2.m_ndm_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_ndm_klett_1064, single(fillmissing(POLIPHON2.m_ndm_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_nds_klett_355, single(fillmissing(POLIPHON2.m_nds_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_nds_klett_532, single(fillmissing(POLIPHON2.m_nds_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_nds_klett_1064, single(fillmissing(POLIPHON2.m_nds_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_bb_klett_355, single(fillmissing(POLIPHON2.m_bb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_bb_klett_532, single(fillmissing(POLIPHON2.m_bb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_bb_klett_1064, single(fillmissing(POLIPHON2.m_bb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_vsf_klett_355, single(fillmissing(POLIPHON2.m_vsf_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_vsf_klett_532, single(fillmissing(POLIPHON2.m_vsf_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_vsf_klett_1064, single(fillmissing(POLIPHON2.m_vsf_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_vsa_klett_355, single(fillmissing(POLIPHON2.m_vsa_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_vsa_klett_532, single(fillmissing(POLIPHON2.m_vsa_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_vsa_klett_1064, single(fillmissing(POLIPHON2.m_vsa_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_vst_klett_355, single(fillmissing(POLIPHON2.m_vst_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_vst_klett_532, single(fillmissing(POLIPHON2.m_vst_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_m_vst_klett_1064, single(fillmissing(POLIPHON2.m_vst_klett_1064(:, 1), missing_value)));

% number concentrations
netcdf.putVar(ncID_klett, varID_n_100_d_klett_355, single(fillmissing(POLIPHON2.n_100_d_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_100_d_klett_532, single(fillmissing(POLIPHON2.n_100_d_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_100_d_klett_1064, single(fillmissing(POLIPHON2.n_100_d_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_d_klett_355, single(fillmissing(POLIPHON2.n_250_d_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_d_klett_532, single(fillmissing(POLIPHON2.n_250_d_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_d_klett_1064, single(fillmissing(POLIPHON2.n_250_d_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_c_klett_355, single(fillmissing(POLIPHON2.n_50_c_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_c_klett_532, single(fillmissing(POLIPHON2.n_50_c_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_c_klett_1064, single(fillmissing(POLIPHON2.n_50_c_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_c_klett_355, single(fillmissing(POLIPHON2.n_250_c_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_c_klett_532, single(fillmissing(POLIPHON2.n_250_c_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_c_klett_1064, single(fillmissing(POLIPHON2.n_250_c_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_m_klett_355, single(fillmissing(POLIPHON2.n_50_m_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_m_klett_532, single(fillmissing(POLIPHON2.n_50_m_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_m_klett_1064, single(fillmissing(POLIPHON2.n_50_m_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_m_klett_355, single(fillmissing(POLIPHON2.n_250_m_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_m_klett_532, single(fillmissing(POLIPHON2.n_250_m_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_m_klett_1064, single(fillmissing(POLIPHON2.n_250_m_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_bb_klett_355, single(fillmissing(POLIPHON2.n_50_bb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_bb_klett_532, single(fillmissing(POLIPHON2.n_50_bb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_bb_klett_1064, single(fillmissing(POLIPHON2.n_50_bb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_bb_klett_355, single(fillmissing(POLIPHON2.n_250_bb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_bb_klett_532, single(fillmissing(POLIPHON2.n_250_bb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_bb_klett_1064, single(fillmissing(POLIPHON2.n_250_bb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_vsf_klett_355, single(fillmissing(POLIPHON2.n_50_vsf_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_vsf_klett_532, single(fillmissing(POLIPHON2.n_50_vsf_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_vsf_klett_1064, single(fillmissing(POLIPHON2.n_50_vsf_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_vsf_klett_355, single(fillmissing(POLIPHON2.n_250_vsf_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_vsf_klett_532, single(fillmissing(POLIPHON2.n_250_vsf_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_vsf_klett_1064, single(fillmissing(POLIPHON2.n_250_vsf_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_vsa_klett_355, single(fillmissing(POLIPHON2.n_50_vsa_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_vsa_klett_532, single(fillmissing(POLIPHON2.n_50_vsa_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_vsa_klett_1064, single(fillmissing(POLIPHON2.n_50_vsa_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_vsa_klett_355, single(fillmissing(POLIPHON2.n_250_vsa_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_vsa_klett_532, single(fillmissing(POLIPHON2.n_250_vsa_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_vsa_klett_1064, single(fillmissing(POLIPHON2.n_250_vsa_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_vst_klett_355, single(fillmissing(POLIPHON2.n_50_vst_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_vst_klett_532, single(fillmissing(POLIPHON2.n_50_vst_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_50_vst_klett_1064, single(fillmissing(POLIPHON2.n_50_vst_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_vst_klett_355, single(fillmissing(POLIPHON2.n_250_vst_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_vst_klett_532, single(fillmissing(POLIPHON2.n_250_vst_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_250_vst_klett_1064, single(fillmissing(POLIPHON2.n_250_vst_klett_1064(:, 1), missing_value)));

% surface area concentrations
netcdf.putVar(ncID_klett, varID_sa_d_klett_355, single(fillmissing(POLIPHON2.sa_d_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_d_klett_532, single(fillmissing(POLIPHON2.sa_d_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_d_klett_1064, single(fillmissing(POLIPHON2.sa_d_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_c_klett_355, single(fillmissing(POLIPHON2.sa_c_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_c_klett_532, single(fillmissing(POLIPHON2.sa_c_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_c_klett_1064, single(fillmissing(POLIPHON2.sa_c_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_m_klett_355, single(fillmissing(POLIPHON2.sa_m_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_m_klett_532, single(fillmissing(POLIPHON2.sa_m_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_m_klett_1064, single(fillmissing(POLIPHON2.sa_m_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_bb_klett_355, single(fillmissing(POLIPHON2.sa_bb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_bb_klett_532, single(fillmissing(POLIPHON2.sa_bb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_bb_klett_1064, single(fillmissing(POLIPHON2.sa_bb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_vsf_klett_355, single(fillmissing(POLIPHON2.sa_vsf_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_vsf_klett_532, single(fillmissing(POLIPHON2.sa_vsf_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_vsf_klett_1064, single(fillmissing(POLIPHON2.sa_vsf_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_vsa_klett_355, single(fillmissing(POLIPHON2.sa_vsa_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_vsa_klett_532, single(fillmissing(POLIPHON2.sa_vsa_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_vsa_klett_1064, single(fillmissing(POLIPHON2.sa_vsa_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_vst_klett_355, single(fillmissing(POLIPHON2.sa_vst_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_vst_klett_532, single(fillmissing(POLIPHON2.sa_vst_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_sa_vst_klett_1064, single(fillmissing(POLIPHON2.sa_vst_klett_1064(:, 1), missing_value)));

% errors extinction
netcdf.putVar(ncID_klett, varID_err_ext_d_klett_355, single(fillmissing(POLIPHON2.err_ext_d_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_d_klett_532, single(fillmissing(POLIPHON2.err_ext_d_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_d_klett_1064, single(fillmissing(POLIPHON2.err_ext_d_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_cd_klett_355, single(fillmissing(POLIPHON2.err_ext_cd_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_cd_klett_532, single(fillmissing(POLIPHON2.err_ext_cd_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_cd_klett_1064, single(fillmissing(POLIPHON2.err_ext_cd_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_fd_klett_355, single(fillmissing(POLIPHON2.err_ext_fd_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_fd_klett_532, single(fillmissing(POLIPHON2.err_ext_fd_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_fd_klett_1064, single(fillmissing(POLIPHON2.err_ext_fd_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_ndm_klett_355, single(fillmissing(POLIPHON2.err_ext_ndm_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_ndm_klett_532, single(fillmissing(POLIPHON2.err_ext_ndm_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_ndm_klett_1064, single(fillmissing(POLIPHON2.err_ext_ndm_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_nds_klett_355, single(fillmissing(POLIPHON2.err_ext_nds_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_nds_klett_532, single(fillmissing(POLIPHON2.err_ext_nds_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_nds_klett_1064, single(fillmissing(POLIPHON2.err_ext_nds_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_bb_klett_355, single(fillmissing(POLIPHON2.err_ext_bb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_bb_klett_532, single(fillmissing(POLIPHON2.err_ext_bb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_bb_klett_1064, single(fillmissing(POLIPHON2.err_ext_bb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_vsf_klett_355, single(fillmissing(POLIPHON2.err_ext_vsf_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_vsf_klett_532, single(fillmissing(POLIPHON2.err_ext_vsf_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_vsf_klett_1064, single(fillmissing(POLIPHON2.err_ext_vsf_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_vsa_klett_355, single(fillmissing(POLIPHON2.err_ext_vsa_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_vsa_klett_532, single(fillmissing(POLIPHON2.err_ext_vsa_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_vsa_klett_1064, single(fillmissing(POLIPHON2.err_ext_vsa_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_vst_klett_355, single(fillmissing(POLIPHON2.err_ext_vst_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_vst_klett_532, single(fillmissing(POLIPHON2.err_ext_vst_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_ext_vst_klett_1064, single(fillmissing(POLIPHON2.err_ext_vst_klett_1064(:, 1), missing_value)));

% errors mass
netcdf.putVar(ncID_klett, varID_err_m_d_klett_355, single(fillmissing(POLIPHON2.err_m_d_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_d_klett_532, single(fillmissing(POLIPHON2.err_m_d_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_d_klett_1064, single(fillmissing(POLIPHON2.err_m_d_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_cd_klett_355, single(fillmissing(POLIPHON2.err_m_cd_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_cd_klett_532, single(fillmissing(POLIPHON2.err_m_cd_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_cd_klett_1064, single(fillmissing(POLIPHON2.err_m_cd_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_fd_klett_355, single(fillmissing(POLIPHON2.err_m_fd_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_fd_klett_532, single(fillmissing(POLIPHON2.err_m_fd_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_fd_klett_1064, single(fillmissing(POLIPHON2.err_m_fd_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_ndm_klett_355, single(fillmissing(POLIPHON2.err_m_ndm_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_ndm_klett_532, single(fillmissing(POLIPHON2.err_m_ndm_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_ndm_klett_1064, single(fillmissing(POLIPHON2.err_m_ndm_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_nds_klett_355, single(fillmissing(POLIPHON2.err_m_nds_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_nds_klett_532, single(fillmissing(POLIPHON2.err_m_nds_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_nds_klett_1064, single(fillmissing(POLIPHON2.err_m_nds_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_bb_klett_355, single(fillmissing(POLIPHON2.err_m_bb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_bb_klett_532, single(fillmissing(POLIPHON2.err_m_bb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_bb_klett_1064, single(fillmissing(POLIPHON2.err_m_bb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_vsf_klett_355, single(fillmissing(POLIPHON2.err_m_vsf_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_vsf_klett_532, single(fillmissing(POLIPHON2.err_m_vsf_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_vsf_klett_1064, single(fillmissing(POLIPHON2.err_m_vsf_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_vsa_klett_355, single(fillmissing(POLIPHON2.err_m_vsa_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_vsa_klett_532, single(fillmissing(POLIPHON2.err_m_vsa_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_vsa_klett_1064, single(fillmissing(POLIPHON2.err_m_vsa_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_vst_klett_355, single(fillmissing(POLIPHON2.err_m_vst_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_vst_klett_532, single(fillmissing(POLIPHON2.err_m_vst_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_err_m_vst_klett_1064, single(fillmissing(POLIPHON2.err_m_vst_klett_1064(:, 1), missing_value)));

% ccn
netcdf.putVar(ncID_klett, varID_n_ccn_klett_355, single(fillmissing(POLIPHON2.n_ccn_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_klett_532, single(fillmissing(POLIPHON2.n_ccn_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_klett_1064, single(fillmissing(POLIPHON2.n_ccn_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_d_klett_355, single(fillmissing(POLIPHON2.n_ccn_d_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_d_klett_532, single(fillmissing(POLIPHON2.n_ccn_d_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_d_klett_1064, single(fillmissing(POLIPHON2.n_ccn_d_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_c_klett_355, single(fillmissing(POLIPHON2.n_ccn_c_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_c_klett_532, single(fillmissing(POLIPHON2.n_ccn_c_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_c_klett_1064, single(fillmissing(POLIPHON2.n_ccn_c_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_m_klett_355, single(fillmissing(POLIPHON2.n_ccn_m_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_m_klett_532, single(fillmissing(POLIPHON2.n_ccn_m_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_m_klett_1064, single(fillmissing(POLIPHON2.n_ccn_m_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_bb_klett_355, single(fillmissing(POLIPHON2.n_ccn_bb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_bb_klett_532, single(fillmissing(POLIPHON2.n_ccn_bb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_bb_klett_1064, single(fillmissing(POLIPHON2.n_ccn_bb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_vsf_klett_355, single(fillmissing(POLIPHON2.n_ccn_vsf_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_vsf_klett_532, single(fillmissing(POLIPHON2.n_ccn_vsf_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_vsf_klett_1064, single(fillmissing(POLIPHON2.n_ccn_vsf_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_vst_klett_355, single(fillmissing(POLIPHON2.n_ccn_vst_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_vst_klett_532, single(fillmissing(POLIPHON2.n_ccn_vst_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_vst_klett_1064, single(fillmissing(POLIPHON2.n_ccn_vst_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_vsa_klett_355, single(fillmissing(POLIPHON2.n_ccn_vsa_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_vsa_klett_532, single(fillmissing(POLIPHON2.n_ccn_vsa_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_ccn_vsa_klett_1064, single(fillmissing(POLIPHON2.n_ccn_vsa_klett_1064(:, 1), missing_value)));

% inp
netcdf.putVar(ncID_klett, varID_n_inp_d_d10_amb_klett_355, single(fillmissing(POLIPHON2.n_inp_d_d10_amb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_d10_amb_klett_532, single(fillmissing(POLIPHON2.n_inp_d_d10_amb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_d10_amb_klett_1064, single(fillmissing(POLIPHON2.n_inp_d_d10_amb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_d15_amb_klett_355, single(fillmissing(POLIPHON2.n_inp_d_d15_amb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_d15_amb_klett_532, single(fillmissing(POLIPHON2.n_inp_d_d15_amb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_d15_amb_klett_1064, single(fillmissing(POLIPHON2.n_inp_d_d15_amb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_n12_amb_klett_355, single(fillmissing(POLIPHON2.n_inp_d_n12_amb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_n12_amb_klett_532, single(fillmissing(POLIPHON2.n_inp_d_n12_amb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_n12_amb_klett_1064, single(fillmissing(POLIPHON2.n_inp_d_n12_amb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_s15_amb_klett_355, single(fillmissing(POLIPHON2.n_inp_d_s15_amb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_s15_amb_klett_532, single(fillmissing(POLIPHON2.n_inp_d_s15_amb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_s15_amb_klett_1064, single(fillmissing(POLIPHON2.n_inp_d_s15_amb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_d10_klett_355, single(fillmissing(POLIPHON2.n_inp_d_d10_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_d10_klett_532, single(fillmissing(POLIPHON2.n_inp_d_d10_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_d10_klett_1064, single(fillmissing(POLIPHON2.n_inp_d_d10_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_d15_klett_355, single(fillmissing(POLIPHON2.n_inp_d_d15_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_d15_klett_532, single(fillmissing(POLIPHON2.n_inp_d_d15_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_d15_klett_1064, single(fillmissing(POLIPHON2.n_inp_d_d15_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_n12_klett_355, single(fillmissing(POLIPHON2.n_inp_d_n12_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_n12_klett_532, single(fillmissing(POLIPHON2.n_inp_d_n12_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_n12_klett_1064, single(fillmissing(POLIPHON2.n_inp_d_n12_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_s15_klett_355, single(fillmissing(POLIPHON2.n_inp_d_s15_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_s15_klett_532, single(fillmissing(POLIPHON2.n_inp_d_s15_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_d_s15_klett_1064, single(fillmissing(POLIPHON2.n_inp_d_s15_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_c_d10_amb_klett_355, single(fillmissing(POLIPHON2.n_inp_c_d10_amb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_c_d10_amb_klett_532, single(fillmissing(POLIPHON2.n_inp_c_d10_amb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_c_d10_amb_klett_1064, single(fillmissing(POLIPHON2.n_inp_c_d10_amb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_c_d10_klett_355, single(fillmissing(POLIPHON2.n_inp_c_d10_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_c_d10_klett_532, single(fillmissing(POLIPHON2.n_inp_c_d10_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_c_d10_klett_1064, single(fillmissing(POLIPHON2.n_inp_c_d10_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_m_d10_amb_klett_355, single(fillmissing(POLIPHON2.n_inp_m_d10_amb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_m_d10_amb_klett_532, single(fillmissing(POLIPHON2.n_inp_m_d10_amb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_m_d10_amb_klett_1064, single(fillmissing(POLIPHON2.n_inp_m_d10_amb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_m_d10_klett_355, single(fillmissing(POLIPHON2.n_inp_m_d10_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_m_d10_klett_532, single(fillmissing(POLIPHON2.n_inp_m_d10_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_m_d10_klett_1064, single(fillmissing(POLIPHON2.n_inp_m_d10_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_bb_d10_amb_klett_355, single(fillmissing(POLIPHON2.n_inp_bb_d10_amb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_bb_d10_amb_klett_532, single(fillmissing(POLIPHON2.n_inp_bb_d10_amb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_bb_d10_amb_klett_1064, single(fillmissing(POLIPHON2.n_inp_bb_d10_amb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_bb_d10_klett_355, single(fillmissing(POLIPHON2.n_inp_bb_d10_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_bb_d10_klett_532, single(fillmissing(POLIPHON2.n_inp_bb_d10_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_bb_d10_klett_1064, single(fillmissing(POLIPHON2.n_inp_bb_d10_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vsf_d10_amb_klett_355, single(fillmissing(POLIPHON2.n_inp_vsf_d10_amb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vsf_d10_amb_klett_532, single(fillmissing(POLIPHON2.n_inp_vsf_d10_amb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vsf_d10_amb_klett_1064, single(fillmissing(POLIPHON2.n_inp_vsf_d10_amb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vsf_d10_klett_355, single(fillmissing(POLIPHON2.n_inp_vsf_d10_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vsf_d10_klett_532, single(fillmissing(POLIPHON2.n_inp_vsf_d10_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vsf_d10_klett_1064, single(fillmissing(POLIPHON2.n_inp_vsf_d10_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vsa_d10_amb_klett_355, single(fillmissing(POLIPHON2.n_inp_vsa_d10_amb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vsa_d10_amb_klett_532, single(fillmissing(POLIPHON2.n_inp_vsa_d10_amb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vsa_d10_amb_klett_1064, single(fillmissing(POLIPHON2.n_inp_vsa_d10_amb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vsa_d10_klett_355, single(fillmissing(POLIPHON2.n_inp_vsa_d10_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vsa_d10_klett_532, single(fillmissing(POLIPHON2.n_inp_vsa_d10_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vsa_d10_klett_1064, single(fillmissing(POLIPHON2.n_inp_vsa_d10_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vst_d10_amb_klett_355, single(fillmissing(POLIPHON2.n_inp_vst_d10_amb_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vst_d10_amb_klett_532, single(fillmissing(POLIPHON2.n_inp_vst_d10_amb_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vst_d10_amb_klett_1064, single(fillmissing(POLIPHON2.n_inp_vst_d10_amb_klett_1064(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vst_d10_klett_355, single(fillmissing(POLIPHON2.n_inp_vst_d10_klett_355(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vst_d10_klett_532, single(fillmissing(POLIPHON2.n_inp_vst_d10_klett_532(:, 1), missing_value)));
netcdf.putVar(ncID_klett, varID_n_inp_vst_d10_klett_1064, single(fillmissing(POLIPHON2.n_inp_vst_d10_klett_1064(:, 1), missing_value)));

% re enter define mode
netcdf.reDef(ncID_raman);
netcdf.reDef(ncID_klett);
%% write attributes to the variables
%raman
% altitude
netcdf.putAtt(ncID_raman, varID_altitude_raman, 'unit', 'm');
netcdf.putAtt(ncID_raman, varID_altitude_raman, 'long_name', 'Height of lidar above mean sea level');
netcdf.putAtt(ncID_raman, varID_altitude_raman, 'standard_name', 'altitude');

% longitude
netcdf.putAtt(ncID_raman, varID_longitude_raman, 'unit', 'degrees_east');
netcdf.putAtt(ncID_raman, varID_longitude_raman, 'long_name', 'Longitude of the site');
netcdf.putAtt(ncID_raman, varID_longitude_raman, 'standard_name', 'longitude');
netcdf.putAtt(ncID_raman, varID_longitude_raman, 'axis', 'X');

% latitude
netcdf.putAtt(ncID_raman, varID_latitude_raman, 'unit', 'degrees_north');
netcdf.putAtt(ncID_raman, varID_latitude_raman, 'long_name', 'Latitude of the site');
netcdf.putAtt(ncID_raman, varID_latitude_raman, 'standard_name', 'latitude');
netcdf.putAtt(ncID_raman, varID_latitude_raman, 'axis', 'Y');

% start_time
netcdf.putAtt(ncID_raman, varID_startTime_raman, 'unit', 'seconds since 1970-01-01 00:00:00 UTC');
netcdf.putAtt(ncID_raman, varID_startTime_raman, 'long_name', 'Time UTC to start the current measurement');
netcdf.putAtt(ncID_raman, varID_startTime_raman, 'standard_name', 'time');
netcdf.putAtt(ncID_raman, varID_startTime_raman, 'calendar', 'julian');

% end_time
netcdf.putAtt(ncID_raman, varID_endTime_raman, 'unit', 'seconds since 1970-01-01 00:00:00 UTC');
netcdf.putAtt(ncID_raman, varID_endTime_raman, 'long_name', 'Time UTC to finish the current measurement');
netcdf.putAtt(ncID_raman, varID_endTime_raman, 'standard_name', 'time');
netcdf.putAtt(ncID_raman, varID_endTime_raman, 'calendar', 'julian');

% height
netcdf.putAtt(ncID_raman, varID_height_raman, 'unit', 'm');
netcdf.putAtt(ncID_raman, varID_height_raman, 'long_name', 'Height above the ground');
netcdf.putAtt(ncID_raman, varID_height_raman, 'standard_name', 'height');
netcdf.putAtt(ncID_raman, varID_height_raman, 'axis', 'Z');

% time
netcdf.putAtt(ncID_raman, varID_time_raman, 'unit', 'seconds since 1970-01-01 00:00:00 UTC');
netcdf.putAtt(ncID_raman, varID_time_raman, 'long_name', 'Time UTC');
netcdf.putAtt(ncID_raman, varID_time_raman, 'standard_name', 'time');
netcdf.putAtt(ncID_raman, varID_time_raman, 'axis', 'T');
netcdf.putAtt(ncID_raman, varID_time_raman, 'calendar', 'julian');

% klett
% altitude
netcdf.putAtt(ncID_klett, varID_altitude_klett, 'unit', 'm');
netcdf.putAtt(ncID_klett, varID_altitude_klett, 'long_name', 'Height of lidar above mean sea level');
netcdf.putAtt(ncID_klett, varID_altitude_klett, 'standard_name', 'altitude');

% longitude
netcdf.putAtt(ncID_klett, varID_longitude_klett, 'unit', 'degrees_east');
netcdf.putAtt(ncID_klett, varID_longitude_klett, 'long_name', 'Longitude of the site');
netcdf.putAtt(ncID_klett, varID_longitude_klett, 'standard_name', 'longitude');
netcdf.putAtt(ncID_klett, varID_longitude_klett, 'axis', 'X');

% latitude
netcdf.putAtt(ncID_klett, varID_latitude_klett, 'unit', 'degrees_north');
netcdf.putAtt(ncID_klett, varID_latitude_klett, 'long_name', 'Latitude of the site');
netcdf.putAtt(ncID_klett, varID_latitude_klett, 'standard_name', 'latitude');
netcdf.putAtt(ncID_klett, varID_latitude_klett, 'axis', 'Y');

% start_time
netcdf.putAtt(ncID_klett, varID_startTime_klett, 'unit', 'seconds since 1970-01-01 00:00:00 UTC');
netcdf.putAtt(ncID_klett, varID_startTime_klett, 'long_name', 'Time UTC to start the current measurement');
netcdf.putAtt(ncID_klett, varID_startTime_klett, 'standard_name', 'time');
netcdf.putAtt(ncID_klett, varID_startTime_klett, 'calendar', 'julian');

% end_time
netcdf.putAtt(ncID_klett, varID_endTime_klett, 'unit', 'seconds since 1970-01-01 00:00:00 UTC');
netcdf.putAtt(ncID_klett, varID_endTime_klett, 'long_name', 'Time UTC to finish the current measurement');
netcdf.putAtt(ncID_klett, varID_endTime_klett, 'standard_name', 'time');
netcdf.putAtt(ncID_klett, varID_endTime_klett, 'calendar', 'julian');

% height
netcdf.putAtt(ncID_klett, varID_height_klett, 'unit', 'm');
netcdf.putAtt(ncID_klett, varID_height_klett, 'long_name', 'Height above the ground');
netcdf.putAtt(ncID_klett, varID_height_klett, 'standard_name', 'height');
netcdf.putAtt(ncID_klett, varID_height_klett, 'axis', 'Z');

% time
netcdf.putAtt(ncID_klett, varID_time_klett, 'unit', 'seconds since 1970-01-01 00:00:00 UTC');
netcdf.putAtt(ncID_klett, varID_time_klett, 'long_name', 'Time UTC');
netcdf.putAtt(ncID_klett, varID_time_klett, 'standard_name', 'time');
netcdf.putAtt(ncID_klett, varID_time_klett, 'axis', 'T');
netcdf.putAtt(ncID_klett, varID_time_klett, 'calendar', 'julian');
%% raman Extinction, Mass, Volume, INP, CCN,.. raman

% extinction
% dust
netcdf.putAtt(ncID_raman, varID_ext_d_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_d_raman_355, 'long_name', 'Dust ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_d_raman_355, 'standard_name', 'Ad_raman_355.');  

netcdf.putAtt(ncID_raman, varID_ext_d_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_d_raman_532, 'long_name', 'Dust ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_d_raman_532, 'standard_name', 'Ad_raman_532.');  

netcdf.putAtt(ncID_raman, varID_ext_d_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_d_raman_1064, 'long_name', 'Dust ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_d_raman_1064, 'standard_name', 'Ad_raman_1064.');  

% coarse dust
netcdf.putAtt(ncID_raman, varID_ext_cd_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_cd_raman_355, 'long_name', 'Coarse Dust ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_cd_raman_355, 'standard_name', 'Acd_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_ext_cd_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_cd_raman_532, 'long_name', 'Coarse Dust ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_cd_raman_532, 'standard_name', 'Acd_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_ext_cd_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_cd_raman_1064, 'long_name', 'Coarse Dust ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_cd_raman_1064, 'standard_name', 'Acd_raman_1064.'); 

% fine dust
netcdf.putAtt(ncID_raman, varID_ext_fd_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_fd_raman_355, 'long_name', 'Fine Dust ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_fd_raman_355, 'standard_name', 'Afd_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_ext_fd_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_fd_raman_532, 'long_name', 'Fine Dust ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_fd_raman_532, 'standard_name', 'Afd_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_ext_fd_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_fd_raman_1064, 'long_name', 'Fine Dust ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_fd_raman_1064, 'standard_name', 'Afd_raman_1064.'); 

% non-dust marine
netcdf.putAtt(ncID_raman, varID_ext_ndm_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_ndm_raman_355, 'long_name', 'Non-Dust marine ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_ndm_raman_355, 'standard_name', 'Andm1_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_ext_ndm_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_ndm_raman_532, 'long_name', 'Non-Dust marine ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_ndm_raman_532, 'standard_name', 'Andm1_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_ext_ndm_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_ndm_raman_1064, 'long_name', 'Non-Dust marine ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_ndm_raman_1064, 'standard_name', 'Andm1_raman_1064.'); 

% non-dust smoke
netcdf.putAtt(ncID_raman, varID_ext_nds_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_nds_raman_355, 'long_name', 'Non-Dust smoke ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_nds_raman_355, 'standard_name', 'Ands1_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_ext_nds_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_nds_raman_532, 'long_name', 'Non-Dust smoke ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_nds_raman_532, 'standard_name', 'Ands1_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_ext_nds_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_nds_raman_1064, 'long_name', 'Non-Dust smoke ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_nds_raman_1064, 'standard_name', 'Ands1_raman_1064.'); 

% biomass burning
netcdf.putAtt(ncID_raman, varID_ext_bb_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_bb_raman_355, 'long_name', 'Biomass burning smoke ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_bb_raman_355, 'standard_name', 'Abb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_ext_bb_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_bb_raman_532, 'long_name', 'Biomass burning smoke ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_bb_raman_532, 'standard_name', 'Abb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_ext_bb_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_bb_raman_1064, 'long_name', 'Biomass burning smoke ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_bb_raman_1064, 'standard_name', 'Abb_raman_1064.'); 

% fresh volcanic sulfate
netcdf.putAtt(ncID_raman, varID_ext_vsf_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_vsf_raman_355, 'long_name', 'fresh volcanic sulfate ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_vsf_raman_355, 'standard_name', 'Avsf_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_ext_vsf_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_vsf_raman_532, 'long_name', 'fresh volcanic sulfate ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_vsf_raman_532, 'standard_name', 'Avsf_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_ext_vsf_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_vsf_raman_1064, 'long_name', 'fresh volcanic sulfate ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_vsf_raman_1064, 'standard_name', 'Avsf_raman_1064.'); 

% aged volcanic sulfate
netcdf.putAtt(ncID_raman, varID_ext_vsa_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_vsa_raman_355, 'long_name', 'aged volcanic sulfate ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_vsa_raman_355, 'standard_name', 'Avsa_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_ext_vsa_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_vsa_raman_532, 'long_name', 'aged volcanic sulfate ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_vsa_raman_532, 'standard_name', 'Avsa_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_ext_vsa_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_vsa_raman_1064, 'long_name', 'aged volcanic sulfate ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_vsa_raman_1064, 'standard_name', 'Avsa_raman_1064.'); 

% tropospheric volcanic sulfate
netcdf.putAtt(ncID_raman, varID_ext_vst_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_vst_raman_355, 'long_name', 'tropospheric volcanic sulfate ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_vst_raman_355, 'standard_name', 'Avst_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_ext_vst_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_vst_raman_532, 'long_name', 'tropospheric volcanic sulfate ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_vst_raman_532, 'standard_name', 'Avst_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_ext_vst_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_ext_vst_raman_1064, 'long_name', 'tropospheric volcanic sulfate ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_ext_vst_raman_1064, 'standard_name', 'Avst_raman_1064.'); 

% mass 

% dust
netcdf.putAtt(ncID_raman, varID_m_d_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_d_raman_355, 'long_name', 'Dust mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_d_raman_355, 'standard_name', 'm_d_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_m_d_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_d_raman_532, 'long_name', 'Dust mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_d_raman_532, 'standard_name', 'm_d_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_m_d_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_d_raman_1064, 'long_name', 'Dust mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_d_raman_1064, 'standard_name', 'm_d_raman_1064.'); 

% coarse dust
netcdf.putAtt(ncID_raman, varID_m_cd_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_cd_raman_355, 'long_name', 'Coarse Dust mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_cd_raman_355, 'standard_name', 'm_cd_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_m_cd_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_cd_raman_532, 'long_name', 'Coarse Dust mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_cd_raman_532, 'standard_name', 'm_cd_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_m_cd_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_cd_raman_1064, 'long_name', 'Coarse Dust mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_cd_raman_1064, 'standard_name', 'm_cd_raman_1064.'); 

% fine dust
netcdf.putAtt(ncID_raman, varID_m_fd_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_fd_raman_355, 'long_name', 'Fine Dust mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_fd_raman_355, 'standard_name', 'm_fd_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_m_fd_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_fd_raman_532, 'long_name', 'Fine Dust mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_fd_raman_532, 'standard_name', 'm_fd_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_m_fd_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_fd_raman_1064, 'long_name', 'Fine Dust mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_fd_raman_1064, 'standard_name', 'm_fd_raman_1064.'); 

% marine
netcdf.putAtt(ncID_raman, varID_m_ndm_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_ndm_raman_355, 'long_name', 'Non-Dust marine mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_ndm_raman_355, 'standard_name', 'm_ndm_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_m_ndm_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_ndm_raman_532, 'long_name', 'Non-Dust marine mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_ndm_raman_532, 'standard_name', 'm_ndm_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_m_ndm_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_ndm_raman_1064, 'long_name', 'Non-Dust marine mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_ndm_raman_1064, 'standard_name', 'm_ndm_raman_1064.'); 

% smoke
netcdf.putAtt(ncID_raman, varID_m_nds_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_nds_raman_355, 'long_name', 'Non-Dust smoke mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_nds_raman_355, 'standard_name', 'm_nds_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_m_nds_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_nds_raman_532, 'long_name', 'Non-Dust smoke mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_nds_raman_532, 'standard_name', 'm_nds_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_m_nds_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_nds_raman_1064, 'long_name', 'Non-Dust smoke mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_nds_raman_1064, 'standard_name', 'm_nds_raman_1064.'); 

% biomass burning
netcdf.putAtt(ncID_raman, varID_m_bb_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_bb_raman_355, 'long_name', 'Biomass burning mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_bb_raman_355, 'standard_name', 'm_bb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_m_bb_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_bb_raman_532, 'long_name', 'Biomass burning mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_bb_raman_532, 'standard_name', 'm_bb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_m_bb_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_bb_raman_1064, 'long_name', 'Biomass burning mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_bb_raman_1064, 'standard_name', 'm_bb_raman_1064.'); 

% vsf
netcdf.putAtt(ncID_raman, varID_m_vsf_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_vsf_raman_355, 'long_name', 'fresh volcanic sulfate mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_vsf_raman_355, 'standard_name', 'm_vsf_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_m_vsf_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_vsf_raman_532, 'long_name', 'fresh volcanic sulfate mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_vsf_raman_532, 'standard_name', 'm_vsf_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_m_vsf_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_vsf_raman_1064, 'long_name', 'fresh volcanic sulfate mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_vsf_raman_1064, 'standard_name', 'm_vsf_raman_1064.'); 

% vsa
netcdf.putAtt(ncID_raman, varID_m_vsa_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_vsa_raman_355, 'long_name', 'aged volcanic sulfate mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_vsa_raman_355, 'standard_name', 'm_vsa_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_m_vsa_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_vsa_raman_532, 'long_name', 'aged volcanic sulfate mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_vsa_raman_532, 'standard_name', 'm_vsa_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_m_vsa_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_vsa_raman_1064, 'long_name', 'aged volcanic sulfate mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_vsa_raman_1064, 'standard_name', 'm_vsa_raman_1064.'); 

% vst
netcdf.putAtt(ncID_raman, varID_m_vst_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_vst_raman_355, 'long_name', 'tropospheric volcanic sulfate mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_vst_raman_355, 'standard_name', 'm_vst_raman_355.');

netcdf.putAtt(ncID_raman, varID_m_vst_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_vst_raman_532, 'long_name', 'tropospheric volcanic sulfate mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_vst_raman_532, 'standard_name', 'm_vst_raman_532.');

netcdf.putAtt(ncID_raman, varID_m_vst_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_m_vst_raman_1064, 'long_name', 'tropospheric volcanic sulfate mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_m_vst_raman_1064, 'standard_name', 'm_vst_raman_1064.');

% number concentrations

% dust 100
netcdf.putAtt(ncID_raman, varID_n_100_d_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_100_d_raman_355, 'long_name', 'Dust Number Conc. >100nm 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_100_d_raman_355, 'standard_name', 'n_100_d_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_100_d_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_100_d_raman_532, 'long_name', 'Dust Number Conc. >100nm 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_100_d_raman_532, 'standard_name', 'n_100_d_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_100_d_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_100_d_raman_1064, 'long_name', 'Dust Number Conc. >100nm 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_100_d_raman_1064, 'standard_name', 'n_100_d_raman_1064.'); 

% dust 250
netcdf.putAtt(ncID_raman, varID_n_250_d_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_d_raman_355, 'long_name', 'Dust Number Conc. >250nm 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_d_raman_355, 'standard_name', 'n_250_d_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_250_d_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_d_raman_532, 'long_name', 'Dust Number Conc. >250nm 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_d_raman_532, 'standard_name', 'n_250_d_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_250_d_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_d_raman_1064, 'long_name', 'Dust Number Conc. >250nm 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_d_raman_1064, 'standard_name', 'n_250_d_raman_1064.'); 

% continental 50
netcdf.putAtt(ncID_raman, varID_n_50_c_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_c_raman_355, 'long_name', 'Continental Number Conc. >50nm 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_c_raman_355, 'standard_name', 'n_50_c_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_50_c_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_c_raman_532, 'long_name', 'Continental Number Conc. >50nm 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_c_raman_532, 'standard_name', 'n_50_c_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_50_c_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_c_raman_1064, 'long_name', 'Continental Number Conc. >50nm 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_c_raman_1064, 'standard_name', 'n_50_c_raman_1064.'); 

% continental 250
netcdf.putAtt(ncID_raman, varID_n_250_c_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_c_raman_355, 'long_name', 'Continental Number Conc. >250nm 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_c_raman_355, 'standard_name', 'n_250_c_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_250_c_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_c_raman_532, 'long_name', 'Continental Number Conc. >250nm 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_c_raman_532, 'standard_name', 'n_250_c_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_250_c_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_c_raman_1064, 'long_name', 'Continental Number Conc. >250nm 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_c_raman_1064, 'standard_name', 'n_250_c_raman_1064.'); 

% marine 50
netcdf.putAtt(ncID_raman, varID_n_50_m_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_m_raman_355, 'long_name', 'Marine Number Conc. >50nm 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_m_raman_355, 'standard_name', 'n_50_m_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_50_m_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_m_raman_532, 'long_name', 'Marine Number Conc. >50nm 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_m_raman_532, 'standard_name', 'n_50_m_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_50_m_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_m_raman_1064, 'long_name', 'Marine Number Conc. >50nm 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_m_raman_1064, 'standard_name', 'n_50_m_raman_1064.'); 

% marine 250
netcdf.putAtt(ncID_raman, varID_n_250_m_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_m_raman_355, 'long_name', 'Marine Number Conc. >250nm 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_m_raman_355, 'standard_name', 'n_250_m_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_250_m_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_m_raman_532, 'long_name', 'Marine Number Conc. >250nm 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_m_raman_532, 'standard_name', 'n_250_m_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_250_m_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_m_raman_1064, 'long_name', 'Marine Number Conc. >250nm 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_m_raman_1064, 'standard_name', 'n_250_m_raman_1064.'); 

% biomass burning 50
netcdf.putAtt(ncID_raman, varID_n_50_bb_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_bb_raman_355, 'long_name', 'Biomass Burning Number Conc. >50nm 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_bb_raman_355, 'standard_name', 'n_50_bb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_50_bb_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_bb_raman_532, 'long_name', 'Biomass Burning Number Conc. >50nm 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_bb_raman_532, 'standard_name', 'n_50_bb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_50_bb_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_bb_raman_1064, 'long_name', 'Biomass Burning Number Conc. >50nm 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_bb_raman_1064, 'standard_name', 'n_50_bb_raman_1064.'); 

% biomass burning 250
netcdf.putAtt(ncID_raman, varID_n_250_bb_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_bb_raman_355, 'long_name', 'Biomass Burning Number Conc. >250nm 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_bb_raman_355, 'standard_name', 'n_250_bb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_250_bb_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_bb_raman_532, 'long_name', 'Biomass Burning Number Conc. >250nm 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_bb_raman_532, 'standard_name', 'n_250_bb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_250_bb_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_bb_raman_1064, 'long_name', 'Biomass Burning Number Conc. >250nm 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_bb_raman_1064, 'standard_name', 'n_250_bb_raman_1064.'); 

% vsf 50
netcdf.putAtt(ncID_raman, varID_n_50_vsf_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_vsf_raman_355, 'long_name', 'Fresh Volcanic Sulfate Number Conc. >50nm 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_vsf_raman_355, 'standard_name', 'n_50_vsf_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_50_vsf_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_vsf_raman_532, 'long_name', 'Fresh Volcanic Sulfate Number Conc. >50nm 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_vsf_raman_532, 'standard_name', 'n_50_vsf_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_50_vsf_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_vsf_raman_1064, 'long_name', 'Fresh Volcanic Sulfate Number Conc. >50nm 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_vsf_raman_1064, 'standard_name', 'n_50_vsf_raman_1064.'); 

% vsf 250
netcdf.putAtt(ncID_raman, varID_n_250_vsf_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_vsf_raman_355, 'long_name', 'Fresh Volcanic Sulfate Number Conc. >250nm 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_vsf_raman_355, 'standard_name', 'n_250_vsf_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_250_vsf_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_vsf_raman_532, 'long_name', 'Fresh Volcanic Sulfate Number Conc. >250nm 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_vsf_raman_532, 'standard_name', 'n_250_vsf_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_250_vsf_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_vsf_raman_1064, 'long_name', 'Fresh Volcanic Sulfate Number Conc. >250nm 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_vsf_raman_1064, 'standard_name', 'n_250_vsf_raman_1064.'); 

% vsa 50
netcdf.putAtt(ncID_raman, varID_n_50_vsa_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_vsa_raman_355, 'long_name', 'Aged Volcanic Sulfate Number Conc. >50nm 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_vsa_raman_355, 'standard_name', 'n_50_vsa_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_50_vsa_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_vsa_raman_532, 'long_name', 'Aged Volcanic Sulfate Number Conc. >50nm 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_vsa_raman_532, 'standard_name', 'n_50_vsa_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_50_vsa_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_vsa_raman_1064, 'long_name', 'Aged Volcanic Sulfate Number Conc. >50nm 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_vsa_raman_1064, 'standard_name', 'n_50_vsa_raman_1064.'); 

% vsa 250
netcdf.putAtt(ncID_raman, varID_n_250_vsa_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_vsa_raman_355, 'long_name', 'Aged Volcanic Sulfate Number Conc. >250nm 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_vsa_raman_355, 'standard_name', 'n_250_vsa_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_250_vsa_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_vsa_raman_532, 'long_name', 'Aged Volcanic Sulfate Number Conc. >250nm 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_vsa_raman_532, 'standard_name', 'n_250_vsa_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_250_vsa_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_vsa_raman_1064, 'long_name', 'Aged Volcanic Sulfate Number Conc. >250nm 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_vsa_raman_1064, 'standard_name', 'n_250_vsa_raman_1064.'); 

% vst 50
netcdf.putAtt(ncID_raman, varID_n_50_vst_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_vst_raman_355, 'long_name', 'Trop. Volcanic Sulfate Number Conc. >50nm 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_vst_raman_355, 'standard_name', 'n_50_vst_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_50_vst_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_vst_raman_532, 'long_name', 'Trop. Volcanic Sulfate Number Conc. >50nm 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_vst_raman_532, 'standard_name', 'n_50_vst_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_50_vst_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_50_vst_raman_1064, 'long_name', 'Trop. Volcanic Sulfate Number Conc. >50nm 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_50_vst_raman_1064, 'standard_name', 'n_50_vst_raman_1064.'); 

% vst 250
netcdf.putAtt(ncID_raman, varID_n_250_vst_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_vst_raman_355, 'long_name', 'Trop. Volcanic Sulfate Number Conc. >250nm 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_vst_raman_355, 'standard_name', 'n_250_vst_raman_355.');

netcdf.putAtt(ncID_raman, varID_n_250_vst_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_vst_raman_532, 'long_name', 'Trop. Volcanic Sulfate Number Conc. >250nm 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_vst_raman_532, 'standard_name', 'n_250_vst_raman_532.');

netcdf.putAtt(ncID_raman, varID_n_250_vst_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_250_vst_raman_1064, 'long_name', 'Trop. Volcanic Sulfate Number Conc. >250nm 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_250_vst_raman_1064, 'standard_name', 'n_250_vst_raman_1064.');

% surface area conc

% dust
netcdf.putAtt(ncID_raman, varID_sa_d_raman_355, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_d_raman_355, 'long_name', 'Dust Surface Area Conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_d_raman_355, 'standard_name', 'sa_d_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_sa_d_raman_532, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_d_raman_532, 'long_name', 'Dust Surface Area Conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_d_raman_532, 'standard_name', 'sa_d_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_sa_d_raman_1064, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_d_raman_1064, 'long_name', 'Dust Surface Area Conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_d_raman_1064, 'standard_name', 'sa_d_raman_1064.'); 

% continental
netcdf.putAtt(ncID_raman, varID_sa_c_raman_355, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_c_raman_355, 'long_name', 'Continental Surface Area Conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_c_raman_355, 'standard_name', 'sa_c_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_sa_c_raman_532, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_c_raman_532, 'long_name', 'Continental Surface Area Conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_c_raman_532, 'standard_name', 'sa_c_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_sa_c_raman_1064, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_c_raman_1064, 'long_name', 'Continental Surface Area Conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_c_raman_1064, 'standard_name', 'sa_c_raman_1064.'); 

% marine
netcdf.putAtt(ncID_raman, varID_sa_m_raman_355, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_m_raman_355, 'long_name', 'Marine Surface Area Conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_m_raman_355, 'standard_name', 'sa_m_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_sa_m_raman_532, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_m_raman_532, 'long_name', 'Marine Surface Area Conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_m_raman_532, 'standard_name', 'sa_m_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_sa_m_raman_1064, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_m_raman_1064, 'long_name', 'Marine Surface Area Conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_m_raman_1064, 'standard_name', 'sa_m_raman_1064.'); 

% biomass burning
netcdf.putAtt(ncID_raman, varID_sa_bb_raman_355, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_bb_raman_355, 'long_name', 'Biomass Burning Surface Area Conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_bb_raman_355, 'standard_name', 'sa_bb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_sa_bb_raman_532, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_bb_raman_532, 'long_name', 'Biomass Burning Surface Area Conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_bb_raman_532, 'standard_name', 'sa_bb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_sa_bb_raman_1064, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_bb_raman_1064, 'long_name', 'Biomass Burning Surface Area Conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_bb_raman_1064, 'standard_name', 'sa_bb_raman_1064.'); 

% fresh volcanic
netcdf.putAtt(ncID_raman, varID_sa_vsf_raman_355, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_vsf_raman_355, 'long_name', 'Fresh Volcanic Sulfate Surface Area Conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_vsf_raman_355, 'standard_name', 'sa_vsf_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_sa_vsf_raman_532, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_vsf_raman_532, 'long_name', 'Fresh Volcanic Sulfate Surface Area Conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_vsf_raman_532, 'standard_name', 'sa_vsf_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_sa_vsf_raman_1064, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_vsf_raman_1064, 'long_name', 'Fresh Volcanic Sulfate Surface Area Conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_vsf_raman_1064, 'standard_name', 'sa_vsf_raman_1064.'); 

% aged volcanic
netcdf.putAtt(ncID_raman, varID_sa_vsa_raman_355, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_vsa_raman_355, 'long_name', 'Aged Volcanic Sulfate Surface Area Conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_vsa_raman_355, 'standard_name', 'sa_vsa_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_sa_vsa_raman_532, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_vsa_raman_532, 'long_name', 'Aged Volcanic Sulfate Surface Area Conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_vsa_raman_532, 'standard_name', 'sa_vsa_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_sa_vsa_raman_1064, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_vsa_raman_1064, 'long_name', 'Aged Volcanic Sulfate Surface Area Conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_vsa_raman_1064, 'standard_name', 'sa_vsa_raman_1064.'); 

% trop. volcanic
netcdf.putAtt(ncID_raman, varID_sa_vst_raman_355, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_vst_raman_355, 'long_name', 'Trop. Volcanic Sulfate Surface Area Conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_vst_raman_355, 'standard_name', 'sa_vst_raman_355.');

netcdf.putAtt(ncID_raman, varID_sa_vst_raman_532, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_vst_raman_532, 'long_name', 'Trop. Volcanic Sulfate Surface Area Conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_vst_raman_532, 'standard_name', 'sa_vst_raman_532.');

netcdf.putAtt(ncID_raman, varID_sa_vst_raman_1064, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_sa_vst_raman_1064, 'long_name', 'Trop. Volcanic Sulfate Surface Area Conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_sa_vst_raman_1064, 'standard_name', 'sa_vst_raman_1064.');

% errors
% extinction
% dust
netcdf.putAtt(ncID_raman, varID_err_ext_d_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_d_raman_355, 'long_name', 'Error Dust ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_d_raman_355, 'standard_name', 'err_ext_d_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_err_ext_d_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_d_raman_532, 'long_name', 'Error Dust ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_d_raman_532, 'standard_name', 'err_ext_d_raman_532.'); 


netcdf.putAtt(ncID_raman, varID_err_ext_d_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_d_raman_1064, 'long_name', 'Error Dust ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_d_raman_1064, 'standard_name', 'err_ext_d_raman_1064.'); 

% coarse dust
netcdf.putAtt(ncID_raman, varID_err_ext_cd_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_cd_raman_355, 'long_name', 'Error Coarse Dust ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_cd_raman_355, 'standard_name', 'err_ext_cd_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_err_ext_cd_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_cd_raman_532, 'long_name', 'Error Coarse Dust ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_cd_raman_532, 'standard_name', 'err_ext_cd_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_err_ext_cd_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_cd_raman_1064, 'long_name', 'Error Coarse Dust ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_cd_raman_1064, 'standard_name', 'err_ext_cd_raman_1064.'); 

% fine dust
netcdf.putAtt(ncID_raman, varID_err_ext_fd_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_fd_raman_355, 'long_name', 'Error Fine Dust ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_fd_raman_355, 'standard_name', 'err_ext_fd_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_err_ext_fd_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_fd_raman_532, 'long_name', 'Error Fine Dust ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_fd_raman_532, 'standard_name', 'err_ext_fd_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_err_ext_fd_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_fd_raman_1064, 'long_name', 'Error Fine Dust ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_fd_raman_1064, 'standard_name', 'err_ext_fd_raman_1064.'); 

% marine
netcdf.putAtt(ncID_raman, varID_err_ext_ndm_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_ndm_raman_355, 'long_name', 'Error Non-Dust marine ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_ndm_raman_355, 'standard_name', 'err_ext_ndm_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_err_ext_ndm_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_ndm_raman_532, 'long_name', 'Error Non-Dust marine ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_ndm_raman_532, 'standard_name', 'err_ext_ndm_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_err_ext_ndm_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_ndm_raman_1064, 'long_name', 'Error Non-Dust marine ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_ndm_raman_1064, 'standard_name', 'err_ext_ndm_raman_1064.'); 

% smoke
netcdf.putAtt(ncID_raman, varID_err_ext_nds_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_nds_raman_355, 'long_name', 'Error Non-Dust smoke ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_nds_raman_355, 'standard_name', 'err_ext_nds_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_err_ext_nds_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_nds_raman_532, 'long_name', 'Error Non-Dust smoke ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_nds_raman_532, 'standard_name', 'err_ext_nds_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_err_ext_nds_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_nds_raman_1064, 'long_name', 'Error Non-Dust smoke ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_nds_raman_1064, 'standard_name', 'err_ext_nds_raman_1064.'); 

% biomass burning
netcdf.putAtt(ncID_raman, varID_err_ext_bb_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_bb_raman_355, 'long_name', 'Error Biomass burning ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_bb_raman_355, 'standard_name', 'err_ext_bb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_err_ext_bb_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_bb_raman_532, 'long_name', 'Error Biomass burning ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_bb_raman_532, 'standard_name', 'err_ext_bb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_err_ext_bb_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_bb_raman_1064, 'long_name', 'Error Biomass burning ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_bb_raman_1064, 'standard_name', 'err_ext_bb_raman_1064.'); 

% fresh vs
netcdf.putAtt(ncID_raman, varID_err_ext_vsf_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_vsf_raman_355, 'long_name', 'Error fresh volcanic sulfate ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_vsf_raman_355, 'standard_name', 'err_ext_vsf_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_err_ext_vsf_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_vsf_raman_532, 'long_name', 'Error fresh volcanic sulfate ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_vsf_raman_532, 'standard_name', 'err_ext_vsf_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_err_ext_vsf_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_vsf_raman_1064, 'long_name', 'Error fresh volcanic sulfate ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_vsf_raman_1064, 'standard_name', 'err_ext_vsf_raman_1064.'); 

% aged vs
netcdf.putAtt(ncID_raman, varID_err_ext_vsa_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_vsa_raman_355, 'long_name', 'Error aged volcanic sulfate ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_vsa_raman_355, 'standard_name', 'err_ext_vsa_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_err_ext_vsa_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_vsa_raman_532, 'long_name', 'Error aged volcanic sulfate ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_vsa_raman_532, 'standard_name', 'err_ext_vsa_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_err_ext_vsa_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_vsa_raman_1064, 'long_name', 'Error aged volcanic sulfate ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_vsa_raman_1064, 'standard_name', 'err_ext_vsa_raman_1064.'); 

% tropos. vs
netcdf.putAtt(ncID_raman, varID_err_ext_vst_raman_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_vst_raman_355, 'long_name', 'Error tropospheric volcanic sulfate ext. coeff. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_vst_raman_355, 'standard_name', 'err_ext_vst_raman_355.');

netcdf.putAtt(ncID_raman, varID_err_ext_vst_raman_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_vst_raman_532, 'long_name', 'Error tropospheric volcanic sulfate ext. coeff. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_vst_raman_532, 'standard_name', 'err_ext_vst_raman_532.');

netcdf.putAtt(ncID_raman, varID_err_ext_vst_raman_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_err_ext_vst_raman_1064, 'long_name', 'Error tropospheric volcanic sulfate ext. coeff. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_ext_vst_raman_1064, 'standard_name', 'err_ext_vst_raman_1064.');

% mass
% dust

netcdf.putAtt(ncID_raman, varID_err_m_d_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_d_raman_355, 'long_name', 'Error Dust mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_d_raman_355, 'standard_name', 'err_m_d_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_err_m_d_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_d_raman_532, 'long_name', 'Error Dust mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_d_raman_532, 'standard_name', 'err_m_d_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_err_m_d_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_d_raman_1064, 'long_name', 'Error Dust mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_d_raman_1064, 'standard_name', 'err_m_d_raman_1064.'); 

% coarse dust
netcdf.putAtt(ncID_raman, varID_err_m_cd_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_cd_raman_355, 'long_name', 'Error Coarse Dust mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_cd_raman_355, 'standard_name', 'err_m_cd_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_err_m_cd_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_cd_raman_532, 'long_name', 'Error Coarse Dust mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_cd_raman_532, 'standard_name', 'err_m_cd_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_err_m_cd_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_cd_raman_1064, 'long_name', 'Error Coarse Dust mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_cd_raman_1064, 'standard_name', 'err_m_cd_raman_1064.'); 

% fine dust
netcdf.putAtt(ncID_raman, varID_err_m_fd_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_fd_raman_355, 'long_name', 'Error Fine Dust mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_fd_raman_355, 'standard_name', 'err_m_fd_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_err_m_fd_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_fd_raman_532, 'long_name', 'Error Fine Dust mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_fd_raman_532, 'standard_name', 'err_m_fd_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_err_m_fd_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_fd_raman_1064, 'long_name', 'Error Fine Dust mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_fd_raman_1064, 'standard_name', 'err_m_fd_raman_1064.'); 

% marine 
netcdf.putAtt(ncID_raman, varID_err_m_ndm_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_ndm_raman_355, 'long_name', 'Error Non-Dust marine mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_ndm_raman_355, 'standard_name', 'err_m_ndm_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_err_m_ndm_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_ndm_raman_532, 'long_name', 'Error Non-Dust marine mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_ndm_raman_532, 'standard_name', 'err_m_ndm_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_err_m_ndm_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_ndm_raman_1064, 'long_name', 'Error Non-Dust marine mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_ndm_raman_1064, 'standard_name', 'err_m_ndm_raman_1064.'); 

% smoke
netcdf.putAtt(ncID_raman, varID_err_m_nds_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_nds_raman_355, 'long_name', 'Error Non-Dust smoke mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_nds_raman_355, 'standard_name', 'err_m_nds_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_err_m_nds_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_nds_raman_532, 'long_name', 'Error Non-Dust smoke mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_nds_raman_532, 'standard_name', 'err_m_nds_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_err_m_nds_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_nds_raman_1064, 'long_name', 'Error Non-Dust smoke mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_nds_raman_1064, 'standard_name', 'err_m_nds_raman_1064.'); 

% biomass burning
netcdf.putAtt(ncID_raman, varID_err_m_bb_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_bb_raman_355, 'long_name', 'Error Biomass burning mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_bb_raman_355, 'standard_name', 'err_m_bb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_err_m_bb_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_bb_raman_532, 'long_name', 'Error Biomass burning mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_bb_raman_532, 'standard_name', 'err_m_bb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_err_m_bb_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_bb_raman_1064, 'long_name', 'Error Biomass burning mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_bb_raman_1064, 'standard_name', 'err_m_bb_raman_1064.'); 

% fresh vs
netcdf.putAtt(ncID_raman, varID_err_m_vsf_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_vsf_raman_355, 'long_name', 'Error fresh volcanic sulfate mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_vsf_raman_355, 'standard_name', 'err_m_vsf_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_err_m_vsf_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_vsf_raman_532, 'long_name', 'Error fresh volcanic sulfate mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_vsf_raman_532, 'standard_name', 'err_m_vsf_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_err_m_vsf_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_vsf_raman_1064, 'long_name', 'Error fresh volcanic sulfate mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_vsf_raman_1064, 'standard_name', 'err_m_vsf_raman_1064.'); 

% aged vs
netcdf.putAtt(ncID_raman, varID_err_m_vsa_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_vsa_raman_355, 'long_name', 'Error aged volcanic sulfate mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_vsa_raman_355, 'standard_name', 'err_m_vsa_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_err_m_vsa_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_vsa_raman_532, 'long_name', 'Error aged volcanic sulfate mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_vsa_raman_532, 'standard_name', 'err_m_vsa_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_err_m_vsa_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_vsa_raman_1064, 'long_name', 'Error aged volcanic sulfate mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_vsa_raman_1064, 'standard_name', 'err_m_vsa_raman_1064.'); 

% tropos. vs
netcdf.putAtt(ncID_raman, varID_err_m_vst_raman_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_vst_raman_355, 'long_name', 'Error tropospheric volcanic sulfate mass conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_vst_raman_355, 'standard_name', 'err_m_vst_raman_355.');

netcdf.putAtt(ncID_raman, varID_err_m_vst_raman_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_vst_raman_532, 'long_name', 'Error tropospheric volcanic sulfate mass conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_vst_raman_532, 'standard_name', 'err_m_vst_raman_532.');

netcdf.putAtt(ncID_raman, varID_err_m_vst_raman_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_err_m_vst_raman_1064, 'long_name', 'Error tropospheric volcanic sulfate mass conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_err_m_vst_raman_1064, 'standard_name', 'err_m_vst_raman_1064.');

% CCN
% total
netcdf.putAtt(ncID_raman, varID_n_ccn_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_raman_355, 'long_name', 'Total CCN Conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_raman_355, 'standard_name', 'n_ccn_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_ccn_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_raman_532, 'long_name', 'Total CCN Conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_raman_532, 'standard_name', 'n_ccn_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_ccn_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_raman_1064, 'long_name', 'Total CCN Conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_raman_1064, 'standard_name', 'n_ccn_raman_1064.'); 

% dust
netcdf.putAtt(ncID_raman, varID_n_ccn_d_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_d_raman_355, 'long_name', 'Dust CCN Conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_d_raman_355, 'standard_name', 'n_ccn_d_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_ccn_d_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_d_raman_532, 'long_name', 'Dust CCN Conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_d_raman_532, 'standard_name', 'n_ccn_d_raman_532.'); 


netcdf.putAtt(ncID_raman, varID_n_ccn_d_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_d_raman_1064, 'long_name', 'Dust CCN Conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_d_raman_1064, 'standard_name', 'n_ccn_d_raman_1064.'); 

% continental
netcdf.putAtt(ncID_raman, varID_n_ccn_c_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_c_raman_355, 'long_name', 'Continental CCN Conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_c_raman_355, 'standard_name', 'n_ccn_c_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_ccn_c_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_c_raman_532, 'long_name', 'Continental CCN Conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_c_raman_532, 'standard_name', 'n_ccn_c_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_ccn_c_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_c_raman_1064, 'long_name', 'Continental CCN Conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_c_raman_1064, 'standard_name', 'n_ccn_c_raman_1064.'); 

% marine
netcdf.putAtt(ncID_raman, varID_n_ccn_m_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_m_raman_355, 'long_name', 'Marine CCN Conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_m_raman_355, 'standard_name', 'n_ccn_m_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_ccn_m_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_m_raman_532, 'long_name', 'Marine CCN Conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_m_raman_532, 'standard_name', 'n_ccn_m_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_ccn_m_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_m_raman_1064, 'long_name', 'Marine CCN Conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_m_raman_1064, 'standard_name', 'n_ccn_m_raman_1064.'); 

% biomass burnig
netcdf.putAtt(ncID_raman, varID_n_ccn_bb_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_bb_raman_355, 'long_name', 'Biomass Burning CCN Conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_bb_raman_355, 'standard_name', 'n_ccn_bb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_ccn_bb_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_bb_raman_532, 'long_name', 'Biomass Burning CCN Conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_bb_raman_532, 'standard_name', 'n_ccn_bb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_ccn_bb_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_bb_raman_1064, 'long_name', 'Biomass Burning CCN Conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_bb_raman_1064, 'standard_name', 'n_ccn_bb_raman_1064.'); 

% fresh vs
netcdf.putAtt(ncID_raman, varID_n_ccn_vsf_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vsf_raman_355, 'long_name', 'Fresh Volcanic Sulfate CCN Conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vsf_raman_355, 'standard_name', 'n_ccn_vsf_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_ccn_vsf_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vsf_raman_532, 'long_name', 'Fresh Volcanic Sulfate CCN Conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vsf_raman_532, 'standard_name', 'n_ccn_vsf_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_ccn_vsf_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vsf_raman_1064, 'long_name', 'Fresh Volcanic Sulfate CCN Conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vsf_raman_1064, 'standard_name', 'n_ccn_vsf_raman_1064.'); 

% aged vs
netcdf.putAtt(ncID_raman, varID_n_ccn_vsa_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vsa_raman_355, 'long_name', 'Aged Volcanic Sulfate CCN Conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vsa_raman_355, 'standard_name', 'n_ccn_vsa_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_ccn_vsa_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vsa_raman_532, 'long_name', 'Aged Volcanic Sulfate CCN Conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vsa_raman_532, 'standard_name', 'n_ccn_vsa_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_ccn_vsa_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vsa_raman_1064, 'long_name', 'Aged Volcanic Sulfate CCN Conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vsa_raman_1064, 'standard_name', 'n_ccn_vsa_raman_1064.');

% tropos. vs
netcdf.putAtt(ncID_raman, varID_n_ccn_vst_raman_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vst_raman_355, 'long_name', 'Trop. Volcanic Sulfate CCN Conc. 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vst_raman_355, 'standard_name', 'n_ccn_vst_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_ccn_vst_raman_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vst_raman_532, 'long_name', 'Trop. Volcanic Sulfate CCN Conc. 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vst_raman_532, 'standard_name', 'n_ccn_vst_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_ccn_vst_raman_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vst_raman_1064, 'long_name', 'Trop. Volcanic Sulfate CCN Conc. 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_ccn_vst_raman_1064, 'standard_name', 'n_ccn_vst_raman_1064.'); 

% INP

% Dust INP DeMott 2010
netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_amb_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_amb_raman_355, 'long_name', 'Dust INP DeMott 2010 (Amb) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_amb_raman_355, 'standard_name', 'n_inp_d_d10_amb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_amb_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_amb_raman_532, 'long_name', 'Dust INP DeMott 2010 (Amb) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_amb_raman_532, 'standard_name', 'n_inp_d_d10_amb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_amb_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_amb_raman_1064, 'long_name', 'Dust INP DeMott 2010 (Amb) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_amb_raman_1064, 'standard_name', 'n_inp_d_d10_amb_raman_1064.'); 

% Dust INP DeMott 2015
netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_amb_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_amb_raman_355, 'long_name', 'Dust INP DeMott 2015 (Amb) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_amb_raman_355, 'standard_name', 'n_inp_d_d15_amb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_amb_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_amb_raman_532, 'long_name', 'Dust INP DeMott 2015 (Amb) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_amb_raman_532, 'standard_name', 'n_inp_d_d15_amb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_amb_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_amb_raman_1064, 'long_name', 'Dust INP DeMott 2015 (Amb) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_amb_raman_1064, 'standard_name', 'n_inp_d_d15_amb_raman_1064.'); 

% Dust INP Niemand 2012
netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_amb_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_amb_raman_355, 'long_name', 'Dust INP Niemand 2012 (Amb) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_amb_raman_355, 'standard_name', 'n_inp_d_n12_amb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_amb_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_amb_raman_532, 'long_name', 'Dust INP Niemand 2012 (Amb) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_amb_raman_532, 'standard_name', 'n_inp_d_n12_amb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_amb_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_amb_raman_1064, 'long_name', 'Dust INP Niemand 2012 (Amb) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_amb_raman_1064, 'standard_name', 'n_inp_d_n12_amb_raman_1064.'); 

% Dust INP Steinke 2015
netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_amb_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_amb_raman_355, 'long_name', 'Dust INP Steinke 2015 (Amb) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_amb_raman_355, 'standard_name', 'n_inp_d_s15_amb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_amb_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_amb_raman_532, 'long_name', 'Dust INP Steinke 2015 (Amb) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_amb_raman_532, 'standard_name', 'n_inp_d_s15_amb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_amb_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_amb_raman_1064, 'long_name', 'Dust INP Steinke 2015 (Amb) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_amb_raman_1064, 'standard_name', 'n_inp_d_s15_amb_raman_1064.'); 

% Dust INP DeMott 2010 
netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_raman_355, 'long_name', 'Dust INP DeMott 2010 (Fixed) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_raman_355, 'standard_name', 'n_inp_d_d10_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_raman_532, 'long_name', 'Dust INP DeMott 2010 (Fixed) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_raman_532, 'standard_name', 'n_inp_d_d10_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_raman_1064, 'long_name', 'Dust INP DeMott 2010 (Fixed) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d10_raman_1064, 'standard_name', 'n_inp_d_d10_raman_1064.'); 

% Dust INP DeMott 2015
netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_raman_355, 'long_name', 'Dust INP DeMott 2015 (Fixed) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_raman_355, 'standard_name', 'n_inp_d_d15_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_raman_532, 'long_name', 'Dust INP DeMott 2015 (Fixed) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_raman_532, 'standard_name', 'n_inp_d_d15_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_raman_1064, 'long_name', 'Dust INP DeMott 2015 (Fixed) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_d15_raman_1064, 'standard_name', 'n_inp_d_d15_raman_1064.'); 

% Dust INP Niemand 2012 
netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_raman_355, 'long_name', 'Dust INP Niemand 2012 (Fixed) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_raman_355, 'standard_name', 'n_inp_d_n12_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_raman_532, 'long_name', 'Dust INP Niemand 2012 (Fixed) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_raman_532, 'standard_name', 'n_inp_d_n12_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_raman_1064, 'long_name', 'Dust INP Niemand 2012 (Fixed) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_n12_raman_1064, 'standard_name', 'n_inp_d_n12_raman_1064.'); 

% Dust INP Steinke 2015
netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_raman_355, 'long_name', 'Dust INP Steinke 2015 (Fixed) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_raman_355, 'standard_name', 'n_inp_d_s15_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_raman_532, 'long_name', 'Dust INP Steinke 2015 (Fixed) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_raman_532, 'standard_name', 'n_inp_d_s15_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_raman_1064, 'long_name', 'Dust INP Steinke 2015 (Fixed) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_d_s15_raman_1064, 'standard_name', 'n_inp_d_s15_raman_1064.'); 

% Continental INP DeMott 2010
netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_amb_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_amb_raman_355, 'long_name', 'Continental INP DeMott 2010 (Amb) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_amb_raman_355, 'standard_name', 'n_inp_c_d10_amb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_amb_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_amb_raman_532, 'long_name', 'Continental INP DeMott 2010 (Amb) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_amb_raman_532, 'standard_name', 'n_inp_c_d10_amb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_amb_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_amb_raman_1064, 'long_name', 'Continental INP DeMott 2010 (Amb) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_amb_raman_1064, 'standard_name', 'n_inp_c_d10_amb_raman_1064.'); 

% Continental INP DeMott 2010
netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_raman_355, 'long_name', 'Continental INP DeMott 2010 (Fixed) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_raman_355, 'standard_name', 'n_inp_c_d10_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_raman_532, 'long_name', 'Continental INP DeMott 2010 (Fixed) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_raman_532, 'standard_name', 'n_inp_c_d10_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_raman_1064, 'long_name', 'Continental INP DeMott 2010 (Fixed) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_c_d10_raman_1064, 'standard_name', 'n_inp_c_d10_raman_1064.'); 

% Marine INP DeMott 2010 
netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_amb_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_amb_raman_355, 'long_name', 'Marine INP DeMott 2010 (Amb) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_amb_raman_355, 'standard_name', 'n_inp_m_d10_amb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_amb_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_amb_raman_532, 'long_name', 'Marine INP DeMott 2010 (Amb) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_amb_raman_532, 'standard_name', 'n_inp_m_d10_amb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_amb_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_amb_raman_1064, 'long_name', 'Marine INP DeMott 2010 (Amb) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_amb_raman_1064, 'standard_name', 'n_inp_m_d10_amb_raman_1064.'); 

% Marine INP DeMott 2010 
netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_raman_355, 'long_name', 'Marine INP DeMott 2010 (Fixed) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_raman_355, 'standard_name', 'n_inp_m_d10_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_raman_532, 'long_name', 'Marine INP DeMott 2010 (Fixed) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_raman_532, 'standard_name', 'n_inp_m_d10_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_raman_1064, 'long_name', 'Marine INP DeMott 2010 (Fixed) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_m_d10_raman_1064, 'standard_name', 'n_inp_m_d10_raman_1064.'); 

% Biomass Burning INP DeMott 2010 
netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_amb_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_amb_raman_355, 'long_name', 'Biomass Burning INP DeMott 2010 (Amb) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_amb_raman_355, 'standard_name', 'inp_bb_d10_amb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_amb_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_amb_raman_532, 'long_name', 'Biomass Burning INP DeMott 2010 (Amb) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_amb_raman_532, 'standard_name', 'INPbb_d10_amb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_amb_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_amb_raman_1064, 'long_name', 'Biomass Burning INP DeMott 2010 (Amb) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_amb_raman_1064, 'standard_name', 'INPbb_d10_amb_raman_1064.'); 

% Biomass Burning INP DeMott 2010
netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_raman_355, 'long_name', 'Biomass Burning INP DeMott 2010 (Fixed) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_raman_355, 'standard_name', 'INPbb_d10_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_raman_532, 'long_name', 'Biomass Burning INP DeMott 2010 (Fixed) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_raman_532, 'standard_name', 'INPbb_d10_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_raman_1064, 'long_name', 'Biomass Burning INP DeMott 2010 (Fixed) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_bb_d10_raman_1064, 'standard_name', 'INPbb_d10_raman_1064.'); 

% Fresh Volc. INP DeMott 2010
netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_amb_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_amb_raman_355, 'long_name', 'Fresh Volc. INP DeMott 2010 (Amb) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_amb_raman_355, 'standard_name', 'INPvsf_d10_amb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_amb_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_amb_raman_532, 'long_name', 'Fresh Volc. INP DeMott 2010 (Amb) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_amb_raman_532, 'standard_name', 'INPvsf_d10_amb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_amb_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_amb_raman_1064, 'long_name', 'Fresh Volc. INP DeMott 2010 (Amb) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_amb_raman_1064, 'standard_name', 'INPvsf_d10_amb_raman_1064.'); 

% Fresh Volc. INP DeMott 2010
netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_raman_355, 'long_name', 'Fresh Volc. INP DeMott 2010 (Fixed) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_raman_355, 'standard_name', 'INPvsf_d10_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_raman_532, 'long_name', 'Fresh Volc. INP DeMott 2010 (Fixed) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_raman_532, 'standard_name', 'INPvsf_d10_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_raman_1064, 'long_name', 'Fresh Volc. INP DeMott 2010 (Fixed) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsf_d10_raman_1064, 'standard_name', 'INPvsf_d10_raman_1064.'); 

% Aged Volc. INP DeMott 2010
netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_amb_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_amb_raman_355, 'long_name', 'Aged Volc. INP DeMott 2010 (Amb) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_amb_raman_355, 'standard_name', 'INPvsa_d10_amb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_amb_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_amb_raman_532, 'long_name', 'Aged Volc. INP DeMott 2010 (Amb) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_amb_raman_532, 'standard_name', 'INPvsa_d10_amb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_amb_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_amb_raman_1064, 'long_name', 'Aged Volc. INP DeMott 2010 (Amb) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_amb_raman_1064, 'standard_name', 'INPvsa_d10_amb_raman_1064.'); 

% Aged Volc. INP DeMott 2010 
netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_raman_355, 'long_name', 'Aged Volc. INP DeMott 2010 (Fixed) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_raman_355, 'standard_name', 'INPvsa_d10_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_raman_532, 'long_name', 'Aged Volc. INP DeMott 2010 (Fixed) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_raman_532, 'standard_name', 'INPvsa_d10_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_raman_1064, 'long_name', 'Aged Volc. INP DeMott 2010 (Fixed) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vsa_d10_raman_1064, 'standard_name', 'INPvsa_d10_raman_1064.'); 

% Trop. Volc. INP DeMott 2010
netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_amb_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_amb_raman_355, 'long_name', 'Trop. Volc. INP DeMott 2010 (Amb) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_amb_raman_355, 'standard_name', 'INPvst_d10_amb_raman_355.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_amb_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_amb_raman_532, 'long_name', 'Trop. Volc. INP DeMott 2010 (Amb) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_amb_raman_532, 'standard_name', 'INPvst_d10_amb_raman_532.'); 

netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_amb_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_amb_raman_1064, 'long_name', 'Trop. Volc. INP DeMott 2010 (Amb) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_amb_raman_1064, 'standard_name', 'INPvst_d10_amb_raman_1064.'); 

% Trop. Volc. INP DeMott 2010 
netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_raman_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_raman_355, 'long_name', 'Trop. Volc. INP DeMott 2010 (Fixed) 355 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_raman_355, 'standard_name', 'INPvst_d10_raman_355.');

netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_raman_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_raman_532, 'long_name', 'Trop. Volc. INP DeMott 2010 (Fixed) 532 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_raman_532, 'standard_name', 'INPvst_d10_raman_532.');

netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_raman_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_raman_1064, 'long_name', 'Trop. Volc. INP DeMott 2010 (Fixed) 1064 nm raman');  
netcdf.putAtt(ncID_raman, varID_n_inp_vst_d10_raman_1064, 'standard_name', 'INPvst_d10_raman_1064.');
%% raman 355
% aerBsc_raman_355
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_355, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_355, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_355, 'long_name', 'aerosol backscatter coefficient at 355 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_355, 'standard_name', 'beta (aer, 355 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_355, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_355, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID_raman, varID_aerBsc_raman_355, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta355 * 1e6, PollyConfig.heightFullOverlap(flagCh355FR), PollyConfig.maxDecomHeight355, PollyConfig.smoothWin_raman_355 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_355, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% aerBscStd_raman_355
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_355, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_355, 'long_name', 'uncertainty of aerosol backscatter coefficient at 355 nm');
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_355, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_355, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_355, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta355 * 1e6, PollyConfig.heightFullOverlap(flagCh355FR), PollyConfig.maxDecomHeight355, PollyConfig.smoothWin_raman_355 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_355, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% varID_aerBsc355_raman_d2
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_d2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_d2, 'long_name', 'two-step dust particle backscatter coefficient at 355 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_d2, 'standard_name', 'beta dust (aer, 355 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_d2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_d2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_d2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc355_raman_d2
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_d2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_d2, 'long_name', 'uncertainty of two-step dust particle backscatter coefficient at 355 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_d2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_d2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_d2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_d2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc355_raman_dc2
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_dc2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_dc2, 'long_name', 'two-step coarse-dust particle backscatter coefficient at 355 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_dc2, 'standard_name', 'beta dust (aer, 355 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_dc2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_dc2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_dc2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc355_raman_dc2
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_dc2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_dc2, 'long_name', 'uncertainty of two-step coarse-dust particle backscatter coefficient at 355 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_dc2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_dc2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_dc2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_dc2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc355_raman_df2
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_df2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_df2, 'long_name', 'two-step fine-dust particle backscatter coefficient at 355 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_df2, 'standard_name', 'beta dust (aer, 355 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_df2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_df2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_df2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc355_raman_df2
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_df2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_df2, 'long_name', 'uncertainty of two-step fine-dust particle backscatter coefficient at 355 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_df2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_df2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_df2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_df2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc355_raman_nddf2
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_nddf2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_nddf2, 'long_name', 'two-step non-dust/ fine-dust particle backscatter coefficient at 355 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_nddf2, 'standard_name', 'beta dust (aer, 355 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_nddf2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_nddf2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_nddf2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc355_raman_nddf2
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_nddf2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_nddf2, 'long_name', 'uncertainty of two-step non-dust/ fine-dust particle backscatter coefficient at 355 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_nddf2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_nddf2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_nddf2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_nddf2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc355_raman_nd2
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_nd2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_nd2, 'long_name', 'two-step non-dust particle backscatter coefficient at 355 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_nd2, 'standard_name', 'beta dust (aer, 355 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_nd2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_nd2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_aerBsc355_raman_nd2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc355_raman_nd2
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_nd2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_nd2, 'long_name', 'uncertainty of two-step non-dust particle backscatter coefficient at 355 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_nd2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_nd2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_nd2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_err_aerBsc355_raman_nd2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

%% raman 532
% aerBsc_raman_532
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_532, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_532, 'standard_name', 'beta (aer, 532 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_532, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_532, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID_raman, varID_aerBsc_raman_532, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta532 * 1e6, PollyConfig.heightFullOverlap(flagCh532FR), PollyConfig.maxDecomHeight532, PollyConfig.smoothWin_raman_532 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_532, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% aerBscStd_raman_532
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_532, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_532, 'long_name', 'uncertainty of aerosol backscatter coefficient at 532 nm');
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_532, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_532, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_532, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta532 * 1e6, PollyConfig.heightFullOverlap(flagCh532FR), PollyConfig.maxDecomHeight532, PollyConfig.smoothWin_raman_532 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_532, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% varID_aerBsc532_raman_d2
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_d2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_d2, 'long_name', 'two-step dust particle backscatter coefficient at 532 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_d2, 'standard_name', 'beta dust (aer, 532 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_d2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_d2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_d2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc532_raman_d2
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_d2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_d2, 'long_name', 'uncertainty of two-step dust particle backscatter coefficient at 532 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_d2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_d2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_d2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_d2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc532_raman_dc2
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_dc2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_dc2, 'long_name', 'two-step coarse-dust particle backscatter coefficient at 532 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_dc2, 'standard_name', 'beta dust (aer, 532 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_dc2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_dc2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_dc2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc532_raman_dc2
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_dc2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_dc2, 'long_name', 'uncertainty of two-step coarse-dust particle backscatter coefficient at 532 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_dc2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_dc2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_dc2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_dc2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc532_raman_df2
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_df2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_df2, 'long_name', 'two-step fine-dust particle backscatter coefficient at 532 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_df2, 'standard_name', 'beta dust (aer, 532 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_df2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_df2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_df2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc532_raman_df2
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_df2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_df2, 'long_name', 'uncertainty of two-step fine-dust particle backscatter coefficient at 532 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_df2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_df2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_df2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_df2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc532_raman_nddf2
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_nddf2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_nddf2, 'long_name', 'two-step non-dust/ fine-dust particle backscatter coefficient at 532 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_nddf2, 'standard_name', 'beta dust (aer, 532 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_nddf2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_nddf2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_nddf2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc532_raman_nddf2
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_nddf2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_nddf2, 'long_name', 'uncertainty of two-step non-dust/ fine-dust particle backscatter coefficient at 532 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_nddf2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_nddf2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_nddf2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_nddf2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc532_raman_nd2
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_nd2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_nd2, 'long_name', 'two-step non-dust particle backscatter coefficient at 532 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_nd2, 'standard_name', 'beta dust (aer, 532 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_nd2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_nd2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_aerBsc532_raman_nd2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc532_raman_nd2
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_nd2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_nd2, 'long_name', 'uncertainty of two-step non-dust particle backscatter coefficient at 532 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_nd2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_nd2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_nd2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_err_aerBsc532_raman_nd2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

%% raman 1064
% aerBsc_raman_1064
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_1064, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_1064, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_1064, 'long_name', 'aerosol backscatter coefficient at 1064 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_1064, 'standard_name', 'beta (aer, 1064 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_1064, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_1064, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID_raman, varID_aerBsc_raman_1064, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta1064 * 1e6, PollyConfig.heightFullOverlap(flagCh1064FR), PollyConfig.maxDecomHeight1064, PollyConfig.smoothWin_raman_1064 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID_raman, varID_aerBsc_raman_1064, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% aerBscStd_raman_1064
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_1064, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_1064, 'long_name', 'uncertainty of aerosol backscatter coefficient at 1064 nm');
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_1064, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_1064, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_1064, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta1064 * 1e6, PollyConfig.heightFullOverlap(flagCh1064FR), PollyConfig.maxDecomHeight1064, PollyConfig.smoothWin_raman_1064 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID_raman, varID_aerBscStd_raman_1064, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% varID_aerBsc1064_raman_d2
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_d2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_d2, 'long_name', 'two-step dust particle backscatter coefficient at 1064 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_d2, 'standard_name', 'beta dust (aer, 1064 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_d2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_d2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_d2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc1064_raman_d2
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_d2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_d2, 'long_name', 'uncertainty of two-step dust particle backscatter coefficient at 1064 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_d2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_d2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_d2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_d2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc1064_raman_dc2
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_dc2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_dc2, 'long_name', 'two-step coarse-dust particle backscatter coefficient at 1064 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_dc2, 'standard_name', 'beta dust (aer, 1064 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_dc2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_dc2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_dc2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc1064_raman_dc2
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_dc2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_dc2, 'long_name', 'uncertainty of two-step coarse-dust particle backscatter coefficient at 1064 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_dc2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_dc2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_dc2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_dc2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc1064_raman_df2
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_df2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_df2, 'long_name', 'two-step fine-dust particle backscatter coefficient at 1064 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_df2, 'standard_name', 'beta dust (aer, 1064 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_df2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_df2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_df2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc1064_raman_df2
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_df2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_df2, 'long_name', 'uncertainty of two-step fine-dust particle backscatter coefficient at 1064 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_df2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_df2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_df2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_df2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc1064_raman_nddf2
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_nddf2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_nddf2, 'long_name', 'two-step non-dust/ fine-dust particle backscatter coefficient at 1064 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_nddf2, 'standard_name', 'beta dust (aer, 1064 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_nddf2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_nddf2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_nddf2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc1064_raman_nddf2
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_nddf2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_nddf2, 'long_name', 'uncertainty of two-step non-dust/ fine-dust particle backscatter coefficient at 1064 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_nddf2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_nddf2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_nddf2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_nddf2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc1064_raman_nd2
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_nd2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_nd2, 'long_name', 'two-step non-dust particle backscatter coefficient at 1064 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_nd2, 'standard_name', 'beta dust (aer, 1064 nm)');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_nd2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_nd2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_aerBsc1064_raman_nd2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc1064_raman_nd2
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_nd2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_nd2, 'long_name', 'uncertainty of two-step non-dust particle backscatter coefficient at 1064 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_nd2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_nd2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_nd2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_err_aerBsc1064_raman_nd2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));




%% Extinction, Mass, Surface Arean, CCN, INP,.. Klett

% extinction
% dust
netcdf.putAtt(ncID_klett, varID_ext_d_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_d_klett_355, 'long_name', 'Dust ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_d_klett_355, 'standard_name', 'Ad_klett_355.');  

netcdf.putAtt(ncID_klett, varID_ext_d_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_d_klett_532, 'long_name', 'Dust ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_d_klett_532, 'standard_name', 'Ad_klett_532.');  

netcdf.putAtt(ncID_klett, varID_ext_d_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_d_klett_1064, 'long_name', 'Dust ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_d_klett_1064, 'standard_name', 'Ad_klett_1064.');  

% coarse dust
netcdf.putAtt(ncID_klett, varID_ext_cd_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_cd_klett_355, 'long_name', 'Coarse Dust ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_cd_klett_355, 'standard_name', 'Acd_klett_355.'); 


netcdf.putAtt(ncID_klett, varID_ext_cd_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_cd_klett_532, 'long_name', 'Coarse Dust ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_cd_klett_532, 'standard_name', 'Acd_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_ext_cd_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_cd_klett_1064, 'long_name', 'Coarse Dust ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_cd_klett_1064, 'standard_name', 'Acd_klett_1064.'); 

% fine dust
netcdf.putAtt(ncID_klett, varID_ext_fd_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_fd_klett_355, 'long_name', 'Fine Dust ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_fd_klett_355, 'standard_name', 'Afd_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_ext_fd_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_fd_klett_532, 'long_name', 'Fine Dust ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_fd_klett_532, 'standard_name', 'Afd_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_ext_fd_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_fd_klett_1064, 'long_name', 'Fine Dust ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_fd_klett_1064, 'standard_name', 'Afd_klett_1064.'); 

% non-dust marine
netcdf.putAtt(ncID_klett, varID_ext_ndm_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_ndm_klett_355, 'long_name', 'Non-Dust marine ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_ndm_klett_355, 'standard_name', 'Andm1_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_ext_ndm_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_ndm_klett_532, 'long_name', 'Non-Dust marine ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_ndm_klett_532, 'standard_name', 'Andm1_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_ext_ndm_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_ndm_klett_1064, 'long_name', 'Non-Dust marine ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_ndm_klett_1064, 'standard_name', 'Andm1_klett_1064.'); 

% non-dust smoke
netcdf.putAtt(ncID_klett, varID_ext_nds_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_nds_klett_355, 'long_name', 'Non-Dust smoke ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_nds_klett_355, 'standard_name', 'Ands1_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_ext_nds_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_nds_klett_532, 'long_name', 'Non-Dust smoke ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_nds_klett_532, 'standard_name', 'Ands1_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_ext_nds_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_nds_klett_1064, 'long_name', 'Non-Dust smoke ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_nds_klett_1064, 'standard_name', 'Ands1_klett_1064.'); 

% biomass burning
netcdf.putAtt(ncID_klett, varID_ext_bb_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_bb_klett_355, 'long_name', 'Biomass burning smoke ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_bb_klett_355, 'standard_name', 'Abb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_ext_bb_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_bb_klett_532, 'long_name', 'Biomass burning smoke ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_bb_klett_532, 'standard_name', 'Abb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_ext_bb_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_bb_klett_1064, 'long_name', 'Biomass burning smoke ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_bb_klett_1064, 'standard_name', 'Abb_klett_1064.'); 

% fresh volcanic sulfate
netcdf.putAtt(ncID_klett, varID_ext_vsf_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_vsf_klett_355, 'long_name', 'fresh volcanic sulfate ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_vsf_klett_355, 'standard_name', 'Avsf_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_ext_vsf_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_vsf_klett_532, 'long_name', 'fresh volcanic sulfate ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_vsf_klett_532, 'standard_name', 'Avsf_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_ext_vsf_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_vsf_klett_1064, 'long_name', 'fresh volcanic sulfate ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_vsf_klett_1064, 'standard_name', 'Avsf_klett_1064.'); 

% aged volcanic sulfate
netcdf.putAtt(ncID_klett, varID_ext_vsa_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_vsa_klett_355, 'long_name', 'aged volcanic sulfate ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_vsa_klett_355, 'standard_name', 'Avsa_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_ext_vsa_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_vsa_klett_532, 'long_name', 'aged volcanic sulfate ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_vsa_klett_532, 'standard_name', 'Avsa_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_ext_vsa_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_vsa_klett_1064, 'long_name', 'aged volcanic sulfate ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_vsa_klett_1064, 'standard_name', 'Avsa_klett_1064.'); 

% tropospheric volcanic sulfate
netcdf.putAtt(ncID_klett, varID_ext_vst_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_vst_klett_355, 'long_name', 'tropospheric volcanic sulfate ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_vst_klett_355, 'standard_name', 'Avst_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_ext_vst_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_vst_klett_532, 'long_name', 'tropospheric volcanic sulfate ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_vst_klett_532, 'standard_name', 'Avst_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_ext_vst_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_ext_vst_klett_1064, 'long_name', 'tropospheric volcanic sulfate ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_ext_vst_klett_1064, 'standard_name', 'Avst_klett_1064.'); 

% mass 

% dust
netcdf.putAtt(ncID_klett, varID_m_d_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_d_klett_355, 'long_name', 'Dust mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_d_klett_355, 'standard_name', 'm_d_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_m_d_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_d_klett_532, 'long_name', 'Dust mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_d_klett_532, 'standard_name', 'm_d_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_m_d_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_d_klett_1064, 'long_name', 'Dust mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_d_klett_1064, 'standard_name', 'm_d_klett_1064.'); 

% coarse dust
netcdf.putAtt(ncID_klett, varID_m_cd_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_cd_klett_355, 'long_name', 'Coarse Dust mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_cd_klett_355, 'standard_name', 'm_cd_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_m_cd_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_cd_klett_532, 'long_name', 'Coarse Dust mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_cd_klett_532, 'standard_name', 'm_cd_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_m_cd_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_cd_klett_1064, 'long_name', 'Coarse Dust mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_cd_klett_1064, 'standard_name', 'm_cd_klett_1064.'); 

% fine dust
netcdf.putAtt(ncID_klett, varID_m_fd_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_fd_klett_355, 'long_name', 'Fine Dust mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_fd_klett_355, 'standard_name', 'm_fd_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_m_fd_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_fd_klett_532, 'long_name', 'Fine Dust mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_fd_klett_532, 'standard_name', 'm_fd_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_m_fd_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_fd_klett_1064, 'long_name', 'Fine Dust mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_fd_klett_1064, 'standard_name', 'm_fd_klett_1064.'); 

% marine
netcdf.putAtt(ncID_klett, varID_m_ndm_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_ndm_klett_355, 'long_name', 'Non-Dust marine mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_ndm_klett_355, 'standard_name', 'm_ndm_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_m_ndm_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_ndm_klett_532, 'long_name', 'Non-Dust marine mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_ndm_klett_532, 'standard_name', 'm_ndm_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_m_ndm_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_ndm_klett_1064, 'long_name', 'Non-Dust marine mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_ndm_klett_1064, 'standard_name', 'm_ndm_klett_1064.'); 

% smoke
netcdf.putAtt(ncID_klett, varID_m_nds_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_nds_klett_355, 'long_name', 'Non-Dust smoke mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_nds_klett_355, 'standard_name', 'm_nds_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_m_nds_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_nds_klett_532, 'long_name', 'Non-Dust smoke mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_nds_klett_532, 'standard_name', 'm_nds_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_m_nds_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_nds_klett_1064, 'long_name', 'Non-Dust smoke mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_nds_klett_1064, 'standard_name', 'm_nds_klett_1064.'); 

% biomass burning
netcdf.putAtt(ncID_klett, varID_m_bb_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_bb_klett_355, 'long_name', 'Biomass burning mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_bb_klett_355, 'standard_name', 'm_bb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_m_bb_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_bb_klett_532, 'long_name', 'Biomass burning mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_bb_klett_532, 'standard_name', 'm_bb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_m_bb_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_bb_klett_1064, 'long_name', 'Biomass burning mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_bb_klett_1064, 'standard_name', 'm_bb_klett_1064.'); 

% vsf
netcdf.putAtt(ncID_klett, varID_m_vsf_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_vsf_klett_355, 'long_name', 'fresh volcanic sulfate mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_vsf_klett_355, 'standard_name', 'm_vsf_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_m_vsf_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_vsf_klett_532, 'long_name', 'fresh volcanic sulfate mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_vsf_klett_532, 'standard_name', 'm_vsf_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_m_vsf_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_vsf_klett_1064, 'long_name', 'fresh volcanic sulfate mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_vsf_klett_1064, 'standard_name', 'm_vsf_klett_1064.'); 

% vsa
netcdf.putAtt(ncID_klett, varID_m_vsa_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_vsa_klett_355, 'long_name', 'aged volcanic sulfate mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_vsa_klett_355, 'standard_name', 'm_vsa_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_m_vsa_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_vsa_klett_532, 'long_name', 'aged volcanic sulfate mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_vsa_klett_532, 'standard_name', 'm_vsa_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_m_vsa_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_vsa_klett_1064, 'long_name', 'aged volcanic sulfate mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_vsa_klett_1064, 'standard_name', 'm_vsa_klett_1064.'); 

% vst
netcdf.putAtt(ncID_klett, varID_m_vst_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_vst_klett_355, 'long_name', 'tropospheric volcanic sulfate mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_vst_klett_355, 'standard_name', 'm_vst_klett_355.');

netcdf.putAtt(ncID_klett, varID_m_vst_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_vst_klett_532, 'long_name', 'tropospheric volcanic sulfate mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_vst_klett_532, 'standard_name', 'm_vst_klett_532.');

netcdf.putAtt(ncID_klett, varID_m_vst_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_m_vst_klett_1064, 'long_name', 'tropospheric volcanic sulfate mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_m_vst_klett_1064, 'standard_name', 'm_vst_klett_1064.');

% number concentrations

% dust 100
netcdf.putAtt(ncID_klett, varID_n_100_d_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_100_d_klett_355, 'long_name', 'Dust Number Conc. >100nm 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_100_d_klett_355, 'standard_name', 'n_100_d_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_100_d_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_100_d_klett_532, 'long_name', 'Dust Number Conc. >100nm 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_100_d_klett_532, 'standard_name', 'n_100_d_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_100_d_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_100_d_klett_1064, 'long_name', 'Dust Number Conc. >100nm 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_100_d_klett_1064, 'standard_name', 'n_100_d_klett_1064.'); 

% dust 250
netcdf.putAtt(ncID_klett, varID_n_250_d_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_d_klett_355, 'long_name', 'Dust Number Conc. >250nm 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_d_klett_355, 'standard_name', 'n_250_d_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_250_d_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_d_klett_532, 'long_name', 'Dust Number Conc. >250nm 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_d_klett_532, 'standard_name', 'n_250_d_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_250_d_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_d_klett_1064, 'long_name', 'Dust Number Conc. >250nm 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_d_klett_1064, 'standard_name', 'n_250_d_klett_1064.'); 

% continental 50
netcdf.putAtt(ncID_klett, varID_n_50_c_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_c_klett_355, 'long_name', 'Continental Number Conc. >50nm 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_c_klett_355, 'standard_name', 'n_50_c_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_50_c_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_c_klett_532, 'long_name', 'Continental Number Conc. >50nm 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_c_klett_532, 'standard_name', 'n_50_c_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_50_c_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_c_klett_1064, 'long_name', 'Continental Number Conc. >50nm 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_c_klett_1064, 'standard_name', 'n_50_c_klett_1064.'); 

% continental 250
netcdf.putAtt(ncID_klett, varID_n_250_c_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_c_klett_355, 'long_name', 'Continental Number Conc. >250nm 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_c_klett_355, 'standard_name', 'n_250_c_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_250_c_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_c_klett_532, 'long_name', 'Continental Number Conc. >250nm 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_c_klett_532, 'standard_name', 'n_250_c_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_250_c_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_c_klett_1064, 'long_name', 'Continental Number Conc. >250nm 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_c_klett_1064, 'standard_name', 'n_250_c_klett_1064.'); 

% marine 50
netcdf.putAtt(ncID_klett, varID_n_50_m_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_m_klett_355, 'long_name', 'Marine Number Conc. >50nm 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_m_klett_355, 'standard_name', 'n_50_m_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_50_m_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_m_klett_532, 'long_name', 'Marine Number Conc. >50nm 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_m_klett_532, 'standard_name', 'n_50_m_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_50_m_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_m_klett_1064, 'long_name', 'Marine Number Conc. >50nm 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_m_klett_1064, 'standard_name', 'n_50_m_klett_1064.'); 

% marine 250
netcdf.putAtt(ncID_klett, varID_n_250_m_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_m_klett_355, 'long_name', 'Marine Number Conc. >250nm 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_m_klett_355, 'standard_name', 'n_250_m_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_250_m_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_m_klett_532, 'long_name', 'Marine Number Conc. >250nm 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_m_klett_532, 'standard_name', 'n_250_m_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_250_m_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_m_klett_1064, 'long_name', 'Marine Number Conc. >250nm 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_m_klett_1064, 'standard_name', 'n_250_m_klett_1064.'); 

% biomass burning 50
netcdf.putAtt(ncID_klett, varID_n_50_bb_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_bb_klett_355, 'long_name', 'Biomass Burning Number Conc. >50nm 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_bb_klett_355, 'standard_name', 'n_50_bb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_50_bb_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_bb_klett_532, 'long_name', 'Biomass Burning Number Conc. >50nm 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_bb_klett_532, 'standard_name', 'n_50_bb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_50_bb_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_bb_klett_1064, 'long_name', 'Biomass Burning Number Conc. >50nm 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_bb_klett_1064, 'standard_name', 'n_50_bb_klett_1064.'); 

% biomass burning 250
netcdf.putAtt(ncID_klett, varID_n_250_bb_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_bb_klett_355, 'long_name', 'Biomass Burning Number Conc. >250nm 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_bb_klett_355, 'standard_name', 'n_250_bb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_250_bb_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_bb_klett_532, 'long_name', 'Biomass Burning Number Conc. >250nm 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_bb_klett_532, 'standard_name', 'n_250_bb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_250_bb_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_bb_klett_1064, 'long_name', 'Biomass Burning Number Conc. >250nm 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_bb_klett_1064, 'standard_name', 'n_250_bb_klett_1064.'); 

% vsf 50
netcdf.putAtt(ncID_klett, varID_n_50_vsf_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_vsf_klett_355, 'long_name', 'Fresh Volcanic Sulfate Number Conc. >50nm 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_vsf_klett_355, 'standard_name', 'n_50_vsf_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_50_vsf_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_vsf_klett_532, 'long_name', 'Fresh Volcanic Sulfate Number Conc. >50nm 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_vsf_klett_532, 'standard_name', 'n_50_vsf_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_50_vsf_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_vsf_klett_1064, 'long_name', 'Fresh Volcanic Sulfate Number Conc. >50nm 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_vsf_klett_1064, 'standard_name', 'n_50_vsf_klett_1064.'); 

% vsf 250
netcdf.putAtt(ncID_klett, varID_n_250_vsf_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_vsf_klett_355, 'long_name', 'Fresh Volcanic Sulfate Number Conc. >250nm 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_vsf_klett_355, 'standard_name', 'n_250_vsf_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_250_vsf_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_vsf_klett_532, 'long_name', 'Fresh Volcanic Sulfate Number Conc. >250nm 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_vsf_klett_532, 'standard_name', 'n_250_vsf_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_250_vsf_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_vsf_klett_1064, 'long_name', 'Fresh Volcanic Sulfate Number Conc. >250nm 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_vsf_klett_1064, 'standard_name', 'n_250_vsf_klett_1064.'); 
% vsa 50
netcdf.putAtt(ncID_klett, varID_n_50_vsa_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_vsa_klett_355, 'long_name', 'Aged Volcanic Sulfate Number Conc. >50nm 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_vsa_klett_355, 'standard_name', 'n_50_vsa_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_50_vsa_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_vsa_klett_532, 'long_name', 'Aged Volcanic Sulfate Number Conc. >50nm 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_vsa_klett_532, 'standard_name', 'n_50_vsa_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_50_vsa_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_vsa_klett_1064, 'long_name', 'Aged Volcanic Sulfate Number Conc. >50nm 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_vsa_klett_1064, 'standard_name', 'n_50_vsa_klett_1064.'); 

% vsa 250
netcdf.putAtt(ncID_klett, varID_n_250_vsa_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_vsa_klett_355, 'long_name', 'Aged Volcanic Sulfate Number Conc. >250nm 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_vsa_klett_355, 'standard_name', 'n_250_vsa_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_250_vsa_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_vsa_klett_532, 'long_name', 'Aged Volcanic Sulfate Number Conc. >250nm 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_vsa_klett_532, 'standard_name', 'n_250_vsa_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_250_vsa_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_vsa_klett_1064, 'long_name', 'Aged Volcanic Sulfate Number Conc. >250nm 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_vsa_klett_1064, 'standard_name', 'n_250_vsa_klett_1064.'); 

% vst 50
netcdf.putAtt(ncID_klett, varID_n_50_vst_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_vst_klett_355, 'long_name', 'Trop. Volcanic Sulfate Number Conc. >50nm 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_vst_klett_355, 'standard_name', 'n_50_vst_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_50_vst_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_vst_klett_532, 'long_name', 'Trop. Volcanic Sulfate Number Conc. >50nm 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_vst_klett_532, 'standard_name', 'n_50_vst_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_50_vst_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_50_vst_klett_1064, 'long_name', 'Trop. Volcanic Sulfate Number Conc. >50nm 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_50_vst_klett_1064, 'standard_name', 'n_50_vst_klett_1064.'); 

% vst 250
netcdf.putAtt(ncID_klett, varID_n_250_vst_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_vst_klett_355, 'long_name', 'Trop. Volcanic Sulfate Number Conc. >250nm 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_vst_klett_355, 'standard_name', 'n_250_vst_klett_355.');

netcdf.putAtt(ncID_klett, varID_n_250_vst_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_vst_klett_532, 'long_name', 'Trop. Volcanic Sulfate Number Conc. >250nm 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_vst_klett_532, 'standard_name', 'n_250_vst_klett_532.');

netcdf.putAtt(ncID_klett, varID_n_250_vst_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_250_vst_klett_1064, 'long_name', 'Trop. Volcanic Sulfate Number Conc. >250nm 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_250_vst_klett_1064, 'standard_name', 'n_250_vst_klett_1064.');

% surface area conc
% dust
netcdf.putAtt(ncID_klett, varID_sa_d_klett_355, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_d_klett_355, 'long_name', 'Dust Surface Area Conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_d_klett_355, 'standard_name', 'sa_d_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_sa_d_klett_532, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_d_klett_532, 'long_name', 'Dust Surface Area Conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_d_klett_532, 'standard_name', 'sa_d_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_sa_d_klett_1064, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_d_klett_1064, 'long_name', 'Dust Surface Area Conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_d_klett_1064, 'standard_name', 'sa_d_klett_1064.'); 
% continental

netcdf.putAtt(ncID_klett, varID_sa_c_klett_355, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_c_klett_355, 'long_name', 'Continental Surface Area Conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_c_klett_355, 'standard_name', 'sa_c_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_sa_c_klett_532, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_c_klett_532, 'long_name', 'Continental Surface Area Conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_c_klett_532, 'standard_name', 'sa_c_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_sa_c_klett_1064, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_c_klett_1064, 'long_name', 'Continental Surface Area Conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_c_klett_1064, 'standard_name', 'sa_c_klett_1064.'); 

% marine
netcdf.putAtt(ncID_klett, varID_sa_m_klett_355, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_m_klett_355, 'long_name', 'Marine Surface Area Conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_m_klett_355, 'standard_name', 'sa_m_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_sa_m_klett_532, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_m_klett_532, 'long_name', 'Marine Surface Area Conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_m_klett_532, 'standard_name', 'sa_m_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_sa_m_klett_1064, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_m_klett_1064, 'long_name', 'Marine Surface Area Conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_m_klett_1064, 'standard_name', 'sa_m_klett_1064.'); 

% biomass burning
netcdf.putAtt(ncID_klett, varID_sa_bb_klett_355, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_bb_klett_355, 'long_name', 'Biomass Burning Surface Area Conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_bb_klett_355, 'standard_name', 'sa_bb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_sa_bb_klett_532, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_bb_klett_532, 'long_name', 'Biomass Burning Surface Area Conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_bb_klett_532, 'standard_name', 'sa_bb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_sa_bb_klett_1064, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_bb_klett_1064, 'long_name', 'Biomass Burning Surface Area Conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_bb_klett_1064, 'standard_name', 'sa_bb_klett_1064.'); 

% fresh volcanic
netcdf.putAtt(ncID_klett, varID_sa_vsf_klett_355, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_vsf_klett_355, 'long_name', 'Fresh Volcanic Sulfate Surface Area Conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_vsf_klett_355, 'standard_name', 'sa_vsf_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_sa_vsf_klett_532, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_vsf_klett_532, 'long_name', 'Fresh Volcanic Sulfate Surface Area Conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_vsf_klett_532, 'standard_name', 'sa_vsf_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_sa_vsf_klett_1064, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_vsf_klett_1064, 'long_name', 'Fresh Volcanic Sulfate Surface Area Conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_vsf_klett_1064, 'standard_name', 'sa_vsf_klett_1064.'); 

% aged volcanic
netcdf.putAtt(ncID_klett, varID_sa_vsa_klett_355, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_vsa_klett_355, 'long_name', 'Aged Volcanic Sulfate Surface Area Conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_vsa_klett_355, 'standard_name', 'sa_vsa_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_sa_vsa_klett_532, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_vsa_klett_532, 'long_name', 'Aged Volcanic Sulfate Surface Area Conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_vsa_klett_532, 'standard_name', 'sa_vsa_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_sa_vsa_klett_1064, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_vsa_klett_1064, 'long_name', 'Aged Volcanic Sulfate Surface Area Conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_vsa_klett_1064, 'standard_name', 'sa_vsa_klett_1064.'); 

% trop. volcanic
netcdf.putAtt(ncID_klett, varID_sa_vst_klett_355, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_vst_klett_355, 'long_name', 'Trop. Volcanic Sulfate Surface Area Conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_vst_klett_355, 'standard_name', 'sa_vst_klett_355.');

netcdf.putAtt(ncID_klett, varID_sa_vst_klett_532, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_vst_klett_532, 'long_name', 'Trop. Volcanic Sulfate Surface Area Conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_vst_klett_532, 'standard_name', 'sa_vst_klett_532.');

netcdf.putAtt(ncID_klett, varID_sa_vst_klett_1064, 'unit', 'm$^{2}$ m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_sa_vst_klett_1064, 'long_name', 'Trop. Volcanic Sulfate Surface Area Conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_sa_vst_klett_1064, 'standard_name', 'sa_vst_klett_1064.');

% errors
% extinction
% dust
netcdf.putAtt(ncID_klett, varID_err_ext_d_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_d_klett_355, 'long_name', 'Error Dust ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_d_klett_355, 'standard_name', 'err_ext_d_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_err_ext_d_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_d_klett_532, 'long_name', 'Error Dust ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_d_klett_532, 'standard_name', 'err_ext_d_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_err_ext_d_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_d_klett_1064, 'long_name', 'Error Dust ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_d_klett_1064, 'standard_name', 'err_ext_d_klett_1064.'); 

% coarse dust
netcdf.putAtt(ncID_klett, varID_err_ext_cd_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_cd_klett_355, 'long_name', 'Error Coarse Dust ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_cd_klett_355, 'standard_name', 'err_ext_cd_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_err_ext_cd_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_cd_klett_532, 'long_name', 'Error Coarse Dust ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_cd_klett_532, 'standard_name', 'err_ext_cd_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_err_ext_cd_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_cd_klett_1064, 'long_name', 'Error Coarse Dust ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_cd_klett_1064, 'standard_name', 'err_ext_cd_klett_1064.'); 

% fine dust
netcdf.putAtt(ncID_klett, varID_err_ext_fd_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_fd_klett_355, 'long_name', 'Error Fine Dust ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_fd_klett_355, 'standard_name', 'err_ext_fd_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_err_ext_fd_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_fd_klett_532, 'long_name', 'Error Fine Dust ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_fd_klett_532, 'standard_name', 'err_ext_fd_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_err_ext_fd_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_fd_klett_1064, 'long_name', 'Error Fine Dust ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_fd_klett_1064, 'standard_name', 'err_ext_fd_klett_1064.'); 

% marine
netcdf.putAtt(ncID_klett, varID_err_ext_ndm_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_ndm_klett_355, 'long_name', 'Error Non-Dust marine ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_ndm_klett_355, 'standard_name', 'err_ext_ndm_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_err_ext_ndm_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_ndm_klett_532, 'long_name', 'Error Non-Dust marine ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_ndm_klett_532, 'standard_name', 'err_ext_ndm_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_err_ext_ndm_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_ndm_klett_1064, 'long_name', 'Error Non-Dust marine ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_ndm_klett_1064, 'standard_name', 'err_ext_ndm_klett_1064.'); 

% smoke
netcdf.putAtt(ncID_klett, varID_err_ext_nds_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_nds_klett_355, 'long_name', 'Error Non-Dust smoke ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_nds_klett_355, 'standard_name', 'err_ext_nds_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_err_ext_nds_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_nds_klett_532, 'long_name', 'Error Non-Dust smoke ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_nds_klett_532, 'standard_name', 'err_ext_nds_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_err_ext_nds_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_nds_klett_1064, 'long_name', 'Error Non-Dust smoke ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_nds_klett_1064, 'standard_name', 'err_ext_nds_klett_1064.'); 

% biomass burning
netcdf.putAtt(ncID_klett, varID_err_ext_bb_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_bb_klett_355, 'long_name', 'Error Biomass burning ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_bb_klett_355, 'standard_name', 'err_ext_bb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_err_ext_bb_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_bb_klett_532, 'long_name', 'Error Biomass burning ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_bb_klett_532, 'standard_name', 'err_ext_bb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_err_ext_bb_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_bb_klett_1064, 'long_name', 'Error Biomass burning ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_bb_klett_1064, 'standard_name', 'err_ext_bb_klett_1064.'); 

% fresh vs
netcdf.putAtt(ncID_klett, varID_err_ext_vsf_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_vsf_klett_355, 'long_name', 'Error fresh volcanic sulfate ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_vsf_klett_355, 'standard_name', 'err_ext_vsf_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_err_ext_vsf_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_vsf_klett_532, 'long_name', 'Error fresh volcanic sulfate ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_vsf_klett_532, 'standard_name', 'err_ext_vsf_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_err_ext_vsf_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_vsf_klett_1064, 'long_name', 'Error fresh volcanic sulfate ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_vsf_klett_1064, 'standard_name', 'err_ext_vsf_klett_1064.'); 

% aged vs
netcdf.putAtt(ncID_klett, varID_err_ext_vsa_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_vsa_klett_355, 'long_name', 'Error aged volcanic sulfate ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_vsa_klett_355, 'standard_name', 'err_ext_vsa_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_err_ext_vsa_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_vsa_klett_532, 'long_name', 'Error aged volcanic sulfate ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_vsa_klett_532, 'standard_name', 'err_ext_vsa_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_err_ext_vsa_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_vsa_klett_1064, 'long_name', 'Error aged volcanic sulfate ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_vsa_klett_1064, 'standard_name', 'err_ext_vsa_klett_1064.'); 

% tropos. vs
netcdf.putAtt(ncID_klett, varID_err_ext_vst_klett_355, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_vst_klett_355, 'long_name', 'Error tropospheric volcanic sulfate ext. coeff. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_vst_klett_355, 'standard_name', 'err_ext_vst_klett_355.');

netcdf.putAtt(ncID_klett, varID_err_ext_vst_klett_532, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_vst_klett_532, 'long_name', 'Error tropospheric volcanic sulfate ext. coeff. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_vst_klett_532, 'standard_name', 'err_ext_vst_klett_532.');

netcdf.putAtt(ncID_klett, varID_err_ext_vst_klett_1064, 'unit', 'm$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_err_ext_vst_klett_1064, 'long_name', 'Error tropospheric volcanic sulfate ext. coeff. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_ext_vst_klett_1064, 'standard_name', 'err_ext_vst_klett_1064.');

% mass
% dust
netcdf.putAtt(ncID_klett, varID_err_m_d_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_d_klett_355, 'long_name', 'Error Dust mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_d_klett_355, 'standard_name', 'err_m_d_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_err_m_d_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_d_klett_532, 'long_name', 'Error Dust mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_d_klett_532, 'standard_name', 'err_m_d_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_err_m_d_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_d_klett_1064, 'long_name', 'Error Dust mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_d_klett_1064, 'standard_name', 'err_m_d_klett_1064.'); 

% coarse dust
netcdf.putAtt(ncID_klett, varID_err_m_cd_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_cd_klett_355, 'long_name', 'Error Coarse Dust mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_cd_klett_355, 'standard_name', 'err_m_cd_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_err_m_cd_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_cd_klett_532, 'long_name', 'Error Coarse Dust mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_cd_klett_532, 'standard_name', 'err_m_cd_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_err_m_cd_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_cd_klett_1064, 'long_name', 'Error Coarse Dust mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_cd_klett_1064, 'standard_name', 'err_m_cd_klett_1064.'); 

% fine dust
netcdf.putAtt(ncID_klett, varID_err_m_fd_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_fd_klett_355, 'long_name', 'Error Fine Dust mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_fd_klett_355, 'standard_name', 'err_m_fd_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_err_m_fd_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_fd_klett_532, 'long_name', 'Error Fine Dust mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_fd_klett_532, 'standard_name', 'err_m_fd_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_err_m_fd_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_fd_klett_1064, 'long_name', 'Error Fine Dust mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_fd_klett_1064, 'standard_name', 'err_m_fd_klett_1064.'); 

% marine 
netcdf.putAtt(ncID_klett, varID_err_m_ndm_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_ndm_klett_355, 'long_name', 'Error Non-Dust marine mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_ndm_klett_355, 'standard_name', 'err_m_ndm_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_err_m_ndm_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_ndm_klett_532, 'long_name', 'Error Non-Dust marine mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_ndm_klett_532, 'standard_name', 'err_m_ndm_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_err_m_ndm_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_ndm_klett_1064, 'long_name', 'Error Non-Dust marine mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_ndm_klett_1064, 'standard_name', 'err_m_ndm_klett_1064.'); 

% smoke
netcdf.putAtt(ncID_klett, varID_err_m_nds_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_nds_klett_355, 'long_name', 'Error Non-Dust smoke mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_nds_klett_355, 'standard_name', 'err_m_nds_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_err_m_nds_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_nds_klett_532, 'long_name', 'Error Non-Dust smoke mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_nds_klett_532, 'standard_name', 'err_m_nds_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_err_m_nds_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_nds_klett_1064, 'long_name', 'Error Non-Dust smoke mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_nds_klett_1064, 'standard_name', 'err_m_nds_klett_1064.'); 

% biomass burning
netcdf.putAtt(ncID_klett, varID_err_m_bb_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_bb_klett_355, 'long_name', 'Error Biomass burning mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_bb_klett_355, 'standard_name', 'err_m_bb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_err_m_bb_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_bb_klett_532, 'long_name', 'Error Biomass burning mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_bb_klett_532, 'standard_name', 'err_m_bb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_err_m_bb_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_bb_klett_1064, 'long_name', 'Error Biomass burning mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_bb_klett_1064, 'standard_name', 'err_m_bb_klett_1064.'); 

% fresh vs
netcdf.putAtt(ncID_klett, varID_err_m_vsf_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_vsf_klett_355, 'long_name', 'Error fresh volcanic sulfate mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_vsf_klett_355, 'standard_name', 'err_m_vsf_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_err_m_vsf_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_vsf_klett_532, 'long_name', 'Error fresh volcanic sulfate mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_vsf_klett_532, 'standard_name', 'err_m_vsf_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_err_m_vsf_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_vsf_klett_1064, 'long_name', 'Error fresh volcanic sulfate mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_vsf_klett_1064, 'standard_name', 'err_m_vsf_klett_1064.'); 

% aged vs
netcdf.putAtt(ncID_klett, varID_err_m_vsa_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_vsa_klett_355, 'long_name', 'Error aged volcanic sulfate mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_vsa_klett_355, 'standard_name', 'err_m_vsa_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_err_m_vsa_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_vsa_klett_532, 'long_name', 'Error aged volcanic sulfate mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_vsa_klett_532, 'standard_name', 'err_m_vsa_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_err_m_vsa_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_vsa_klett_1064, 'long_name', 'Error aged volcanic sulfate mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_vsa_klett_1064, 'standard_name', 'err_m_vsa_klett_1064.'); 

% tropos. vs
netcdf.putAtt(ncID_klett, varID_err_m_vst_klett_355, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_vst_klett_355, 'long_name', 'Error tropospheric volcanic sulfate mass conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_vst_klett_355, 'standard_name', 'err_m_vst_klett_355.');

netcdf.putAtt(ncID_klett, varID_err_m_vst_klett_532, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_vst_klett_532, 'long_name', 'Error tropospheric volcanic sulfate mass conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_vst_klett_532, 'standard_name', 'err_m_vst_klett_532.');

netcdf.putAtt(ncID_klett, varID_err_m_vst_klett_1064, 'unit', 'ug m$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_err_m_vst_klett_1064, 'long_name', 'Error tropospheric volcanic sulfate mass conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_err_m_vst_klett_1064, 'standard_name', 'err_m_vst_klett_1064.');

% CCN
% total
netcdf.putAtt(ncID_klett, varID_n_ccn_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_klett_355, 'long_name', 'Total CCN Conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_klett_355, 'standard_name', 'n_ccn_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_ccn_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_klett_532, 'long_name', 'Total CCN Conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_klett_532, 'standard_name', 'n_ccn_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_ccn_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_klett_1064, 'long_name', 'Total CCN Conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_klett_1064, 'standard_name', 'n_ccn_klett_1064.'); 

% dust
netcdf.putAtt(ncID_klett, varID_n_ccn_d_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_d_klett_355, 'long_name', 'Dust CCN Conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_d_klett_355, 'standard_name', 'n_ccn_d_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_ccn_d_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_d_klett_532, 'long_name', 'Dust CCN Conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_d_klett_532, 'standard_name', 'n_ccn_d_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_ccn_d_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_d_klett_1064, 'long_name', 'Dust CCN Conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_d_klett_1064, 'standard_name', 'n_ccn_d_klett_1064.'); 

% continental
netcdf.putAtt(ncID_klett, varID_n_ccn_c_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_c_klett_355, 'long_name', 'Continental CCN Conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_c_klett_355, 'standard_name', 'n_ccn_c_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_ccn_c_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_c_klett_532, 'long_name', 'Continental CCN Conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_c_klett_532, 'standard_name', 'n_ccn_c_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_ccn_c_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_c_klett_1064, 'long_name', 'Continental CCN Conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_c_klett_1064, 'standard_name', 'n_ccn_c_klett_1064.'); 

% marine
netcdf.putAtt(ncID_klett, varID_n_ccn_m_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_m_klett_355, 'long_name', 'Marine CCN Conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_m_klett_355, 'standard_name', 'n_ccn_m_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_ccn_m_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_m_klett_532, 'long_name', 'Marine CCN Conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_m_klett_532, 'standard_name', 'n_ccn_m_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_ccn_m_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_m_klett_1064, 'long_name', 'Marine CCN Conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_m_klett_1064, 'standard_name', 'n_ccn_m_klett_1064.'); 

% biomass burnig
netcdf.putAtt(ncID_klett, varID_n_ccn_bb_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_bb_klett_355, 'long_name', 'Biomass Burning CCN Conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_bb_klett_355, 'standard_name', 'n_ccn_bb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_ccn_bb_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_bb_klett_532, 'long_name', 'Biomass Burning CCN Conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_bb_klett_532, 'standard_name', 'n_ccn_bb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_ccn_bb_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_bb_klett_1064, 'long_name', 'Biomass Burning CCN Conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_bb_klett_1064, 'standard_name', 'n_ccn_bb_klett_1064.'); 

% fresh vs
netcdf.putAtt(ncID_klett, varID_n_ccn_vsf_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_vsf_klett_355, 'long_name', 'Fresh Volcanic Sulfate CCN Conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_vsf_klett_355, 'standard_name', 'n_ccn_vsf_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_ccn_vsf_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_vsf_klett_532, 'long_name', 'Fresh Volcanic Sulfate CCN Conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_vsf_klett_532, 'standard_name', 'n_ccn_vsf_klett_532.'); 
netcdf.putAtt(ncID_klett, varID_n_ccn_vsf_klett_1064, 'unit', 'cm$^{-3}$');  

netcdf.putAtt(ncID_klett, varID_n_ccn_vsf_klett_1064, 'long_name', 'Fresh Volcanic Sulfate CCN Conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_vsf_klett_1064, 'standard_name', 'n_ccn_vsf_klett_1064.'); 

% aged vs
netcdf.putAtt(ncID_klett, varID_n_ccn_vsa_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_vsa_klett_355, 'long_name', 'Aged Volcanic Sulfate CCN Conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_vsa_klett_355, 'standard_name', 'n_ccn_vsa_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_ccn_vsa_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_vsa_klett_532, 'long_name', 'Aged Volcanic Sulfate CCN Conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_vsa_klett_532, 'standard_name', 'n_ccn_vsa_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_ccn_vsa_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_vsa_klett_1064, 'long_name', 'Aged Volcanic Sulfate CCN Conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_vsa_klett_1064, 'standard_name', 'n_ccn_vsa_klett_1064.');

% tropos. vs
netcdf.putAtt(ncID_klett, varID_n_ccn_vst_klett_355, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_vst_klett_355, 'long_name', 'Trop. Volcanic Sulfate CCN Conc. 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_vst_klett_355, 'standard_name', 'n_ccn_vst_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_ccn_vst_klett_532, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_vst_klett_532, 'long_name', 'Trop. Volcanic Sulfate CCN Conc. 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_vst_klett_532, 'standard_name', 'n_ccn_vst_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_ccn_vst_klett_1064, 'unit', 'cm$^{-3}$');  
netcdf.putAtt(ncID_klett, varID_n_ccn_vst_klett_1064, 'long_name', 'Trop. Volcanic Sulfate CCN Conc. 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_ccn_vst_klett_1064, 'standard_name', 'n_ccn_vst_klett_1064.'); 

% INP
% Dust INP DeMott 2010
netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_amb_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_amb_klett_355, 'long_name', 'Dust INP DeMott 2010 (Amb) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_amb_klett_355, 'standard_name', 'n_inp_d_d10_amb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_amb_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_amb_klett_532, 'long_name', 'Dust INP DeMott 2010 (Amb) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_amb_klett_532, 'standard_name', 'n_inp_d_d10_amb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_amb_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_amb_klett_1064, 'long_name', 'Dust INP DeMott 2010 (Amb) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_amb_klett_1064, 'standard_name', 'n_inp_d_d10_amb_klett_1064.'); 

% Dust INP DeMott 2015
netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_amb_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_amb_klett_355, 'long_name', 'Dust INP DeMott 2015 (Amb) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_amb_klett_355, 'standard_name', 'n_inp_d_d15_amb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_amb_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_amb_klett_532, 'long_name', 'Dust INP DeMott 2015 (Amb) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_amb_klett_532, 'standard_name', 'n_inp_d_d15_amb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_amb_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_amb_klett_1064, 'long_name', 'Dust INP DeMott 2015 (Amb) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_amb_klett_1064, 'standard_name', 'n_inp_d_d15_amb_klett_1064.'); 

% Dust INP Niemand 2012
netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_amb_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_amb_klett_355, 'long_name', 'Dust INP Niemand 2012 (Amb) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_amb_klett_355, 'standard_name', 'n_inp_d_n12_amb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_amb_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_amb_klett_532, 'long_name', 'Dust INP Niemand 2012 (Amb) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_amb_klett_532, 'standard_name', 'n_inp_d_n12_amb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_amb_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_amb_klett_1064, 'long_name', 'Dust INP Niemand 2012 (Amb) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_amb_klett_1064, 'standard_name', 'n_inp_d_n12_amb_klett_1064.'); 

% Dust INP Steinke 2015
netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_amb_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_amb_klett_355, 'long_name', 'Dust INP Steinke 2015 (Amb) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_amb_klett_355, 'standard_name', 'n_inp_d_s15_amb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_amb_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_amb_klett_532, 'long_name', 'Dust INP Steinke 2015 (Amb) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_amb_klett_532, 'standard_name', 'n_inp_d_s15_amb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_amb_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_amb_klett_1064, 'long_name', 'Dust INP Steinke 2015 (Amb) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_amb_klett_1064, 'standard_name', 'n_inp_d_s15_amb_klett_1064.'); 

% Dust INP DeMott 2010 
netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_klett_355, 'long_name', 'Dust INP DeMott 2010 (Fixed) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_klett_355, 'standard_name', 'n_inp_d_d10_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_klett_532, 'long_name', 'Dust INP DeMott 2010 (Fixed) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_klett_532, 'standard_name', 'n_inp_d_d10_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_klett_1064, 'long_name', 'Dust INP DeMott 2010 (Fixed) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d10_klett_1064, 'standard_name', 'n_inp_d_d10_klett_1064.'); 

% Dust INP DeMott 2015
netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_klett_355, 'long_name', 'Dust INP DeMott 2015 (Fixed) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_klett_355, 'standard_name', 'n_inp_d_d15_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_klett_532, 'long_name', 'Dust INP DeMott 2015 (Fixed) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_klett_532, 'standard_name', 'n_inp_d_d15_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_klett_1064, 'long_name', 'Dust INP DeMott 2015 (Fixed) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_d15_klett_1064, 'standard_name', 'n_inp_d_d15_klett_1064.'); 

% Dust INP Niemand 2012 
netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_klett_355, 'long_name', 'Dust INP Niemand 2012 (Fixed) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_klett_355, 'standard_name', 'n_inp_d_n12_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_klett_532, 'long_name', 'Dust INP Niemand 2012 (Fixed) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_klett_532, 'standard_name', 'n_inp_d_n12_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_klett_1064, 'long_name', 'Dust INP Niemand 2012 (Fixed) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_n12_klett_1064, 'standard_name', 'n_inp_d_n12_klett_1064.'); 

% Dust INP Steinke 2015
netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_klett_355, 'long_name', 'Dust INP Steinke 2015 (Fixed) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_klett_355, 'standard_name', 'n_inp_d_s15_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_klett_532, 'long_name', 'Dust INP Steinke 2015 (Fixed) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_klett_532, 'standard_name', 'n_inp_d_s15_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_klett_1064, 'long_name', 'Dust INP Steinke 2015 (Fixed) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_d_s15_klett_1064, 'standard_name', 'n_inp_d_s15_klett_1064.'); 

% Continental INP DeMott 2010
netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_amb_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_amb_klett_355, 'long_name', 'Continental INP DeMott 2010 (Amb) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_amb_klett_355, 'standard_name', 'n_inp_c_d10_amb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_amb_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_amb_klett_532, 'long_name', 'Continental INP DeMott 2010 (Amb) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_amb_klett_532, 'standard_name', 'n_inp_c_d10_amb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_amb_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_amb_klett_1064, 'long_name', 'Continental INP DeMott 2010 (Amb) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_amb_klett_1064, 'standard_name', 'n_inp_c_d10_amb_klett_1064.'); 

% Continental INP DeMott 2010
netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_klett_355, 'long_name', 'Continental INP DeMott 2010 (Fixed) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_klett_355, 'standard_name', 'n_inp_c_d10_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_klett_532, 'long_name', 'Continental INP DeMott 2010 (Fixed) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_klett_532, 'standard_name', 'n_inp_c_d10_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_klett_1064, 'long_name', 'Continental INP DeMott 2010 (Fixed) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_c_d10_klett_1064, 'standard_name', 'n_inp_c_d10_klett_1064.'); 

% Marine INP DeMott 2010 
netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_amb_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_amb_klett_355, 'long_name', 'Marine INP DeMott 2010 (Amb) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_amb_klett_355, 'standard_name', 'n_inp_m_d10_amb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_amb_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_amb_klett_532, 'long_name', 'Marine INP DeMott 2010 (Amb) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_amb_klett_532, 'standard_name', 'n_inp_m_d10_amb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_amb_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_amb_klett_1064, 'long_name', 'Marine INP DeMott 2010 (Amb) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_amb_klett_1064, 'standard_name', 'n_inp_m_d10_amb_klett_1064.'); 

% Marine INP DeMott 2010 
netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_klett_355, 'long_name', 'Marine INP DeMott 2010 (Fixed) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_klett_355, 'standard_name', 'n_inp_m_d10_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_klett_532, 'long_name', 'Marine INP DeMott 2010 (Fixed) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_klett_532, 'standard_name', 'n_inp_m_d10_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_klett_1064, 'long_name', 'Marine INP DeMott 2010 (Fixed) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_m_d10_klett_1064, 'standard_name', 'n_inp_m_d10_klett_1064.'); 

% Biomass Burning INP DeMott 2010 
netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_amb_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_amb_klett_355, 'long_name', 'Biomass Burning INP DeMott 2010 (Amb) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_amb_klett_355, 'standard_name', 'INPbb_d10_amb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_amb_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_amb_klett_532, 'long_name', 'Biomass Burning INP DeMott 2010 (Amb) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_amb_klett_532, 'standard_name', 'INPbb_d10_amb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_amb_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_amb_klett_1064, 'long_name', 'Biomass Burning INP DeMott 2010 (Amb) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_amb_klett_1064, 'standard_name', 'INPbb_d10_amb_klett_1064.'); 

% Biomass Burning INP DeMott 2010
netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_klett_355, 'long_name', 'Biomass Burning INP DeMott 2010 (Fixed) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_klett_355, 'standard_name', 'INPbb_d10_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_klett_532, 'long_name', 'Biomass Burning INP DeMott 2010 (Fixed) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_klett_532, 'standard_name', 'INPbb_d10_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_klett_1064, 'long_name', 'Biomass Burning INP DeMott 2010 (Fixed) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_bb_d10_klett_1064, 'standard_name', 'INPbb_d10_klett_1064.'); 

% Fresh Volc. INP DeMott 2010
netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_amb_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_amb_klett_355, 'long_name', 'Fresh Volc. INP DeMott 2010 (Amb) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_amb_klett_355, 'standard_name', 'INPvsf_d10_amb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_amb_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_amb_klett_532, 'long_name', 'Fresh Volc. INP DeMott 2010 (Amb) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_amb_klett_532, 'standard_name', 'INPvsf_d10_amb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_amb_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_amb_klett_1064, 'long_name', 'Fresh Volc. INP DeMott 2010 (Amb) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_amb_klett_1064, 'standard_name', 'INPvsf_d10_amb_klett_1064.'); 

% Fresh Volc. INP DeMott 2010
netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_klett_355, 'long_name', 'Fresh Volc. INP DeMott 2010 (Fixed) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_klett_355, 'standard_name', 'INPvsf_d10_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_klett_532, 'long_name', 'Fresh Volc. INP DeMott 2010 (Fixed) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_klett_532, 'standard_name', 'INPvsf_d10_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_klett_1064, 'long_name', 'Fresh Volc. INP DeMott 2010 (Fixed) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsf_d10_klett_1064, 'standard_name', 'INPvsf_d10_klett_1064.'); 

% Aged Volc. INP DeMott 2010
netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_amb_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_amb_klett_355, 'long_name', 'Aged Volc. INP DeMott 2010 (Amb) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_amb_klett_355, 'standard_name', 'INPvsa_d10_amb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_amb_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_amb_klett_532, 'long_name', 'Aged Volc. INP DeMott 2010 (Amb) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_amb_klett_532, 'standard_name', 'INPvsa_d10_amb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_amb_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_amb_klett_1064, 'long_name', 'Aged Volc. INP DeMott 2010 (Amb) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_amb_klett_1064, 'standard_name', 'INPvsa_d10_amb_klett_1064.'); 

% Aged Volc. INP DeMott 2010 
netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_klett_355, 'long_name', 'Aged Volc. INP DeMott 2010 (Fixed) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_klett_355, 'standard_name', 'INPvsa_d10_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_klett_532, 'long_name', 'Aged Volc. INP DeMott 2010 (Fixed) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_klett_532, 'standard_name', 'INPvsa_d10_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_klett_1064, 'long_name', 'Aged Volc. INP DeMott 2010 (Fixed) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vsa_d10_klett_1064, 'standard_name', 'INPvsa_d10_klett_1064.'); 

% Trop. Volc. INP DeMott 2010
netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_amb_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_amb_klett_355, 'long_name', 'Trop. Volc. INP DeMott 2010 (Amb) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_amb_klett_355, 'standard_name', 'INPvst_d10_amb_klett_355.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_amb_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_amb_klett_532, 'long_name', 'Trop. Volc. INP DeMott 2010 (Amb) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_amb_klett_532, 'standard_name', 'INPvst_d10_amb_klett_532.'); 

netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_amb_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_amb_klett_1064, 'long_name', 'Trop. Volc. INP DeMott 2010 (Amb) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_amb_klett_1064, 'standard_name', 'INPvst_d10_amb_klett_1064.'); 

% Trop. Volc. INP DeMott 2010 
netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_klett_355, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_klett_355, 'long_name', 'Trop. Volc. INP DeMott 2010 (Fixed) 355 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_klett_355, 'standard_name', 'INPvst_d10_klett_355.');

netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_klett_532, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_klett_532, 'long_name', 'Trop. Volc. INP DeMott 2010 (Fixed) 532 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_klett_532, 'standard_name', 'INPvst_d10_klett_532.');

netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_klett_1064, 'unit', 'L$^{-1}$');  
netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_klett_1064, 'long_name', 'Trop. Volc. INP DeMott 2010 (Fixed) 1064 nm klett');  
netcdf.putAtt(ncID_klett, varID_n_inp_vst_d10_klett_1064, 'standard_name', 'INPvst_d10_klett_1064.');

%% klett 355
% aerBsc_klett_355
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_355, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_355, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_355, 'long_name', 'aerosol backscatter coefficient at 355 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_355, 'standard_name', 'beta (aer, 355 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_355, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_355, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID_klett, varID_aerBsc_klett_355, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta355 * 1e6, PollyConfig.heightFullOverlap(flagCh355FR), PollyConfig.maxDecomHeight355, PollyConfig.smoothWin_klett_355 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_355, 'comment', sprintf('The result is retrieved with klett method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined klett elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% aerBscStd_klett_355
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_355, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_355, 'long_name', 'uncertainty of aerosol backscatter coefficient at 355 nm');
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_355, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_355, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_355, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta355 * 1e6, PollyConfig.heightFullOverlap(flagCh355FR), PollyConfig.maxDecomHeight355, PollyConfig.smoothWin_klett_355 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_355, 'comment', sprintf('The result is retrieved with klett method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined klett elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% varID_aerBsc355_klett_d2
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_d2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_d2, 'long_name', 'two-step dust particle backscatter coefficient at 355 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_d2, 'standard_name', 'beta dust (aer, 355 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_d2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_d2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_d2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc355_klett_d2
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_d2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_d2, 'long_name', 'uncertainty of two-step dust particle backscatter coefficient at 355 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_d2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_d2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_d2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_d2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc355_klett_dc2
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_dc2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_dc2, 'long_name', 'two-step coarse-dust particle backscatter coefficient at 355 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_dc2, 'standard_name', 'beta dust (aer, 355 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_dc2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_dc2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_dc2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc355_klett_dc2
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_dc2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_dc2, 'long_name', 'uncertainty of two-step coarse-dust particle backscatter coefficient at 355 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_dc2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_dc2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_dc2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_dc2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc355_klett_df2
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_df2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_df2, 'long_name', 'two-step fine-dust particle backscatter coefficient at 355 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_df2, 'standard_name', 'beta dust (aer, 355 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_df2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_df2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_df2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc355_klett_df2
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_df2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_df2, 'long_name', 'uncertainty of two-step fine-dust particle backscatter coefficient at 355 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_df2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_df2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_df2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_df2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc355_klett_nddf2
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_nddf2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_nddf2, 'long_name', 'two-step non-dust/ fine-dust particle backscatter coefficient at 355 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_nddf2, 'standard_name', 'beta dust (aer, 355 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_nddf2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_nddf2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_nddf2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc355_klett_nddf2
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_nddf2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_nddf2, 'long_name', 'uncertainty of two-step non-dust/ fine-dust particle backscatter coefficient at 355 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_nddf2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_nddf2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_nddf2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_nddf2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc355_klett_nd2
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_nd2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_nd2, 'long_name', 'two-step non-dust particle backscatter coefficient at 355 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_nd2, 'standard_name', 'beta dust (aer, 355 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_nd2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_nd2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_aerBsc355_klett_nd2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc355_klett_nd2
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_nd2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_nd2, 'long_name', 'uncertainty of two-step non-dust particle backscatter coefficient at 355 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_nd2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_nd2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_nd2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_err_aerBsc355_klett_nd2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

%% klett 532
% aerBsc_klett_532
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_532, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_532, 'standard_name', 'beta (aer, 532 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_532, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_532, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID_klett, varID_aerBsc_klett_532, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta532 * 1e6, PollyConfig.heightFullOverlap(flagCh532FR), PollyConfig.maxDecomHeight532, PollyConfig.smoothWin_klett_532 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_532, 'comment', sprintf('The result is retrieved with klett method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined klett elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% aerBscStd_klett_532
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_532, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_532, 'long_name', 'uncertainty of aerosol backscatter coefficient at 532 nm');
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_532, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_532, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_532, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta532 * 1e6, PollyConfig.heightFullOverlap(flagCh532FR), PollyConfig.maxDecomHeight532, PollyConfig.smoothWin_klett_532 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_532, 'comment', sprintf('The result is retrieved with klett method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined klett elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% varID_aerBsc532_klett_d2
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_d2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_d2, 'long_name', 'two-step dust particle backscatter coefficient at 532 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_d2, 'standard_name', 'beta dust (aer, 532 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_d2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_d2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_d2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc532_klett_d2
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_d2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_d2, 'long_name', 'uncertainty of two-step dust particle backscatter coefficient at 532 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_d2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_d2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_d2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_d2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc532_klett_dc2
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_dc2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_dc2, 'long_name', 'two-step coarse-dust particle backscatter coefficient at 532 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_dc2, 'standard_name', 'beta dust (aer, 532 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_dc2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_dc2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_dc2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc532_klett_dc2
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_dc2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_dc2, 'long_name', 'uncertainty of two-step coarse-dust particle backscatter coefficient at 532 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_dc2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_dc2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_dc2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_dc2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc532_klett_df2
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_df2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_df2, 'long_name', 'two-step fine-dust particle backscatter coefficient at 532 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_df2, 'standard_name', 'beta dust (aer, 532 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_df2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_df2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_df2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc532_klett_df2
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_df2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_df2, 'long_name', 'uncertainty of two-step fine-dust particle backscatter coefficient at 532 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_df2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_df2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_df2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_df2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc532_klett_nddf2
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_nddf2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_nddf2, 'long_name', 'two-step non-dust/ fine-dust particle backscatter coefficient at 532 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_nddf2, 'standard_name', 'beta dust (aer, 532 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_nddf2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_nddf2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_nddf2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc532_klett_nddf2
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_nddf2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_nddf2, 'long_name', 'uncertainty of two-step non-dust/ fine-dust particle backscatter coefficient at 532 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_nddf2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_nddf2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_nddf2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_nddf2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc532_klett_nd2
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_nd2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_nd2, 'long_name', 'two-step non-dust particle backscatter coefficient at 532 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_nd2, 'standard_name', 'beta dust (aer, 532 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_nd2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_nd2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_aerBsc532_klett_nd2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc532_klett_nd2
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_nd2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_nd2, 'long_name', 'uncertainty of two-step non-dust particle backscatter coefficient at 532 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_nd2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_nd2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_nd2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_err_aerBsc532_klett_nd2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

%% klett 1064
% aerBsc_klett_1064
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_1064, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_1064, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_1064, 'long_name', 'aerosol backscatter coefficient at 1064 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_1064, 'standard_name', 'beta (aer, 1064 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_1064, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_1064, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID_klett, varID_aerBsc_klett_1064, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta1064 * 1e6, PollyConfig.heightFullOverlap(flagCh1064FR), PollyConfig.maxDecomHeight1064, PollyConfig.smoothWin_klett_1064 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID_klett, varID_aerBsc_klett_1064, 'comment', sprintf('The result is retrieved with klett method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined klett elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% aerBscStd_klett_1064
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_1064, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_1064, 'long_name', 'uncertainty of aerosol backscatter coefficient at 1064 nm');
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_1064, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_1064, 'source', CampaignConfig.name);
% netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_1064, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta1064 * 1e6, PollyConfig.heightFullOverlap(flagCh1064FR), PollyConfig.maxDecomHeight1064, PollyConfig.smoothWin_klett_1064 * data.hRes, PollyConfig.angstrexp));
netcdf.putAtt(ncID_klett, varID_aerBscStd_klett_1064, 'comment', sprintf('The result is retrieved with klett method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined klett elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

% varID_aerBsc1064_klett_d2
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_d2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_d2, 'long_name', 'two-step dust particle backscatter coefficient at 1064 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_d2, 'standard_name', 'beta dust (aer, 1064 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_d2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_d2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_d2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc1064_klett_d2
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_d2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_d2, 'long_name', 'uncertainty of two-step dust particle backscatter coefficient at 1064 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_d2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_d2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_d2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_d2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc1064_klett_dc2
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_dc2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_dc2, 'long_name', 'two-step coarse-dust particle backscatter coefficient at 1064 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_dc2, 'standard_name', 'beta dust (aer, 1064 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_dc2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_dc2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_dc2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc1064_klett_dc2
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_dc2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_dc2, 'long_name', 'uncertainty of two-step coarse-dust particle backscatter coefficient at 1064 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_dc2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_dc2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_dc2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_dc2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc1064_klett_df2
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_df2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_df2, 'long_name', 'two-step fine-dust particle backscatter coefficient at 1064 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_df2, 'standard_name', 'beta dust (aer, 1064 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_df2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_df2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_df2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc1064_klett_df2
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_df2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_df2, 'long_name', 'uncertainty of two-step fine-dust particle backscatter coefficient at 1064 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_df2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_df2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_df2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_df2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc1064_klett_nddf2
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_nddf2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_nddf2, 'long_name', 'two-step non-dust/ fine-dust particle backscatter coefficient at 1064 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_nddf2, 'standard_name', 'beta dust (aer, 1064 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_nddf2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_nddf2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_nddf2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc1064_klett_nddf2
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_nddf2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_nddf2, 'long_name', 'uncertainty of two-step non-dust/ fine-dust particle backscatter coefficient at 1064 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_nddf2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_nddf2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_nddf2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_nddf2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_aerBsc1064_klett_nd2
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_nd2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_nd2, 'long_name', 'two-step non-dust particle backscatter coefficient at 1064 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_nd2, 'standard_name', 'beta dust (aer, 1064 nm)');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_nd2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_nd2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_aerBsc1064_klett_nd2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

% varID_err_aerBsc1064_klett_nd2
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_nd2, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_nd2, 'long_name', 'uncertainty of two-step non-dust particle backscatter coefficient at 1064 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_nd2, 'standard_name', 'sigma (beta)');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_nd2, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_nd2, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_err_aerBsc1064_klett_nd2, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));

%% ? raman
% varID_beta_dc_raman 
netcdf.putAtt(ncID_raman, varID_beta_dc_raman, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_raman, varID_beta_dc_raman, 'long_name', 'two-step coarse dust particle backscatter coefficient at 532 nm retrieved with Raman method');
netcdf.putAtt(ncID_raman, varID_beta_dc_raman, 'standard_name', 'beta dust (aer, 355 nm)');
netcdf.putAtt(ncID_raman, varID_beta_dc_raman, 'plot_scale', 'linear');
netcdf.putAtt(ncID_raman, varID_beta_dc_raman, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_beta_dc_raman, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));
%%
varID_global = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncID_raman, varID_global, 'Conventions', 'CF-1.0');
netcdf.putAtt(ncID_raman, varID_global, 'Licence', 'Creative Commons Attribution Share Alike 4.0 International (CC BY-SA 4.0)');
netcdf.putAtt(ncID_raman, varID_global, 'Data Policy', 'Each PollyNET site has Principal Investigator(s) (PI), responsible for deployment, maintenance and data collection. Information on which PI is responsible can be gathered via polly@tropos.de. The PI has priority use of the data collected at the site. The PI is entitled to be informed of any use of that data. Mandatory guidelines for data use and publication: Using PollyNET data or plots (also for presentations/workshops): Please consult with the PI or the PollyNET team (see contact_mail contact) before using data or plots! This will help to avoid misinterpretations of the lidar data and avoid the use of data from periods of malfunction of the instrument. Using PollyNET images/data on external websites: PIs and PollyNET must be asked for agreement and a link directed to polly.tropos.de must be included. Publishing PollyNET data and/or plots data: Offer authorship for the PI(s)! Acknowledge projects which have made the measurements possible according to PI(s) recommendation. PollyNET requests a notification of any published papers or reports or a brief description of other uses (e.g., posters, oral presentations, etc.) of data/plots used from PollyNET. This will help us determine the use of PollyNET data, which is helpful in optimizing product development and acquire new funding for future measurements. It also helps us to keep our product-related references up-to-date.');
netcdf.putAtt(ncID_raman, varID_global, 'location', CampaignConfig.location);
netcdf.putAtt(ncID_raman, varID_global, 'institute', PicassoConfig.institute);
netcdf.putAtt(ncID_raman, varID_global, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_raman, varID_global, 'version', PicassoConfig.PicassoVersion);
netcdf.putAtt(ncID_raman, varID_global, 'reference', PicassoConfig.homepage);
netcdf.putAtt(ncID_raman, varID_global, 'contact', PicassoConfig.contact);
netcdf.putAtt(ncID_raman, varID_global, 'PicassoConfig_Info', data.PicassoConfig_saving_info);
netcdf.putAtt(ncID_raman, varID_global, 'PollyConfig_Info', data.PollyConfig_saving_info);
netcdf.putAtt(ncID_raman, varID_global, 'CampaignConfig_Info', data.CampaignConfig_saving_info);
netcdf.putAtt(ncID_raman, varID_global, 'PollyData_Info', data.PollyDataInfo_saving_info);
cwd = pwd;
cd(PicassoConfig.PicassoRootDir);
gitInfo = getGitInfo();
cd(cwd);
netcdf.putAtt(ncID_raman, varID_global, 'history', sprintf('Last processing time at %s by %s, git branch: %s, git commit: %s', tNow, mfilename, gitInfo.branch, gitInfo.hash));

% close file
netcdf.close(ncID_raman);

%% ? klett
% varID_beta_dc_klett 
netcdf.putAtt(ncID_klett, varID_beta_dc_klett, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID_klett, varID_beta_dc_klett, 'long_name', 'two-step coarse dust particle backscatter coefficient at 532 nm retrieved with klett method');
netcdf.putAtt(ncID_klett, varID_beta_dc_klett, 'standard_name', 'beta dust (aer, 355 nm)');
netcdf.putAtt(ncID_klett, varID_beta_dc_klett, 'plot_scale', 'linear');
netcdf.putAtt(ncID_klett, varID_beta_dc_klett, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_beta_dc_klett, 'retrieving_info', sprintf('For information, please go to Tesche et al. (2009) and Mamouri and Ansmann (2014).'));
%%
varID_global = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncID_klett, varID_global, 'Conventions', 'CF-1.0');
netcdf.putAtt(ncID_klett, varID_global, 'Licence', 'Creative Commons Attribution Share Alike 4.0 International (CC BY-SA 4.0)');
netcdf.putAtt(ncID_klett, varID_global, 'Data Policy', 'Each PollyNET site has Principal Investigator(s) (PI), responsible for deployment, maintenance and data collection. Information on which PI is responsible can be gathered via polly@tropos.de. The PI has priority use of the data collected at the site. The PI is entitled to be informed of any use of that data. Mandatory guidelines for data use and publication: Using PollyNET data or plots (also for presentations/workshops): Please consult with the PI or the PollyNET team (see contact_mail contact) before using data or plots! This will help to avoid misinterpretations of the lidar data and avoid the use of data from periods of malfunction of the instrument. Using PollyNET images/data on external websites: PIs and PollyNET must be asked for agreement and a link directed to polly.tropos.de must be included. Publishing PollyNET data and/or plots data: Offer authorship for the PI(s)! Acknowledge projects which have made the measurements possible according to PI(s) recommendation. PollyNET requests a notification of any published papers or reports or a brief description of other uses (e.g., posters, oral presentations, etc.) of data/plots used from PollyNET. This will help us determine the use of PollyNET data, which is helpful in optimizing product development and acquire new funding for future measurements. It also helps us to keep our product-related references up-to-date.');
netcdf.putAtt(ncID_klett, varID_global, 'location', CampaignConfig.location);
netcdf.putAtt(ncID_klett, varID_global, 'institute', PicassoConfig.institute);
netcdf.putAtt(ncID_klett, varID_global, 'source', CampaignConfig.name);
netcdf.putAtt(ncID_klett, varID_global, 'version', PicassoConfig.PicassoVersion);
netcdf.putAtt(ncID_klett, varID_global, 'reference', PicassoConfig.homepage);
netcdf.putAtt(ncID_klett, varID_global, 'contact', PicassoConfig.contact);
netcdf.putAtt(ncID_klett, varID_global, 'PicassoConfig_Info', data.PicassoConfig_saving_info);
netcdf.putAtt(ncID_klett, varID_global, 'PollyConfig_Info', data.PollyConfig_saving_info);
netcdf.putAtt(ncID_klett, varID_global, 'CampaignConfig_Info', data.CampaignConfig_saving_info);
netcdf.putAtt(ncID_klett, varID_global, 'PollyData_Info', data.PollyDataInfo_saving_info);
cwd = pwd;
cd(PicassoConfig.PicassoRootDir);
gitInfo = getGitInfo();
cd(cwd);
netcdf.putAtt(ncID_klett, varID_global, 'history', sprintf('Last processing time at %s by %s, git branch: %s, git commit: %s', tNow, mfilename, gitInfo.branch, gitInfo.hash));

% close file
netcdf.close(ncID_klett);
end
end
## Polly Config

The filename of polly config should be names as {polly version}_config.json. And it should be noted that the {polly version} is the lower case. Any wrong spelling can not be recognized correctly. 

### Descriptions

I will summarize all the configurations in the table below. But you should keep in mind there could be different settings for different polly, so you should create a new configuration file according to your demands.

|keyword |            Description       |Example |Reference|
|:-------:|:------------|:-------:|:--------|
|flagCorrectFalseMShots|whether to correct the invalid shots stored in the netcdf files. (I don't know the reason yet, but it does exist in pollyxt_tropos for a period of time)|true|
|flagFilterFalseMShots|whether to filter out the profiles with invalid shots. (Since I don't know whether it's trustable for these profiles, I will leave this keyword for future development.)|false||
|flagDTCor|whether to implement deadtime correction|true||
|flagWVCalibration|whether to implement water vapor calibration|true||
|MWRFolder|The folder of prw results from MWR. (This is only for LACROS)|"C:\\Users\\zhenping\\Desktop\\Picasso\\test\\read_IWV_from_MWR"||
|dataFileFormat|regular expression to extract the data and time info from polly data file. (This is based on the syntax of matlab **regexp**)|"(?<year>\\d{4})_(?<month>\\d{2})_(?<day>\\d{2})_\\w*_(?<hour>\\d{2})_(?<minute>\\d{2})_(?<second>\\d{2})\\w*.nc"||
|gdas1Site|gdas1 site for the current campaign. (You can find the info in [gdas1-site-list.txt](/doc/gdas1-site-list.txt))|"warsaw"||
|max_height_bin|the number of bins you want to extract for each profile. (Normally, the high altitude bins only contain noise. If you load too much bins, you will slow down the whole processing process)|2500||
|first_range_gate_indx|the first bin for each channel. (It's highly suggested to tune this parameter to compensate the lag among different channels)|[261, 261, 261, 261, 261, 261, 261, 261, 262, 262, 262, 262]||
|first_range_gate_height|The height for the first range bin. [m]. You need to take great care for this parameter, since it will create large bias for extinction coefficient with Raman method. Look for advice from hardware scientist if you are not certain about this|78.75 m **->(The unit is only for demonstration, don't set it in the config files)**||
|dtCorMode|deadtime correction mode. (1: use the parameters saved in the netcdf files; 2: nonparalyzable correction with user define deadtime; 3: paralyzable correction with user defined parameters; 4: no deadtime correction)|1||
|dt|parameters for deadtime correction. If "dtCorMode" is set to be '2', only the deadtime for each channel need to be set here with unit of ns. If "dtCorMode" is set to be '3', the correction parameters need to be set accordingly. You can take [pollyxt_tropos_config.json](/config/pollyxt_tropos_config.json) as an example|[[0.0, 0.972992, 0.00353332, -7.90981e-006, 1.06451e-007, 1.42895e-009], [0, 1.0117, -0.0014, 0.0002, -0.0000, 0.0000], [0, 0.9674, 0.0023, 0.0000, 0.0000, 0.0000], [0, 0.9929, 0.0000, 0.0001, -0.0000, 0.0000], [0, 0.9843, 0.0022, 0.0001, -0.0000, 0.0000], [0, 0.9391, 0.0063, -0.0001, 0.0000, -0.0000], [0, 1.0035, 0.0003, 0.0001, -0.0000, 0.0000], [0, 1.0000, 0, 0, 0, 0], [0, 1.0000, 0.0029, 0.0000, 0.0000, 0.0000], [0, 1.0000, 0.0028, 0.0000, 0.0000, 0.0000], [0, 1.0000, 0.0028, 0.0000, 0.0000, 0.0000], [0, 1.0000, 0.0025, 0.0000, 0.0000, 0.0000], [0, 1, 0, 0, 0, 0]]||
|bgCorRangeIndx|the bottom and top index of signal to calculate the background|[10, 240]||
|mask_SNRmin|the SNR threshold to mask noisy bins|[1.6, 1, 1, 1, 1.5, 1, 1, 1.5, 1, 1, 1, 1, 1]||
|init_depAng|the initial angle of the polariser withou depo calibration [degree]|0||
|maskDepCalAng|the mask for postive and negative calibration angle. 'none' means invalid profiles with different depol_cal_angle|["none", "none", "p", "p", "p", "p", "p", "p", "p", "p", "none", "none", "n", "n", "n", "n", "n", "n", "n", "n"]||
|depol_cal_minbin_{wavelength}|the minimum bin used for depolarization calibration|40||
|depol_cal_maxbin_{wavelength}|the maximum bin used for depolarization calibration|300||
|depol_cal_SNRmin_{wavelength}|Threshold for the minimum SNR used in depol-calibration. There are four signal profiles used in the calibration, total channel at ±45∘ and cross channel at ±45∘. Therefore, an array of four element need to be configured. Namely, [total+45∘, total−45∘, cross+45∘, cross−45∘]
|[1, 1, 1, 1]||
|depol_cal_sigMax_{wavelength}|The maximum signal strength could be used for depol-calibration to prevent signal pileup effects|[1500, 1500, 1500, 1500] (photon count)||
|rel_std_dplus_{wavelength}|Threshold for maximum relative uncertainty of signal ratio at +45∘ depol-calibration. If relative uncertainty exceed this value, it states there could be clouds or too weak signal for this calibration period.|0.2||
|rel_std_dminus_{wavelength}|Threshold for maximum relative uncertainty of signal ratio at −45∘ depol-calibration.|0.2||
|depol_cal_segmentLen_{wavelength}|The small region for evaluating the uncertainty of depol calibration|40||
|depol_cal_smoothWin_{wavelength}|The smoothing window for depol-calibration|8||
|isFR|flag of far-range channel|[1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0]||
|isNR|flag of near-range channel|[0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0]||
|is532nm|flag of 532nm channel|[0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0]||
|is355nm|flag of 355nm channel|[1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0]||
|is1064nm|flag of 1064nm channel|[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]||
|isTot|flag of total channel|[1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0]||
|isCross|flag of cross polarized channel|[0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0]||
|is387nm|flag of 387nm channel|[0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]||
|is407nm|flag of 407nm channel|[0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]||
|is607nm|flag of 607nm channel|[0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0]||
|channelTag|label of each channel|["FR-total-355 nm", "FR-cross-355 nm", "FR-387 nm", "FR-407 nm", "FR-total-532 nm", "FR-cross-532 nm", "FR-607 nm", "FR-total-1064 nm", "NR-total-532 nm", "NR-607 nm", "NR-total-355 nm", "NR-387 nm", "unknown"]||
|minPC_fog|The minimum photon count for non-fog profile. The detected photon count between 40th and 120th bin (above the first bin) for each 30s profile will be accumulated for the fog profile screening.|60|Holger, AMT, A1, 2016|
|TR|Transmission ratio for different channel.|[0.898, 1086, 1, 1, 1.45, 778.8, 1, 1, 1, 1, 1, 1, 1]|Ronny, AMT, 2016|
|overlapCalMode|1:overlap corrected based on the near-range signal. 2: with User-Input overlap function. 3:EARLINET signal mergin algorithm(TODO). 4: no overlap correction|1||
|maxSigSlope4FilterCloud|The slope threshold for cloud screening. The screening is based on the slope of the Range Corrected Signal(photon count * m^2). In theory, this should be done with the attenuated backscatter. Since the lidar constant is unknown and cloud-screen is highly important for retrieving aerosol profiles, this is the only applicable way to my knowledge. Attention should be paid for the threshold setting, because it’s dependent on the the order of ND filter. But it’s not very sensitive because cloud scattering signal is much more stronger than that from aerosols. You can keep this value if there is no dramastic changes of ND filter(more than 1)|3e6||
|saturate_thresh|the threshold for signal saturation|100 [MHz]||
|heightFullOverlap|height for the base of full overlap|[500, 500, 500, 500, 500, 500, 500, 500, 150, 150, 150, 150, 150]|polly_overview.xlsx|
|minSNR_4_sigNorm|The minimum SNR requirement for the signal used for signal normalization both for near- and far- range signal.|[10]||
|intNProfiles|Accumulated profiles for retrieving.|120||
|minIntNProfiles|minimum integral profiles for aerosol retrieving|90||
|meteorDataSource|the data source for meteorological data. If the current data does not exist. It will turn to standard atmosphere model.|"gdas1"||
|radiosondeSitenum|The site number for the nearest radiosonde launching site. (You can search the number in [radiosonde-station-list.txt](/doc/radiosonde-station-list.txt))|14430||
|IWV_instrument|the data source of IWV. ('mwr' or 'aeronet')|"AERONET"||
|maxIWVTLag|The minumum lag required for water vapor calibration between IWV data and lidar water vapor measurement.|0.1666 (day)||
|minDecomLogDist{wavelength}||0.2||
|maxDecomHeight{wavelength}||8000||
|maxDecomThickness{wavelength}||700||
|decomSmoothWin{wavelength}|The smoothing window for molecular corrected signal used in Douglas-Peucker decomposition algorithm.|20|[Pollynet_Processing_Chain.pptx](/doc/Pollynet_Processing_Chain.pptx)|
|minRefThickness{wavelength}|The minimum thickness for the reference height. There is thickness test in the RayleighFit function which will ensure the minimum thickness of the reference height|500 [m]|[Pollynet_Processing_Chain.pptx](/doc/Pollynet_Processing_Chain.pptx)|
|minRefDeltaExt{wavelength}|The maximum slope difference between measured signal and molecule signal. This threshold is used in RayleighFit slope test which will examine whether $slope_{molecular signal}\in[slope_{measured signal} - k\sigma_{slope_{measured signal}}, slope_{measured signal} + k\sigma_{slope_{measured signal}}]$|2|[Pollynet_Processing_Chain.pptx](/doc/Pollynet_Processing_Chain.pptx)|
|minRefSNR{wavelength}|The minimum SNR for the accumulated signal at the tested reference height.|5|[Pollynet_Processing_Chain.pptx](/doc/Pollynet_Processing_Chain.pptx)|
|LR{wavelength}|Default lidar ratio for Klett retrieving method|50 Sr||
|refBeta{wavelength}|Reference value for Klett and Raman method|2e-8||
|smoothWin_klett_{wavelength}|smoothing window for klett method|21||
|maxIterConstrainFernald|The maximum iterations for searching the best Lidar Ratio with Constrained-AOD fernald method|20 Sr||
|minLRConstrainFernald|The minimum lidar ratio used for Constrained-AOD fernald method|1 Sr||
|maxLRConstrainFernald|The maximum lidar ratio used for Constrained-AOD fernald method|150 Sr||
|minDeltaAOD|The minimum AOD deviation that is required for Constrained-AOD fernald method|0.01||
|minRamanRefSNR387|The minimum SNR for the signal at the reference height. If SNR at the reference height is smaller than this value, raman method will not implemented.|40||
|minRamanRefSNR607|The minimum SNR for the signal at the reference height. If SNR at the reference height is smaller than this value, raman method will not implemented.|20||
|angstrexp|Default angstroem exponent for Raman method|0.9||
|smoothWin_raman_{wavelength}|smoothing window for raman method|61||
|LCMeanWindow|The window for calculating the Lidar Constant|50||
|LCMeanMinIndx|The minimum bin used for lidar constant calculation|70||
|LCMeanMaxIndx|The maximum bin used for lidar constant calculation|1000||
|LCCalibrationStatus|The tag for lidar calibration status, which will displayed in the output figures|["none", "Klett", "Raman", "Defaults"||"History"],
|quasi_smooth_h|temporal smoothing window for quasi retrieving method. For consistency, this parameter should be set for each channel|[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]||
|quasi_smooth_t|spatial smoothing window for quasi retrieving method. For consistency, this parameter should be set for each channel|[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]||
|hWVCaliBase|The minimum height used for calculating the IWV from lidar measurement.|120||
|minHWVCaliTop|The minimum top height required for calculating the IWV from lidar measurement.|2000||
|clear_thres_par_beta_1064|The threshold for discriminating clear atmosphere based on particle backscatter at 1064nm|1e-8 m^{-1}|Holger, AMT, 2016|
|turbid_thres_par_beta_1064|The threshold for discriminating turbid atmosphere based on particle backscatter at 1064nm|2e-7 m^{-1}|Holger, AMT, 2016|
|turbid_thres_par_beta_532|The threshold for discriminating turbid atmosphere based on particle backscatter at 532nm|2e-7 m^{-1}|Holger, AMT, 2016|
|droplet_thres_par_depol|The threshold for discriminating cloud droplets based on particle depolarization ratio at 532nm|0.05|Holger, AMT, 2016|
|spheroid_thres_par_depol|The threshold for discriminating spheriod paricles based on particle depolarization ratio at 532nm|0.07|Holger, AMT, 2016|
|unspheroid_thres_par_depol|The threshold for discriminating unspheriod paricles based on particle depolarization ratio at 532nm|0.2|Holger, AMT, 2016|
|ice_thres_par_depol|The threshold for discriminating ice crystals based on particle depolarization ratio at 532nm|0.35|Holger, AMT, 2016|
|ice_thres_vol_depol|The threshold for discriminating ice crystals based on volume depolarization ratio at 532nm|0.3|Holger, AMT, 2016|
|large_thres_ang|The threshold for discriminating large particles based on angstroem exponent|0.75|Holger, AMT, 2016|
|small_thres_ang|The threshold for discriminating small particles based on angstroem exponent|0.5|Holger, AMT, 2016|
|cloud_thres_par_beta_1064|The threshold for discriminating cloud layers based on quasi particle backscatter at 1064nm|2e-5 m^{-1}|Holger, AMT, 2016|
|min_atten_par_beta_1064|The minimum attenuation factor could be expected at the first 250m penatration depth|10|Holger, AMT, 2016|
|search_cloud_above|The parameter is used in cloud top detection. The cloud top will be searched between the first bin with quasi particle backscatter at 1064nm larger than cloud_thres_par_beta_1064 and +search_height_above|300 m|Holger, AMT, 2016|
|search_cloud_below|The parameter is used in cloud base detection. The cloud base will be searched between the first bin with quasi particle backscatter at 1064nm larger than cloud_thres_par_beta_1064 and -search_height_below|100 m|Holger, AMT, 2016|
|overlap{wavelength}Color|the color settings for the line of overlap|[0, 255, 64]||
|RCSProfileRange|Range of RCS in line plot. (original values have been divided by 1e6)|[1e-3, 1e2]||
|RCS{wavelength}ColorRange|Color range of RCS in color plot.(original values have been divided by 1e6|[1e-3, 1e2]||
|aerBscProfileRange|Range of aerosol backscatter coefficient profile|[-0.1, 10] Mm^{-1}*Sr^{-1}||
|aerExtProfileRange|Range of aerosol extinction coefficient profile|[-1, 300] Mm^{-1}||
|aerLRProfileRange|Range of aerosol lidar ratio profile.|[0, 120] Sr||
|WVMRProfileRange|Range of WVMR profile|[0, 10] g*kg^{-1}||
|WVMRColorRange|Color range of WVMR color plot|[0, 10] g*kg^{-1}||
|LC{wavelength}Range|Range of lidar constant profile|[0, 1e14]||
|WVConstRange|The y axis range for displaying the water vapor calibration constant | [0, 20] g*kg^{-1}||
|depolConstRange{wavelength}|The x axis range for displaying the depolarization calibration constant| [0, 0.2]||
|att_beta_cRange_{wavelength}|The color range for the attenuated backscatter| [0, 15] Mm^{-1}*sr^{-1}||
|quasi_beta_cRange_{wavelength}|The color range for the quasi backscatter| [0, 2] Mm^{-1}*sr^{-1}||
|quasi_Par_DR_cRange_532|The color range for the quasi particle depolarization ratio at 532 nm| [0, 0.4]||
|depolCaliFile{wavelength}|files to read and save depolarization calibration results|"pollyxt_tropos_depolcali_532_results.txt"||
|wvCaliFile|files to read and save water vapor calibration results|"pollyxt_tropos_wvcali_results.txt"||
|lcCaliFile|files to read and save lidar calibration constants|"pollyxt_tropos_lccali_results.txt"||
|logbookFile|path to the logbook file. Only the logfile generated by the pollylog program was accepted.|"C:\\Users\\StarWalker\\Documents\\Data\\PollyXT\\pollyxt_lacros\\logbook.csv"||
|radiosondeFolder|directory of the radiosonde file. The radiosonde file should be in standardized format, which has been defined in '../doc/meteorological_file_settings.pptx'|"/home/picasso/data/radiosonde"||
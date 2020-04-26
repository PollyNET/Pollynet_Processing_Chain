# Pollynet Processing Chain Changelog

## Version 2.0

### Release date

2020-04-22

### New features

1. Management calibration results with using database. [#20](https://github.com/PollyNET/Pollynet_Processing_Chain/issues/20)
2. Cloud geometrical properties from target classification products [#21](https://github.com/PollyNET/Pollynet_Processing_Chain/issues/21)
3. Enable the configuration of output image format [#28](https://github.com/PollyNET/Pollynet_Processing_Chain/issues/28)
4. Enable the control of output netCDF files [#26](https://github.com/PollyNET/Pollynet_Processing_Chain/issues/26)
5. New folder structure for polly configuration files [#31](https://github.com/PollyNET/Pollynet_Processing_Chain/issues/31)

### TODO 

* Documentation for algorithms and programs (ongoing)
* Products design (Product level and structure)
* Error analysis
* Interpolation of temperature datasets to remove the artifacts of RH at contigous data segments [#39](https://github.com/PollyNET/Pollynet_Processing_Chain/issues/39)
* Implement PollyXT_CYP [#33](https://github.com/PollyNET/Pollynet_Processing_Chain/issues/33)

## Version 1.3

### Release date

2019-08-04

### New features

1. Quasi-retrieving algorithm 2 with using channel ratio between Elastic and Raman signal
2. Rayleigh fit plot with normalization of the range-corrected signal at the reference height
3. Figures for results and aerosol TC from Quasi-retrieving algorithms 2
4. New housekeeping plots to include the `EN` and `shutter2`
5. Add `polly_global_config.json` to load defaults settings
6. Enable easy installation
7. Enable fully auto depol calibration
8. `Professional` git branches and management
9. Optimizing the figure layout and annotations
10. Seamless working with Polly database

## Version 1.2

### Release date

2019-05-22

### New features

1. Utilizing the ACTRIS data format to publish the processing results.
2. Extending the config files for more systems.
3. Revising typos in the scripts.
4. Adding support for easy-debugging.

## Version 1.1

### New features

|Time|Changes|Reasoning|
|:--:|:------|:--------|
|2019-01-21|Using converted extinction coefficients from backscatter coefficients for lidar calibration.|Extinction coefficients retrieved with Raman method loses the information under the full FOV and has very large uncertainty|
|2019-01-28|Add lidar calibration for 387 and 607 nm|Might be useful for retrieving aerosol properties below clouds with raman method.|
|2019-02-12|Add a function to read logbook from Martin's program and implement the visualization for calibration constants|Monitor the long term behavior of the system|
|2019-02-20|Add function to save the volume depolarization ratio|User demands|
|2019-02-26|Use previous calibrated results with a time lag less than a week as default values instead of pre-set default values in `*_default.json`|Remove the repeated step to set up a new default file in case settings of the lidar were changed|
|2019-03-28|Change the water vapor calibration function. Remove the SNR determination and replace with fixed integration height|SNR determination can not catch the lofted moist layer and will lead to large calibration error.|
|2019-03-31|Add more iteration times for the quasi-retrieving method|Make the quasi backscatter at 355 and 532 nm converged to the true values|

## Version 1.0

### New features

1. aerosol retrieving
2. water vapor calibration
3. depolarization calibration
4. lidar calibration
5. data visualization
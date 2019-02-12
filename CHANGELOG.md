## Pollynet Processing Chain Changelog

### Version 1.1

#### Notable Changes

|Time|Changes|Reasoning|
|:--:|:------|:--------|
|2019-01-21|Using converted extinction coefficients from backscatter coefficients for lidar calibration.|Extinction coefficients retrieved with Raman method loses the information under the full FOV and has very large uncertainty|
|2019-01-28|Add lidar calibration for 387 and 607 nm|Might be useful for retrieving aerosol properties below clouds with raman method.|
|2019-02-12|Add a function to read logbook from Martin's program and implement the visualization for calibration constants|Monitor the long term behavior of the system|

### Version 1.0

Basic funtionality, including:

    - aerosol retrieving
    - water vapor calibration
    - depolarization calibration
    - lidar calibration
    - data visualization
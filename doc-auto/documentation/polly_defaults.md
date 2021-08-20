## Polly Default Settings for pollynet processing chain

- [Polly Default Settings for pollynet processing chain](#polly-default-settings-for-pollynet-processing-chain)
  - [Description](#description)
  - [Polly Systems](#polly-systems)
    - [Polly_1V2](#polly1v2)
    - [PollyXT-DWD](#pollyxt-dwd)
    - [PollyXT-LACROS](#pollyxt-lacros)
    - [arielle](#arielle)
    - [PollyXT-UW](#pollyxt-uw)
    - [PollyXT-TROPOS](#pollyxt-tropos)
    - [PollyXT-FMI](#pollyxt-fmi)
    - [PollyXT-NOA](#pollyxt-noa)
    - [PollyXT-TJK](#pollyxt-tjk)

### Description

Polly defaults are used for configuring the processing program, when the calibration procedure fails. At present stage, there are 3 calibration procedures which are essential for the program: lidar constants, depolarization calibration constant and water vapor calibration constant. Besides, the overlap file is also recommended to be attached to compare with the estimated overlap function through the signal ratio between Near-Range (NR) and Far-Range (FR) channels. In general, different polly systems have their own specific default settings because of their different functionalities. Old polly system has less channels, which in the end would require less calibration procedures and thus less default settings. The most advanced polly system, like the arielle, has been powered with 13 channels, namely 3β+2α+2δ+2FOV, which needs more efforts for retrieving the products.

### Polly Systems

The defaults for the operational polly systems were listed as below, which are highly dependent on their channels. Detailed information about the instrument can be found in [here](../doc/pollynet.md).

#### Polly_1V2

|settings|meaning|Data Type|example|
|:------:|:------|:-------:|:-----:|
|depolCaliConst532|V* at 532. If depol calibration failed because of cloud contamination and there was no available V* within 1 week, the default value will be taken for depol caculations|float|0.024443|
|depolCaliConstStd532|std of V* at 532|float|0.0|
|LC|lidar constant. If lidar calibration failed and there was no available lidar constants within 1 week, the default values will be taken for calibrate the lidar signal. The order of this variable is the same like the order of the channels|array|[16893959541573.252000, 1, 1, 1, 28466210203696.203000]|
|LCStd|std of the lidar constants|array|[0, 0, 0, 0, 0]|
|overlapFile532|overlap file for saving the overlap function of 532 channel. This file can only have two columns: one is the height [m] and the other is the overlap function. There should be 1 header to describe the variables. An exemplified one can be found in the folder of '/lib/pollyDefaults/'|string|"polly_1v2__overlap_532.txt"|
|molDepol532|molecule depolarization ratio at 532 nm. In theory, this value can be calculated based on the filter bandwidth and central wavelength. But due to some system effects from retardation, diattenuation and depolarization, the theoritical value always deviate with the measured molecular background volume depolarization ratio. And this will introduce large error for calculating the particle depolarization ratio of weak aerosol layers. Therefore, we setup this default to cancel out some part of the influences|float|0.0053|
|molDepolStd532|std of molecule depolarization ratio at 532 nm.|float|0.0|

#### PollyXT-DWD

|settings|meaning|Data Type|example|
|:------:|:------|:-------:|:-----:|
|depolCaliConst532|V* at 532. If depol calibration failed because of cloud contamination and there was no available V* within 1 week, the default value will be taken for depol caculations|float|0.024443|
|depolCaliConstStd532|std of V* at 532|float|0.0|
|LC|lidar constant. If lidar calibration failed and there was no available lidar constants within 1 week, the default values will be taken for calibrate the lidar signal. The order of this variable is the same like the order of the channels|array|[123459332446.982710, 1, 97878575429631.625000, 1, 1, 389530086877146.060000, 1, 1]|
|LCStd|std of the lidar constants|array|[0, 0, 0, 0, 0, 0, 0, 0]|
|overlapFile532|overlap file for saving the overlap function of 532 channel. This file can only have two columns: one is the height [m] and the other is the overlap function. There should be 1 header to describe the variables. An exemplified one can be found in the folder of '/lib/pollyDefaults/'|string|"pollyxt_dwd_overlap_532.txt"|
|overlapFile355|overlap file for saving the overlap function of 355 channel. This file can only have two columns: one is the height [m] and the other is the overlap function. There should be 1 header to describe the variables. An exemplified one can be found in the folder of '/lib/pollyDefaults/'|string|"pollyxt_dwd_overlap_355.txt"|
|molDepol532|molecule depolarization ratio at 532 nm. In theory, this value can be calculated based on the filter bandwidth and central wavelength. But due to some system effects from retardation, diattenuation and depolarization, the theoritical value always deviate with the measured molecular background volume depolarization ratio. And this will introduce large error for calculating the particle depolarization ratio of weak aerosol layers. Therefore, we setup this default to cancel out some part of the influences|float|0.0053|
|molDepolStd532|std of molecule depolarization ratio at 532 nm.|float|0.0|

#### PollyXT-LACROS

|settings|meaning|Data Type|example|
|:------:|:------|:-------:|:-----:|
|depolCaliConst532|V* at 532. If depol calibration failed because of cloud contamination and there was no available V* within 1 week, the default value will be taken for depol caculations|float|0.024443|
|depolCaliConstStd532|std of V* at 532|float|0.0|
|depolCaliConst355|V* at 355. If depol calibration failed because of cloud contamination and there was no available V* within 1 week, the default value will be taken for depol caculations|float|0.024443|
|depolCaliConstStd355|std of V* at 355|float|0.0|
|LC|lidar constant. If lidar calibration failed and there was no available lidar constants within 1 week, the default values will be taken for calibrate the lidar signal. The order of this variable is the same like the order of the channels|array|[42545559767070.414000, 1, 6.3e13, 1, 97878575429631.625000, 1, 2.2e14, 389530086877146.060000, 1, 1, 1, 1, 1]|
|LCStd|std of the lidar constants|array|[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]|
|overlapFile532|overlap file for saving the overlap function of 532 channel. This file can only have two columns: one is the height [m] and the other is the overlap function. There should be 1 header to describe the variables. An exemplified one can be found in the folder of '/lib/pollyDefaults/'|string|"pollyxt_lacros_overlap_532.txt"|
|overlapFile355|overlap file for saving the overlap function of 355 channel. This file can only have two columns: one is the height [m] and the other is the overlap function. There should be 1 header to describe the variables. An exemplified one can be found in the folder of '/lib/pollyDefaults/'|string|"pollyxt_lacros_overlap_355.txt"|
|molDepol532|molecule depolarization ratio at 532 nm. In theory, this value can be calculated based on the filter bandwidth and central wavelength. But due to some system effects from retardation, diattenuation and depolarization, the theoritical value always deviate with the measured molecular background volume depolarization ratio. And this will introduce large error for calculating the particle depolarization ratio of weak aerosol layers. Therefore, we setup this default to cancel out some part of the influences|float|0.0053|
|molDepolStd532|std of molecule depolarization ratio at 532 nm.|float|0.0|
|molDepol355|molecule depolarization ratio at 355 nm. In theory, this value can be calculated based on the filter bandwidth and central wavelength. But due to some system effects from retardation, diattenuation and depolarization, the theoritical value always deviate with the measured molecular background volume depolarization ratio. And this will introduce large error for calculating the particle depolarization ratio of weak aerosol layers. Therefore, we setup this default to cancel out some part of the influences|float|0.0239|
|molDepolStd355|std of molecule depolarization ratio at 355 nm.|float|0.0|
|wvconst|water vapor calibration constant [g*kg^{-1}]. If the water vapor calibration cannot be done and there was no available calibration constant within 1 week, the default water vapor constant will be used.|float|15.0|
|wvconstStd|std of water vapor calibration constant [g*kg^{-1}].|float|0.0|

#### arielle

|settings|meaning|Data Type|example|
|:------:|:------|:-------:|:-----:|
|depolCaliConst532|V* at 532. If depol calibration failed because of cloud contamination and there was no available V* within 1 week, the default value will be taken for depol caculations|float|0.024443|
|depolCaliConstStd532|std of V* at 532|float|0.0|
|LC|lidar constant. If lidar calibration failed and there was no available lidar constants within 1 week, the default values will be taken for calibrate the lidar signal. The order of this variable is the same like the order of the channels.|array|[123459332446.982710, 1, 97878575429631.625000, 1, 1, 389530086877146.060000, 1, 1]|
|depolCaliConst355|V* at 355. If depol calibration failed because of cloud contamination and there was no available V* within 1 week, the default value will be taken for depol caculations|float|0.024443|
|depolCaliConstStd355|std of V* at 355|float|0.0|
|LC|lidar constant. If lidar calibration failed and there was no available lidar constants within 1 week, the default values will be taken for calibrate the lidar signal. The order of this variable is the same like the order of the channels|array|[42545559767070.414000, 1, 6.3e13, 1, 97878575429631.625000, 1, 2.2e14, 389530086877146.060000, 1, 1, 1, 1, 1]|
|LCStd|std of the lidar constants|array|[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]|
|overlapFile532|overlap file for saving the overlap function of 532 channel. This file can only have two columns: one is the height [m] and the other is the overlap function. There should be 1 header to describe the variables. An exemplified one can be found in the folder of '/lib/pollyDefaults/'|string|"arielle_overlap_532.txt"|
|overlapFile355|overlap file for saving the overlap function of 355 channel. This file can only have two columns: one is the height [m] and the other is the overlap function. There should be 1 header to describe the variables. An exemplified one can be found in the folder of '/lib/pollyDefaults/'|string|"arielle_overlap_355.txt"|
|molDepol532|molecule depolarization ratio at 532 nm. In theory, this value can be calculated based on the filter bandwidth and central wavelength. But due to some system effects from retardation, diattenuation and depolarization, the theoritical value always deviate with the measured molecular background volume depolarization ratio. And this will introduce large error for calculating the particle depolarization ratio of weak aerosol layers. Therefore, we setup this default to cancel out some part of the influences|float|0.0053|
|molDepolStd532|std of molecule depolarization ratio at 532 nm.|float|0.0|
|molDepol355|molecule depolarization ratio at 355 nm. In theory, this value can be calculated based on the filter bandwidth and central wavelength. But due to some system effects from retardation, diattenuation and depolarization, the theoritical value always deviate with the measured molecular background volume depolarization ratio. And this will introduce large error for calculating the particle depolarization ratio of weak aerosol layers. Therefore, we setup this default to cancel out some part of the influences|float|0.0239|
|molDepolStd355|std of molecule depolarization ratio at 355 nm.|float|0.0|
|wvconst|water vapor calibration constant [g*kg^{-1}]. If the water vapor calibration cannot be done and there was no available calibration constant within 1 week, the default water vapor constant will be used.|float|15.0|
|wvconstStd|std of water vapor calibration constant [g*kg^{-1}].|float|0.0|

#### PollyXT-UW

|settings|meaning|Data Type|example|
|:------:|:------|:-------:|:-----:|
|depolCaliConst532|V* at 532. If depol calibration failed because of cloud contamination and there was no available V* within 1 week, the default value will be taken for depol caculations|float|0.024443|
|depolCaliConstStd532|std of V* at 532|float|0.0|
|depolCaliConst355|V* at 355. If depol calibration failed because of cloud contamination and there was no available V* within 1 week, the default value will be taken for depol caculations|float|0.024443|
|depolCaliConstStd355|std of V* at 355|float|0.0|
|LC|lidar constant. If lidar calibration failed and there was no available lidar constants within 1 week, the default values will be taken for calibrate the lidar signal. The order of this variable is the same like the order of the channels|array|[42545559767070.414000, 1, 6.3e13, 1, 97878575429631.625000, 1, 2.2e14, 389530086877146.060000, 1, 1, 1, 1, 1]|
|LCStd|std of the lidar constants|array|[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]|
|overlapFile532|overlap file for saving the overlap function of 532 channel. This file can only have two columns: one is the height [m] and the other is the overlap function. There should be 1 header to describe the variables. An exemplified one can be found in the folder of '/lib/pollyDefaults/'|string|"pollyxt_uw_overlap_532.txt"|
|overlapFile355|overlap file for saving the overlap function of 355 channel. This file can only have two columns: one is the height [m] and the other is the overlap function. There should be 1 header to describe the variables. An exemplified one can be found in the folder of '/lib/pollyDefaults/'|string|"pollyxt_uw_overlap_355.txt"|
|molDepol532|molecule depolarization ratio at 532 nm. In theory, this value can be calculated based on the filter bandwidth and central wavelength. But due to some system effects from retardation, diattenuation and depolarization, the theoritical value always deviate with the measured molecular background volume depolarization ratio. And this will introduce large error for calculating the particle depolarization ratio of weak aerosol layers. Therefore, we setup this default to cancel out some part of the influences|float|0.0053|
|molDepolStd532|std of molecule depolarization ratio at 532 nm.|float|0.0|
|molDepol355|molecule depolarization ratio at 355 nm. In theory, this value can be calculated based on the filter bandwidth and central wavelength. But due to some system effects from retardation, diattenuation and depolarization, the theoritical value always deviate with the measured molecular background volume depolarization ratio. And this will introduce large error for calculating the particle depolarization ratio of weak aerosol layers. Therefore, we setup this default to cancel out some part of the influences|float|0.0239|
|molDepolStd355|std of molecule depolarization ratio at 355 nm.|float|0.0|
|wvconst|water vapor calibration constant [g*kg^{-1}]. If the water vapor calibration cannot be done and there was no available calibration constant within 1 week, the default water vapor constant will be used.|float|15.0|
|wvconstStd|std of water vapor calibration constant [g*kg^{-1}].|float|0.0|

#### PollyXT-TROPOS

|settings|meaning|Data Type|example|
|:------:|:------|:-------:|:-----:|
|depolCaliConst532|V* at 532. If depol calibration failed because of cloud contamination and there was no available V* within 1 week, the default value will be taken for depol caculations|float|0.024443|
|depolCaliConstStd532|std of V* at 532|float|0.0|
|depolCaliConst355|V* at 355. If depol calibration failed because of cloud contamination and there was no available V* within 1 week, the default value will be taken for depol caculations|float|0.024443|
|depolCaliConstStd355|std of V* at 355|float|0.0|
|LC|lidar constant. If lidar calibration failed and there was no available lidar constants within 1 week, the default values will be taken for calibrate the lidar signal. The order of this variable is the same like the order of the channels|array|[42545559767070.414000, 1, 6.3e13, 1, 97878575429631.625000, 1, 2.2e14, 389530086877146.060000, 1, 1, 1, 1, 1]|
|LCStd|std of the lidar constants|array|[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]|
|overlapFile532|overlap file for saving the overlap function of 532 channel. This file can only have two columns: one is the height [m] and the other is the overlap function. There should be 1 header to describe the variables. An exemplified one can be found in the folder of '/lib/pollyDefaults/'|string|"pollyxt_tropos_overlap_532.txt"|
|overlapFile355|overlap file for saving the overlap function of 355 channel. This file can only have two columns: one is the height [m] and the other is the overlap function. There should be 1 header to describe the variables. An exemplified one can be found in the folder of '/lib/pollyDefaults/'|string|"pollyxt_tropos_overlap_355.txt"|
|molDepol532|molecule depolarization ratio at 532 nm. In theory, this value can be calculated based on the filter bandwidth and central wavelength. But due to some system effects from retardation, diattenuation and depolarization, the theoritical value always deviate with the measured molecular background volume depolarization ratio. And this will introduce large error for calculating the particle depolarization ratio of weak aerosol layers. Therefore, we setup this default to cancel out some part of the influences|float|0.0053|
|molDepolStd532|std of molecule depolarization ratio at 532 nm.|float|0.0|
|molDepol355|molecule depolarization ratio at 355 nm. In theory, this value can be calculated based on the filter bandwidth and central wavelength. But due to some system effects from retardation, diattenuation and depolarization, the theoritical value always deviate with the measured molecular background volume depolarization ratio. And this will introduce large error for calculating the particle depolarization ratio of weak aerosol layers. Therefore, we setup this default to cancel out some part of the influences|float|0.0239|
|molDepolStd355|std of molecule depolarization ratio at 355 nm.|float|0.0|
|wvconst|water vapor calibration constant [g*kg^{-1}]. If the water vapor calibration cannot be done and there was no available calibration constant within 1 week, the default water vapor constant will be used.|float|15.0|
|wvconstStd|std of water vapor calibration constant [g*kg^{-1}].|float|0.0|

#### PollyXT-FMI

|settings|meaning|Data Type|example|
|:------:|:------|:-------:|:-----:|
|depolCaliConst532|V* at 532. If depol calibration failed because of cloud contamination and there was no available V* within 1 week, the default value will be taken for depol caculations|float|0.024443|
|depolCaliConstStd532|std of V* at 532|float|0.0|
|depolCaliConst355|V* at 355. If depol calibration failed because of cloud contamination and there was no available V* within 1 week, the default value will be taken for depol caculations|float|0.024443|
|depolCaliConstStd355|std of V* at 355|float|0.0|
|LC|lidar constant. If lidar calibration failed and there was no available lidar constants within 1 week, the default values will be taken for calibrate the lidar signal. The order of this variable is the same like the order of the channels|array|[42545559767070.414000, 1, 6.3e13, 1, 97878575429631.625000, 1, 2.2e14, 389530086877146.060000, 1, 1, 1, 1, 1]|
|LCStd|std of the lidar constants|array|[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]|
|overlapFile532|overlap file for saving the overlap function of 532 channel. This file can only have two columns: one is the height [m] and the other is the overlap function. There should be 1 header to describe the variables. An exemplified one can be found in the folder of '/lib/pollyDefaults/'|string|"pollyxt_fmi_overlap_532.txt"|
|overlapFile355|overlap file for saving the overlap function of 355 channel. This file can only have two columns: one is the height [m] and the other is the overlap function. There should be 1 header to describe the variables. An exemplified one can be found in the folder of '/lib/pollyDefaults/'|string|"pollyxt_fmi_overlap_355.txt"|
|molDepol532|molecule depolarization ratio at 532 nm. In theory, this value can be calculated based on the filter bandwidth and central wavelength. But due to some system effects from retardation, diattenuation and depolarization, the theoritical value always deviate with the measured molecular background volume depolarization ratio. And this will introduce large error for calculating the particle depolarization ratio of weak aerosol layers. Therefore, we setup this default to cancel out some part of the influences|float|0.0053|
|molDepolStd532|std of molecule depolarization ratio at 532 nm.|float|0.0|
|molDepol355|molecule depolarization ratio at 355 nm. In theory, this value can be calculated based on the filter bandwidth and central wavelength. But due to some system effects from retardation, diattenuation and depolarization, the theoritical value always deviate with the measured molecular background volume depolarization ratio. And this will introduce large error for calculating the particle depolarization ratio of weak aerosol layers. Therefore, we setup this default to cancel out some part of the influences|float|0.0239|
|molDepolStd355|std of molecule depolarization ratio at 355 nm.|float|0.0|
|wvconst|water vapor calibration constant [g*kg^{-1}]. If the water vapor calibration cannot be done and there was no available calibration constant within 1 week, the default water vapor constant will be used.|float|15.0|
|wvconstStd|std of water vapor calibration constant [g*kg^{-1}].|float|0.0|

#### PollyXT-NOA 

**Attention:** The setup has been upgraded from 2 near-range channels to 4 near-range channels at 2016.

|settings|meaning|Data Type|example|
|:------:|:------|:-------:|:-----:|
|depolCaliConst532|V* at 532. If depol calibration failed because of cloud contamination and there was no available V* within 1 week, the default value will be taken for depol caculations|float|0.024443|
|depolCaliConstStd532|std of V* at 532|float|0.0|
|depolCaliConst355|V* at 355. If depol calibration failed because of cloud contamination and there was no available V* within 1 week, the default value will be taken for depol caculations|float|0.024443|
|depolCaliConstStd355|std of V* at 355|float|0.0|
|LC|lidar constant. If lidar calibration failed and there was no available lidar constants within 1 week, the default values will be taken for calibrate the lidar signal. The order of this variable is the same like the order of the channels|array|[42545559767070.414000, 1, 6.3e13, 1, 97878575429631.625000, 1, 2.2e14, 389530086877146.060000, 1, 1, 1, 1, 1]|
|LCStd|std of the lidar constants|array|[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]|
|overlapFile532|overlap file for saving the overlap function of 532 channel. This file can only have two columns: one is the height [m] and the other is the overlap function. There should be 1 header to describe the variables. An exemplified one can be found in the folder of '/lib/pollyDefaults/'|string|"pollyxt_noa_overlap_532.txt"|
|overlapFile355|overlap file for saving the overlap function of 355 channel. This file can only have two columns: one is the height [m] and the other is the overlap function. There should be 1 header to describe the variables. An exemplified one can be found in the folder of '/lib/pollyDefaults/'|string|"pollyxt_noa_overlap_355.txt"|
|molDepol532|molecule depolarization ratio at 532 nm. In theory, this value can be calculated based on the filter bandwidth and central wavelength. But due to some system effects from retardation, diattenuation and depolarization, the theoritical value always deviate with the measured molecular background volume depolarization ratio. And this will introduce large error for calculating the particle depolarization ratio of weak aerosol layers. Therefore, we setup this default to cancel out some part of the influences|float|0.0053|
|molDepolStd532|std of molecule depolarization ratio at 532 nm.|float|0.0|
|molDepol355|molecule depolarization ratio at 355 nm. In theory, this value can be calculated based on the filter bandwidth and central wavelength. But due to some system effects from retardation, diattenuation and depolarization, the theoritical value always deviate with the measured molecular background volume depolarization ratio. And this will introduce large error for calculating the particle depolarization ratio of weak aerosol layers. Therefore, we setup this default to cancel out some part of the influences|float|0.0239|
|molDepolStd355|std of molecule depolarization ratio at 355 nm.|float|0.0|
|wvconst|water vapor calibration constant [g*kg^{-1}]. If the water vapor calibration cannot be done and there was no available calibration constant within 1 week, the default water vapor constant will be used.|float|15.0|
|wvconstStd|std of water vapor calibration constant [g*kg^{-1}].|float|0.0|

#### PollyXT-TJK

|settings|meaning|Data Type|example|
|:------:|:------|:-------:|:-----:|
|depolCaliConst532|V* at 532. If depol calibration failed because of cloud contamination and there was no available V* within 1 week, the default value will be taken for depol caculations|float|0.024443|
|depolCaliConstStd532|std of V* at 532|float|0.0|
|depolCaliConst355|V* at 355. If depol calibration failed because of cloud contamination and there was no available V* within 1 week, the default value will be taken for depol caculations|float|0.024443|
|depolCaliConstStd355|std of V* at 355|float|0.0|
|LC|lidar constant. If lidar calibration failed and there was no available lidar constants within 1 week, the default values will be taken for calibrate the lidar signal. The order of this variable is the same like the order of the channels|array|[42545559767070.414000, 1, 6.3e13, 1, 97878575429631.625000, 1, 2.2e14, 389530086877146.060000, 1, 1, 1, 1, 1]|
|LCStd|std of the lidar constants|array|[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]|
|overlapFile532|overlap file for saving the overlap function of 532 channel. This file can only have two columns: one is the height [m] and the other is the overlap function. There should be 1 header to describe the variables. An exemplified one can be found in the folder of '/lib/pollyDefaults/'|string|"pollyxt_tjk_overlap_532.txt"|
|overlapFile355|overlap file for saving the overlap function of 355 channel. This file can only have two columns: one is the height [m] and the other is the overlap function. There should be 1 header to describe the variables. An exemplified one can be found in the folder of '/lib/pollyDefaults/'|string|"pollyxt_tjk_overlap_355.txt"|
|molDepol532|molecule depolarization ratio at 532 nm. In theory, this value can be calculated based on the filter bandwidth and central wavelength. But due to some system effects from retardation, diattenuation and depolarization, the theoritical value always deviate with the measured molecular background volume depolarization ratio. And this will introduce large error for calculating the particle depolarization ratio of weak aerosol layers. Therefore, we setup this default to cancel out some part of the influences|float|0.0053|
|molDepolStd532|std of molecule depolarization ratio at 532 nm.|float|0.0|
|molDepol355|molecule depolarization ratio at 355 nm. In theory, this value can be calculated based on the filter bandwidth and central wavelength. But due to some system effects from retardation, diattenuation and depolarization, the theoritical value always deviate with the measured molecular background volume depolarization ratio. And this will introduce large error for calculating the particle depolarization ratio of weak aerosol layers. Therefore, we setup this default to cancel out some part of the influences|float|0.0239|
|molDepolStd355|std of molecule depolarization ratio at 355 nm.|float|0.0|
|wvconst|water vapor calibration constant [g*kg^{-1}]. If the water vapor calibration cannot be done and there was no available calibration constant within 1 week, the default water vapor constant will be used.|float|15.0|
|wvconstStd|std of water vapor calibration constant [g*kg^{-1}].|float|0.0|
function data = pollyPreprocess(data, varargin)
% POLLYPREPROCESS Deadtime correction, background correction, first-bin shift,
% mask for low-SNR and mask for depolarization-calibration process.
% USAGE:
%    [data] = pollyPreprocess(data)
% INPUTS:
%    data: struct
%        rawSignal: array
%            signal. [Photon Count]
%        mShots: array
%            number of the laser shots for each profile.
%        mTime: array
%            datetime array for the measurement time of each profile.
%        depCalAng: array
%            angle of the polarizer in the receiving channel. (>0 means 
%            calibration process starts)
%        zenithAng: array
%            zenith angle of the laer beam.
%        repRate: float
%            laser pulse repetition rate. [s^-1]
%        hRes: float
%            spatial resolution [m]
%        mSite: string
%            measurement site.
% KEYWORDS:
%    flagForceMeasTime: logical
%        flag to control whether to align measurement time with file creation
%        time, instead of taking the measurement time in the data file.
%        (default: false)
%    maxHeightBin: numeric
%        number of range bins to read out from data file. (default: 3000)
%    firstBinIndex: numeric
%        index of first bin to read out. (default: 1)
%    pollyType: char
%        polly version. (default: 'arielle')
%    flagDeadTimeCorrection: logical
%        flag to control whether to apply deadtime correction. (default: false)
%    deadtimeCorrectionMode: numeric
%        deadtime correction mode. (default: 2)
%        1: polynomial correction with parameters saved in data file.
%        2: non-paralyzable correction
%        3: polynomail correction with user defined parameters
%        4: disable deadtime correction
%    deadtimeParams: numeric
%        deadtime parameters. (default: [])
%    flagRamanTempCor: logical
%        flag to implement temperature correction for Raman signal.
%    flagRamanChannelTempCor: logical
%        flag to denote channel that needs temperature correction.
%    meteorDataSource: str
%        meteorological data type.
%        e.g., 'gdas1'(default), 'standard_atmosphere', 'websonde', 'radiosonde'
%    gdas1Site: str
%        the GDAS1 site for the current campaign.
%    gdas1_folder: str
%        the main folder of the GDAS1 profiles.
%    radiosondeSitenum: integer
%        site number, which can be found in 
%        doc/radiosonde-station-list.txt.
%    radiosondeFolder: str
%        the folder of the sonding files.
%    radiosondeType: integer
%        file type of the radiosonde file.
%        - 1: radiosonde file for MOSAiC (default)
%        - 2: radiosonde file for MUA
%    bgCorrectionIndex: 2-element array
%        base and top index of bins for background estimation.
%        (defaults: [1, 2])
%    asl: numeric
%        above sea level in meters. (default: 0)
%    initialPolAngle: numeric
%        initial polarization angle of the polarizer for polarization
%        calibration. (default: 0)
%    maskPolCalAngle: cell
%        mask for positive and negative calibration angle of the polarizer, in
%        which 'p' stands for positive angle, while 'n' for negative angle.
%        (default: {})
%    minSNRThresh: numeric
%        lower bound of signal-noise ratio.
%    minPC_fog: numeric
%        minimun number of photon count after strong attenuation by fog.
%    flagFarRangeChannel: logical
%        flags of far-range channel.
%    flag532nmChannel: logical
%        flags of channels with central wavelength (CW) at 532 nm.
%    flagTotalChannel: logical
%        flags of channels receiving total elastic signal.
%    flag355nmChannel: logical
%        flags of channels with CW at 355 nm.
%    flag607nmChannel: logical
%        flags of channels with CW at 607 nm.
%    flag387nmChannel: logical
%        flags of channels with CW at 387 nm.
%    flag407nmChannel: logical
%        flags of channels with CW at 407 nm.
%    flag532nmRotRaman: logical
%        flags of rotational Raman channels with CW at 532 nm.
% OUTPUTS:
%    data: struct
%        rawSignal: array
%            signal. [Photon Count]
%        mShots: array
%            number of the laser shots for each profile.
%        mTime: array
%            datetime array for the measurement time of each profile.
%        depCalAng: array
%            angle of the polarizer in the receiving channel. (>0 means 
%            calibration process starts)
%        zenithAng: array
%            zenith angle of the laer beam.
%        repRate: float
%            laser pulse repetition rate. [s^-1]
%        hRes: float
%            spatial resolution [m]
%        mSite: string
%            measurement site.
%        deadtime: matrix (channel x polynomial_orders)
%            deadtime correction parameters.
%        signal: array
%            Background removed signal
%        bg: array
%            background
%        height: array
%            height. [m]
%        lowSNRMask: logical
%            If SNR less SNRmin, mask is set true. Otherwise, false
%        depCalMask: logical
%            If polly was doing polarization calibration, depCalMask is set
%            true. Otherwise, false.
%        fogMask: logical
%            If it is foggy which means the signal will be very weak, 
%            fogMask will be set true. Otherwise, false
%        mask607Off: logical
%            mask of PMT on/off status at 607 nm channel.
%        mask387Off: logical
%            mask of PMT on/off status at 387 nm channel.
%        mask407Off: logical
%            mask of PMT on/off status at 407 nm channel.
%        mask532RROff: logical
%            mask of PMT on/off status at 532 nm rotational Raman channel.
% EXAMPLE:
% HISTORY:
%    2018-12-16: First edition by Zhenping.
%    2019-07-10: Add mask for laser shutter due to approaching airplanes.
%    2019-08-27: Add mask for turnoff of PMT at 607 and 387nm.
%    2021-01-19: Add keyword of 'flagForceMeasTime' to align measurement time.
%    2021-01-20: Re-sample the profiles into temporal resolution of 30-s.
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'data', @isstruct);
addParameter(p, 'flagForceMeasTime', false, @islogical);
addParameter(p, 'maxHeightBin', 3000, @isnumeric);
addParameter(p, 'firstBinIndex', 1, @isnumeric);
addParameter(p, 'firstBinHeight', 0, @isnumeric);
addParameter(p, 'pollyType', 'arielle', @ischar);
addParameter(p, 'flagDeadTimeCorrection', false, @islogical);
addParameter(p, 'deadtimeCorrectionMode', 2, @isnumeric);
addParameter(p, 'deadtimeParams', [], @isnumeric);
addParameter(p, 'flagRamanTempCor', false, @islogical);
addParameter(p, 'flagRamanChannelTempCor', false, @islogical);
addParameter(p, 'meteorDataSource', 'gdas1', @ischar);
addParameter(p, 'gdas1Site', '', @ischar);
addParameter(p, 'gdas1_folder', '', @ischar);
addParameter(p, 'radiosondeSitenum', 0, @isnumeric);
addParameter(p, 'radiosondeFolder', '', @ischar);
addParameter(p, 'radiosondeType', 1, @isnumeric);
addParameter(p, 'bgCorrectionIndex', [1, 2], @isnumeric);
addParameter(p, 'asl', 0, @isnumeric);
addParameter(p, 'initialPolAngle', 0, @isnumeric);
addParameter(p, 'maskPolCalAngle', {}, @iscell);
addParameter(p, 'minSNRThresh', [], @isnumeric);
addParameter(p, 'minPC_fog', 50, @isnumeric);
addParameter(p, 'flagFarRangeChannel', false, @islogical);
addParameter(p, 'flag532nmChannel', false, @islogical);
addParameter(p, 'flagTotalChannel', false, @islogical);
addParameter(p, 'flag355nmChannel', false, @islogical);
addParameter(p, 'flag607nmChannel', false, @islogical);
addParameter(p, 'flag387nmChannel', false, @islogical);
addParameter(p, 'flag407nmChannel', false, @islogical);
addParameter(p, 'flag532nmRotRaman', false, @islogical);

parse(p, data, varargin{:});

if isempty(data.rawSignal)
    return;
end

config = p.Results;   % copy name-value pairs to 'config'

%% Determine whether number of range bins is out of range
if (max(config.maxHeightBin + config.firstBinIndex - 1) > size(data.rawSignal, 2))
    warning('maxHeightBin or firstBinIndex is out of range.\nTotal number of range bin is %d.\nmaxHeightBin is %d\nfirstBinIndex is %d\n', size(data.rawSignal, 2), config.maxHeightBin, config.firstBinIndex);
    fprintf('Set maxHeightBin and firstBinIndex to default values.\n');
    config.maxHeightBin = ones(1, size(data.rawSignal, 1));
    config.firstBinIndex = 251;
end

%% Re-sample the temporal grid to 30 s, if it's not in 30s.
mShotsPer30s = 30 * data.repRate;
nInt = round(mShotsPer30s / nanmean(data.mShots(1, :), 2));   % number of profiles to be
                                                              % integrated. Usually, 600
                                                              % shots per 30 s

if nInt > 1
    % if shots of single profile is less than mShotsPer30s
    warning('MShots for single profile is not %4.0f... Please check!!!', mShotsPer30s);

    nProfInt = floor(size(data.mShots, 2) / nInt);
    mShotsInt = NaN(size(data.mShots, 1), nProfInt);
    mTimeInt = NaN(1, nProfInt);
    rawSignalInt = NaN(size(data.rawSignal, 1), size(data.rawSignal, 2), nProfInt);
    depCalAngInt = NaN(nProfInt, 1);

    for iProfInt = 1:nProfInt
        profIndx = ((iProfInt - 1) * nInt + 1):(iProfInt * nInt);
        mShotsInt(:, iProfInt) = nansum(data.mShots(:, profIndx), 2);
        mTimeInt(iProfInt) = data.mTime(1) + datenum(0, 1, 0, 0, 0, double(mShotsPer30s / data.repRate * (iProfInt - 1)));
        rawSignalInt(:, :, iProfInt) = repmat(nansum(data.rawSignal(:, :, profIndx), 3), 1, 1, 1);
        if ~ isempty(data.depCalAng)
            depCalAngInt(iProfInt) = data.depCalAng(profIndx(1));
        end
    end

    data.rawSignal = rawSignalInt;
    data.mTime = mTimeInt;
    data.mShots = mShotsInt;
    data.depCalAng = depCalAngInt;
end

%% Modify mShots
% Expected mShots should be an matrix with dims of nChannels x profiles
% However, old polly generate mShots variable with one dimension.
if (size(data.mShots, 1) ~= size(data.rawSignal, 1)) && (size(data.mShots, 2) ~= size(data.rawSignal, 3))
    data.mShots = repmat(transpose(data.mShots), size(data.rawSignal, 1), 1);
end

%% Re-locate measurement time forcefully.
if config.flagForceMeasTime
    data.mTime = data.filenameStartTime + ...
                 datenum(0, 1, 0, 0, 0, double(1:size(data.mTime, 2)) * 30);
end

%% Deadtime correction
rawSignal = pollyDTCor(data.rawSignal, data.mShots, data.hRes, ...
                'flagDeadTimeCorrection', config.flagDeadTimeCorrection, ...
                'deadtimeCorrectionMode', config.deadtimeCorrectionMode, ...
                'deadtime', data.deadtime, ...
                'deadtimeParams', config.deadtimeParams, ...
                'pollyType', config.pollyType);

%% Background Substraction
[sigBGCor, bg] = pollyRemoveBG(rawSignal, ...
    'bgCorrectionIndex', config.bgCorrectionIndex, ...
    'maxHeightBin', config.maxHeightBin, ...
    'firstBinIndex', config.firstBinIndex);
data.bg = bg;
data.signal = sigBGCor;

%% Height (first bin height correction)
data.height = double((0:(size(data.signal, 2)-1)) * data.hRes * ...
    cos(data.zenithAng / 180 * pi) + config.firstBinHeight);   % [m]
data.alt = double(data.height + config.asl);   % geopotential height
% distance between range bin and system.
data.distance0 = double(data.height ./ cos(data.zenithAng / 180 * pi));

%% Temperature effect correction (for Raman signal)
if config.flagRamanTempCor
    temperature = loadMeteor(mean(data.mTime), data.alt, ...
        'meteorDataSource', config.meteorDataSource, ...
        'gdas1Site', config.gdas1Site, ...
        'gdas1_folder', config.gdas1_folder, ...
        'radiosondeSitenum', config.radiosondeSitenum, ...
        'radiosondeFolder', config.radiosondeFolder, ...
        'radiosondeType', config.radiosondeType, ...
        'method', 'linear');
    absTemp = temperature + 273.17;
    corFac = transpose(exp(-0.001 * absTemp) ./ exp(-0.001210));

    for iCh = 1:size(data.signal, 1)
        if config.flagRamanChannelTempCor(iCh)
            data.signal(iCh, :, :) = squeeze(data.signal(iCh, :, :)) ./ repmat(corFac, 1, size(signal, 3));
        end
    end
end

%% Mask for bins with low SNR
SNR = pollySNR(data.signal, data.bg);
data.lowSNRMask = false(size(data.signal));
for iChannel = 1: size(data.signal, 1)
    data.lowSNRMask(iChannel, SNR(iChannel, :, :) < ...
                    config.minSNRThresh(iChannel)) = true;
end

%% Mask for polarization calibration
[data.depol_cal_ang_p_time_start, data.depol_cal_ang_p_time_end, ...
 data.depol_cal_ang_n_time_start, data.depol_cal_ang_n_time_end, ...
 depCalMask] = pollyPolCaliTime(data.depCalAng, data.mTime, ...
                                config.initialPolAngle, config.maskPolCalAngle);
data.depCalMask = transpose(depCalMask);

%% Mask for laser shutter
flagChannel532FR = config.flagFarRangeChannel & config.flag532nmChannel & config.flagTotalChannel;
flagChannel355FR = config.flagFarRangeChannel & config.flag355nmChannel & config.flagTotalChannel;
if any(flagChannel532FR)
    data.shutterOnMask = pollyIsLaserShutterOn(...
        squeeze(data.signal(flagChannel532FR, :, :)));
elseif any(flagChannel355FR)
    data.shutterOnMask = pollyIsLaserShutterOn(...
        squeeze(data.signal(flagChannel355FR, :, :)));
else
    warning('No suitable channel to determine the shutter status');
    data.shutterOnMask = false(size(data.mTime));
end

%% Mask for fog
data.fogMask = false(1, size(data.signal, 3));
is_channel_532_FR_Tot = config.flagFarRangeChannel & config.flag532nmChannel & config.flagTotalChannel;
data.fogMask(transpose(squeeze(sum(data.signal(is_channel_532_FR_Tot, 40:120, :), 2)) <= config.minPC_fog) & (~ data.shutterOnMask)) = true;

%% Mask for PMT on/off status of 607 nm channel
flagChannel607 = config.flagFarRangeChannel & config.flag607nmChannel;
data.mask607Off = pollyIs607Off(squeeze(data.signal(flagChannel607, :, :)));

%% Mask for PMT of 387 nm channel
flagChannel387 = config.flagFarRangeChannel & config.flag387nmChannel;
data.mask387Off = pollyIs387Off(squeeze(data.signal(flagChannel387, :, :)));

%% Mask for PMT of 407 nm channel
flagChannel407 = config.flagFarRangeChannel & config.flag407nmChannel;
data.mask407Off = pollyIs407Off(squeeze(data.signal(flagChannel407, :, :)));

%% Mask for PMT of Rotation Raman channel
flagChannel532RR = config.flagFarRangeChannel & config.flag532nmRotRaman;
data.mask532RROff = pollyIs607Off(squeeze(data.signal(flagChannel532RR, :, :)));

end

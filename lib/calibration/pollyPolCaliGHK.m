function [polCaliEta, polCaliEtaStd, polCaliTime, polCaliAttri] = pollyPolCaliGHK(data, K ,flagTot,flagCro,wavelength, varargin)
% POLLYPOLCALI calibrate the PollyXT cross channels for 355, 532 and 1064 nm with Delta90° method.
%
% USAGE:
%    [polCaliEta, polCaliEtaStd,polCaliFac, polCaliFacStd,  polCaliTime, polCaliAttri] = pollyPolCali(data, transRatio)
%
% INPUTS:
%    data: struct
%       data
%    transRatio: array
%        transmission ratios at each channel.
%
% KEYWORDS:
%    wavelength: char
%        '355nm' or '532nm' or '1064nm'
%    depolCaliMinBin: numeric
%        minimum search index for stable polarization calibration constants.
%    depolCaliMaxBin
%        maximum search index for stable polarization calibration constants.
%    depolCaliMinSNR: numeric
%        minimum signal-noise ratio for calculating polarization calibration constants.
%    depolCaliMaxSig: numeric
%        maximum signal in photon count (to avoid signal saturation).
%    relStdDPlus: numeric
%        maximum relative std of dplus that is allowed.
%    relStdDMinus: numeric
%        maximum relative std of dminus that is allowed.
%    depolCaliSegLen: numeric
%        segement length for testing the variability of the calibration results
%        to prevent of cloud contamintaion.
%    depolCaliSmWin: numeric
%        width of the sliding window for smoothing the signal.
%    dbFile: char
%        absolute path of the calibration database file.
%    pollyType: char
%        polly version. ('arielle')
%    flagUsePrevDepolConst: logical
%        whether to use previous calibration constants.
%    flagDepolCali: logical
%        whether to perform depolarization calibration.
%    default_polCaliEta: numeric
%        default eta for polarization calibration.
%    default_polCaliEtaStd
%        uncertainty of default eta for polarization calibration.
%
% OUTPUTS:
%    polCaliEta: numeric
%        polarization calibration eta.
%    polCaliEtaStd: numeric
%        uncertainty of eta for polarization calibration.
%    polCaliFac: numeric
%        polarization calibration constant.
%    polCaliFacStd: numeric
%        uncertainty of polarization calibration constant.
%    polCaliTime: 2-element array
%        time of depolarization calibration.
%    polCaliAttri: struct
%        polly polarization calibration attributes.
%
% HISTORY:
%    - 2018-12-17: First edition by Zhenping
%    - 2019-08-28: Add flag to control whether to do polarization calibration.
%    - 2020-04-18: Generalise the interface.
%
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'data', @isstruct);
%addRequired(p, 'G', @isnumeric);
%addRequired(p, 'H', @isnumeric);
addRequired(p, 'K', @isnumeric);
addParameter(p, 'wavelength', wavelength, @ischar);
addParameter(p, 'depolCaliMinBin', 0, @isnumeric);
addParameter(p, 'depolCaliMaxBin', 1, @isnumeric);
addParameter(p, 'depolCaliMinSNR', 1, @isnumeric);
addParameter(p, 'depolCaliMaxSig', 1, @isnumeric);
addParameter(p, 'relStdDPlus', 1, @isnumeric);
addParameter(p, 'relStdDMinus', 1, @isnumeric);
addParameter(p, 'depolCaliSegLen', 1, @isnumeric);
addParameter(p, 'depolCaliSmWin', 1, @isnumeric);
addParameter(p, 'dbFile', '', @ischar);
addParameter(p, 'pollyType', 'polly', @ischar);
addParameter(p, 'flagUsePrevDepolConst', false, @islogical);
addParameter(p, 'flagDepolCali', true', @islogical);
addParameter(p, 'default_polCaliEta', NaN, @isnumeric);
addParameter(p, 'default_polCaliEtaStd', NaN, @isnumeric);

parse(p, data, K, varargin{:});

polCaliEta = [];
polCaliEtaStd = [];
polCaliTime = [];
polCaliAttri = struct();

if isempty(data.rawSignal)
    return;
end

time = data.mTime;

if (~ any(flagTot)) || (~ any(flagCro))
    warning('Cross or total channel at'+wavelength+' does not exist.');
    return;
end
sigTot = squeeze(data.signal(flagTot, :, :));
bgTot = squeeze(data.bg(flagTot, :, :));
sigCro = squeeze(data.signal(flagCro, :, :));
bgCro = squeeze(data.bg(flagCro, :, :));

switch p.Results.wavelength

case '355nm'
%     if (~ any(flagTot)) || (~ any(flagCro))
%         warning('Cross or total channel at 355 nm does not exist.');
%         return;
%     end
    % polarization calibration at 355 nm
%     sigTot = squeeze(data.signal(flagTot, :, :));
%     bgTot = squeeze(data.bg(flagTot, :, :));
%     sigCro = squeeze(data.signal(flagCro, :, :));
%     bgCro = squeeze(data.bg(flagCro, :, :));

    [polCaliEta355, polCaliEtaStd355, polCaliStartTime355, polCaliStopTime355, polCalAttri355] = depolCaliGHK(...
        sigTot, bgTot, sigCro, bgCro, time, ...
        data.depol_cal_ang_p_time_start, data.depol_cal_ang_p_time_end, ...
        data.depol_cal_ang_n_time_start, data.depol_cal_ang_n_time_end, ...
        K, ...
        [p.Results.depolCaliMinBin, p.Results.depolCaliMaxBin], ...
        p.Results.depolCaliMinSNR, p.Results.depolCaliMaxSig, ...
        p.Results.relStdDPlus, p.Results.relStdDMinus, ...
        p.Results.depolCaliSegLen, p.Results.depolCaliSmWin);
    %polCalAttri355.polCaliEta355 = polCaliEta;
    %polCalAttri355.polCaliEtaStd355 = polCaliEtaStd;
    polCalAttri355.polCaliEta = polCaliEta355;
    polCalAttri355.polCaliEtaStd = polCaliEtaStd355;
    %polCalAttri355.polCaliFac = polCaliFac355;
    %polCalAttri355.polCaliFacStd = polCaliFacStd355;
    polCalAttri355.polCaliStartTime = polCaliStartTime355;
    polCalAttri355.polCaliStopTime = polCaliStopTime355;
    %print_msg('Polarization calibration eta_355 =', 'flagTimestamp', true);
    %polCaliEta355
    %%%% in future here it must be one more if, if db exist then, elsi if see
    %%%% if cali was succesful, if not then default
    if exist(p.Results.dbFile, 'file') == 2
        [polCaliEta, polCaliEtaStd, polCaliStartTime, polCaliStopTime] = selectDepolConst(...
            polCaliEta355, polCaliEtaStd355, ...
            polCaliStartTime355, polCaliStopTime355, ...
            mean(time), p.Results.dbFile, p.Results.pollyType, wavelength, ...
            'flagUsePrevDepolConst', p.Results.flagUsePrevDepolConst, ...
            'flagDepolCali', p.Results.flagDepolCali, ...
            'deltaTime', datenum(0, 1, 7), ...
            'default_polCaliEta', p.Results.default_polCaliEta, ...
            'default_polCaliEtaStd', p.Results.default_polCaliEtaStd);
        polCaliTime = [polCaliStartTime, polCaliStopTime];
        polCaliAttri = polCalAttri355;
    else
        polCaliEta = p.Results.default_polCaliEta;
        polCaliEtaStd = p.Results.default_polCaliEtaStd;
        polCaliTime = [polCaliStartTime355, polCaliStopTime355];
        polCaliAttri = polCalAttri355;
    end
    
case '532nm'
    % polarization calibration at 532 nm
%     if (~ any(flagTot)) || (~ any(flagCro))
%         warning('Cross or total channel at 532 nm does not exist.');
%         return;
%     end

    [polCaliEta, polCaliEtaStd, polCaliStartTime, polCaliStopTime, polCalAttri532] = depolCaliGHK(...
        sigTot, bgTot, sigCro, bgCro, time, ...
        data.depol_cal_ang_p_time_start, data.depol_cal_ang_p_time_end, ...
        data.depol_cal_ang_n_time_start, data.depol_cal_ang_n_time_end, ...
        K, ...
        [p.Results.depolCaliMinBin, p.Results.depolCaliMaxBin], ...
        p.Results.depolCaliMinSNR, p.Results.depolCaliMaxSig, ...
        p.Results.relStdDPlus, p.Results.relStdDMinus, ...
        p.Results.depolCaliSegLen, p.Results.depolCaliSmWin);
    polCalAttri532.polCaliEta = polCaliEta;
    polCalAttri532.polCaliEtaStd = polCaliEtaStd;
    %polCalAttri532.polCaliFac = polCaliFac532;
    %polCalAttri532.polCaliFacStd = polCaliFacStd532;
    polCalAttri532.polCaliStartTime = polCaliStartTime;
    polCalAttri532.polCaliStopTime = polCaliStopTime;
    %print_msg('Polarization calibration eta_532 =', 'flagTimestamp', true);
    %polCaliEta
    if exist(p.Results.dbFile, 'file') == 2
        [polCaliEta, polCaliEtaStd, polCaliStartTime, polCaliStopTime] = selectDepolConst(...
            polCaliEta, polCaliEtaStd, ...
            polCaliStartTime, polCaliStopTime, ...
            mean(time), p.Results.dbFile, p.Results.pollyType, '532', ...
            'flagUsePrevDepolConst', p.Results.flagUsePrevDepolConst, ...
            'flagDepolCali', p.Results.flagDepolCali, ...
            'deltaTime', datenum(0, 1, 7), ...
            'default_polCaliEta', p.Results.default_polCaliEta, ...
            'default_polCaliEtaStd', p.Results.default_polCaliEtaStd);
        polCaliTime = [polCaliStartTime, polCaliStopTime];
        polCaliAttri = polCalAttri532;
    else
        polCaliEta = p.Results.default_polCaliEta;
        polCaliEtaStd = p.Results.default_polCaliEtaStd;
        polCaliTime = [polCaliStartTime, polCaliStopTime];
        polCaliAttri = polCalAttri532;
    end

case '1064nm'
    [polCaliEta, polCaliEtaStd, polCaliStartTime, polCaliStopTime, polCalAttri1064] = depolCaliGHK(...
        sigTot, bgTot, sigCro, bgCro, time, ...
        data.depol_cal_ang_p_time_start, data.depol_cal_ang_p_time_end, ...
        data.depol_cal_ang_n_time_start, data.depol_cal_ang_n_time_end, ...
        K, ...
        [p.Results.depolCaliMinBin, p.Results.depolCaliMaxBin], ...
        p.Results.depolCaliMinSNR, p.Results.depolCaliMaxSig, ...
        p.Results.relStdDPlus, p.Results.relStdDMinus, ...
        p.Results.depolCaliSegLen, p.Results.depolCaliSmWin);
    polCalAttri1064.polCaliEta = polCaliEta;
    polCalAttri1064.polCaliEtaStd = polCaliEtaStd;
    polCalAttri1064.polCaliStartTime = polCaliStartTime;
    polCalAttri1064.polCaliStopTime = polCaliStopTime;
    %print_msg('Polarization calibration eta_1064 =', 'flagTimestamp', true);
    %polCaliEta
    if exist(p.Results.dbFile, 'file') == 2
        [polCaliEta, polCaliEtaStd, polCaliStartTime, polCaliStopTime] = selectDepolConst(...
            polCaliEta, polCaliEtaStd, ...
            polCaliStartTime, polCaliStopTime, ...
            mean(time), p.Results.dbFile, p.Results.pollyType, '1064', ...
            'flagUsePrevDepolConst', p.Results.flagUsePrevDepolConst, ...
            'flagDepolCali', p.Results.flagDepolCali, ...
            'deltaTime', datenum(0, 1, 7), ...
            'default_polCaliEta', p.Results.default_polCaliEta, ...
            'default_polCaliEtaStd', p.Results.default_polCaliEtaStd);
        polCaliTime = [polCaliStartTime, polCaliStopTime];
        polCaliAttri = polCalAttri1064;
    else
        polCaliEta = p.Results.default_polCaliEta;
        polCaliEtaStd = p.Results.default_polCaliEtaStd;
        polCaliTime = [polCaliStartTime, polCaliStopTime];
        polCaliAttri = polCalAttri1064;
    end
otherwise
    error('Unknown wavelength %s for polarization calibration.', p.Results.wavelength);
end


end
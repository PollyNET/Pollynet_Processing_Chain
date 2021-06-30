function [polCaliFac, polCaliFacStd, polCaliTime, polCaliAttri] = pollyPolCali(data, transRatio, varargin)
% POLLYPOLCALI calibrate the PollyXT cross channels for 355 and 532 nm
% with ±45° method.
% USAGE:
%    [polCaliFac355, polCaliFacStd355, polCaliFac532, polCaliFacStd532, polCaliAttri] = pollyPolCali(data)
% INPUTS:
%    data: struct
%        More detailed information can be found in doc/pollynet_processing_program.md
%    transRatio: array
%        transmission ratios at each channel.
% KEYWORDS:
%    wavelength: char
%        '355nm' or '532nm'.
%    depolCaliMinBin: numeric
%        minimum search index for stable depolarization calibration constants.
%    depolCaliMaxBin
%        maximum search index for stable depolarization calibration constants.
%    depolCaliMinSNR: numeric
%        minimum signal-noise ratio for calculating depolarization calibration constants.
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
%    default_depolconst: numeric
%        default depolarization calibration constant.
%    default_depolconstStd
%        standard deviation of default depolarization calibration constant.
% OUTPUTS:
%    polCaliFac: numeric
%        depolarization calibration constant.
%    polCaliFacStd: numeric
%        uncertainty of depolarization calibration constant.
%    polCaliTime: 2-element array
%        [start, stop] time of depolarization calibration.
%    polCaliAttri: struct
%
% EXAMPLE:
% HISTORY:
%    2018-12-17: First edition by Zhenping
%    2019-08-28: Add flag to control whether to do depolarization
%                calibration.
%    2020-04-18: Generalise the interface.
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'data', @isstruct);
addRequired(p, 'transRatio', @isnumeric);
addParameter(p, 'wavelength', '532nm', @ischar);
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
addParameter(p, 'default_depolconst', NaN, @isnumeric);
addParameter(p, 'default_depolconstStd', NaN, @isnumeric);

parse(p, data, transRatio, varargin{:});

polCaliFac = [];
polCaliFacStd = [];
polCaliTime = [];
polCaliAttri = struct();

if isempty(data.rawSignal)
    return;
end

time = data.mTime;

switch p.Results.wavelength

case '355nm'
    % polarization calibration at 355 nm
    flagTot355 = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
    flagCro355 = data.flagFarRangeChannel & data.flag355nmChannel & data.flagCrossChannel;

    if (~ any(flagTot355)) || (~ any(flagCro355))
        warning('Cross or total channel at 355 nm does not exist.');
        return;
    end

    sigTot355 = squeeze(data.signal(flagTot355, :, :));
    bgTot355 = squeeze(data.bg(flagTot355, :, :));
    sigCro355 = squeeze(data.signal(flagCro355, :, :));
    bgCro355 = squeeze(data.bg(flagCro355, :, :));

    [polCaliFac355, polCaliFacStd355, polCaliStartTime355, polCaliStopTime355, polCalAttri355] = depolCali(...
        sigTot355, bgTot355, sigCro355, bgCro355, time, ...
        data.depol_cal_ang_p_time_start, data.depol_cal_ang_p_time_end, ...
        data.depol_cal_ang_n_time_start, data.depol_cal_ang_n_time_end, ...
        transRatio(flagTot355), transRatio(flagCro355), ...
        [p.Results.depolCaliMinBin, p.Results.depolCaliMaxBin], ...
        p.Results.depolCaliMinSNR, p.Results.depolCaliMaxSig, ...
        p.Results.relStdDPlus, p.Results.relStdDMinus, ...
        p.Results.depolCaliSegLen, p.Results.depolCaliSmWin);
    polCalAttri355.polCaliFac = polCaliFac355;
    polCalAttri355.polCaliFacStd = polCaliFacStd355;
    polCalAttri355.polCaliStartTime = polCaliStartTime355;
    polCalAttri355.polCaliStopTime = polCaliStopTime355;

    if exist(p.Results.dbFile, 'file') == 2
        [polCaliFac, polCaliFacStd, polCaliStartTime, polCaliStopTime] = selectDepolConst(...
            polCaliFac355, polCaliFacStd355, ...
            polCaliStartTime355, polCaliStopTime355, ...
            mean(time), p.Results.dbFile, p.Results.pollyType, '355', ...
            'flagUsePrevDepolConst', p.Results.flagUsePrevDepolConst, ...
            'flagDepolCali', p.Results.flagDepolCali, ...
            'deltaTime', datenum(0, 1, 7), ...
            'default_depolconst', p.Results.default_depolconst, ...
            'default_depolconstStd', p.Results.default_depolconstStd);
        polCaliTime = [polCaliStartTime, polCaliStopTime];
        polCaliAttri = polCalAttri355;
    else
        polCaliFac = p.Results.default_depolconst;
        polCaliFacStd = p.Results.default_depolconstStd;
        polCaliTime = [polCaliStartTime355, polCaliStopTime355];
        polCaliAttri = polCalAttri355;
    end

case '532nm'
    % polarization calibration at 532 nm
    flagTot532 = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
    flagCro532 = data.flagFarRangeChannel & data.flag532nmChannel & data.flagCrossChannel;

    if (~ any(flagTot532)) || (~ any(flagCro532))
        warning('Cross or total channel at 532 nm does not exist.');
        return;
    end

    sigTot532 = squeeze(data.signal(flagTot532, :, :));
    bgTot532 = squeeze(data.bg(flagTot532, :, :));
    sigCro532 = squeeze(data.signal(flagCro532, :, :));
    bgCro532 = squeeze(data.bg(flagCro532, :, :));

    [polCaliFac532, polCaliFacStd532, polCaliStartTime532, polCaliStopTime532, polCalAttri532] = depolCali(...
        sigTot532, bgTot532, sigCro532, bgCro532, time, ...
        data.depol_cal_ang_p_time_start, data.depol_cal_ang_p_time_end, ...
        data.depol_cal_ang_n_time_start, data.depol_cal_ang_n_time_end, ...
        transRatio(flagTot532), transRatio(flagCro532), ...
        [p.Results.depolCaliMinBin, p.Results.depolCaliMaxBin], ...
        p.Results.depolCaliMinSNR, p.Results.depolCaliMaxSig, ...
        p.Results.relStdDPlus, p.Results.relStdDMinus, ...
        p.Results.depolCaliSegLen, p.Results.depolCaliSmWin);
    polCalAttri532.polCaliFac = polCaliFac532;
    polCalAttri532.polCaliFacStd = polCaliFacStd532;
    polCalAttri532.polCaliStartTime = polCaliStartTime532;
    polCalAttri532.polCaliStopTime = polCaliStopTime532;

    if exist(p.Results.dbFile, 'file') == 2
        [polCaliFac, polCaliFacStd, polCaliStartTime, polCaliStopTime] = selectDepolConst(...
            polCaliFac532, polCaliFacStd532, ...
            polCaliStartTime532, polCaliStopTime532, ...
            mean(time), p.Results.dbFile, p.Results.pollyType, '532', ...
            'flagUsePrevDepolConst', p.Results.flagUsePrevDepolConst, ...
            'flagDepolCali', p.Results.flagDepolCali, ...
            'deltaTime', datenum(0, 1, 7), ...
            'default_depolconst', p.Results.default_depolconst, ...
            'default_depolconstStd', p.Results.default_depolconstStd);
        polCaliTime = [polCaliStartTime, polCaliStopTime];
        polCaliAttri = polCalAttri532;
    else
        polCaliFac = p.Results.default_depolconst;
        polCaliFacStd = p.Results.default_depolconstStd;
        polCaliTime = [polCaliStartTime532, polCaliStopTime532];
        polCaliAttri = polCalAttri532;
    end
otherwise
    error('Unknown wavelgnth %s for polarization calibration.', p.Results.wavelength);
end

end
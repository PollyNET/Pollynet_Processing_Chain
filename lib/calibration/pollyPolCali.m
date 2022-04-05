function [polCaliEta, polCaliEtaStd, polCaliFac, polCaliFacStd, polCaliTime, polCaliAttri] = pollyPolCali(data, transRatio, varargin)
% POLLYPOLCALI calibrate the PollyXT cross channels for 355 and 532 nm with ±45° method.
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
%        '355nm' or '532nm'.
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
addParameter(p, 'default_polCaliEta', NaN, @isnumeric);
addParameter(p, 'default_polCaliEtaStd', NaN, @isnumeric);

parse(p, data, transRatio, varargin{:});

polCaliEta = [];
polCaliEtaStd = [];
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

    [polCaliEta355, polCaliEtaStd355, polCaliFac355, polCaliFacStd355, polCaliStartTime355, polCaliStopTime355, polCalAttri355] = depolCali(...
        sigTot355, bgTot355, sigCro355, bgCro355, time, ...
        data.depol_cal_ang_p_time_start, data.depol_cal_ang_p_time_end, ...
        data.depol_cal_ang_n_time_start, data.depol_cal_ang_n_time_end, ...
        transRatio(flagTot355), transRatio(flagCro355), ...
        [p.Results.depolCaliMinBin, p.Results.depolCaliMaxBin], ...
        p.Results.depolCaliMinSNR, p.Results.depolCaliMaxSig, ...
        p.Results.relStdDPlus, p.Results.relStdDMinus, ...
        p.Results.depolCaliSegLen, p.Results.depolCaliSmWin);
    polCalAttri355.polCaliEta355 = polCaliEta355;
    polCalAttri355.polCaliEtaStd355 = polCaliEtaStd355;
    polCalAttri355.polCaliEta = polCaliEta355;
    polCalAttri355.polCaliEtaStd = polCaliEtaStd355;
    polCalAttri355.polCaliFac = polCaliFac355;
    polCalAttri355.polCaliFacStd = polCaliFacStd355;
    polCalAttri355.polCaliStartTime = polCaliStartTime355;
    polCalAttri355.polCaliStopTime = polCaliStopTime355;
%%%% in future here it must be one more if, if db exist then, elsi if see
%%%% if cali was succesful, if not then default
    if exist(p.Results.dbFile, 'file') == 2
        [polCaliEta, polCaliEtaStd, polCaliStartTime, polCaliStopTime] = selectDepolConst(...
            polCaliEta355, polCaliEtaStd355, ...
            polCaliStartTime355, polCaliStopTime355, ...
            mean(time), p.Results.dbFile, p.Results.pollyType, '355', ...
            'flagUsePrevDepolConst', p.Results.flagUsePrevDepolConst, ...
            'flagDepolCali', p.Results.flagDepolCali, ...
            'deltaTime', datenum(0, 1, 7), ...
            'default_polCaliEta', p.Results.default_polCaliEta, ...
            'default_polCaliEtaStd', p.Results.default_polCaliEtaStd);
        polCaliFac = (1 + transRatio(flagTot355)) ./ (1 + transRatio(flagCro355)) * polCaliEta;
        polCaliFacStd = (1 + transRatio(flagTot355)) ./ (1 + transRatio(flagCro355)) * polCaliEtaStd;
        polCaliTime = [polCaliStartTime, polCaliStopTime];
        polCaliAttri = polCalAttri355;
    else
        polCaliEta = p.Results.default_polCaliEta;
        polCaliEtaStd = p.Results.default_polCaliEtaStd;
        polCaliFac = (1 + transRatio(flagTot355)) ./ (1 + transRatio(flagCro355)) * polCaliEta;
        polCaliFacStd = (1 + transRatio(flagTot355)) ./ (1 + transRatio(flagCro355)) * polCaliEtaStd;
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

    [polCaliEta532, polCaliEtaStd532, polCaliFac532, polCaliFacStd532, polCaliStartTime532, polCaliStopTime532, polCalAttri532] = depolCali(...
        sigTot532, bgTot532, sigCro532, bgCro532, time, ...
        data.depol_cal_ang_p_time_start, data.depol_cal_ang_p_time_end, ...
        data.depol_cal_ang_n_time_start, data.depol_cal_ang_n_time_end, ...
        transRatio(flagTot532), transRatio(flagCro532), ...
        [p.Results.depolCaliMinBin, p.Results.depolCaliMaxBin], ...
        p.Results.depolCaliMinSNR, p.Results.depolCaliMaxSig, ...
        p.Results.relStdDPlus, p.Results.relStdDMinus, ...
        p.Results.depolCaliSegLen, p.Results.depolCaliSmWin);
    polCalAttri532.polCaliEta = polCaliEta532;
    polCalAttri532.polCaliEtaStd = polCaliEtaStd532;
    polCalAttri532.polCaliFac = polCaliFac532;
    polCalAttri532.polCaliFacStd = polCaliFacStd532;
    polCalAttri532.polCaliStartTime = polCaliStartTime532;
    polCalAttri532.polCaliStopTime = polCaliStopTime532;

    if exist(p.Results.dbFile, 'file') == 2
        [polCaliEta, polCaliEtaStd, polCaliStartTime, polCaliStopTime] = selectDepolConst(...
            polCaliEta532, polCaliEtaStd532, ...
            polCaliStartTime532, polCaliStopTime532, ...
            mean(time), p.Results.dbFile, p.Results.pollyType, '532', ...
            'flagUsePrevDepolConst', p.Results.flagUsePrevDepolConst, ...
            'flagDepolCali', p.Results.flagDepolCali, ...
            'deltaTime', datenum(0, 1, 7), ...
            'default_polCaliEta', p.Results.default_polCaliEta, ...
            'default_polCaliEtaStd', p.Results.default_polCaliEtaStd);
        polCaliFac = (1 + transRatio(flagTot532)) ./ (1 + transRatio(flagCro532)) * polCaliEta;
        polCaliFacStd = (1 + transRatio(flagTot532)) ./ (1 + transRatio(flagCro532)) * polCaliEtaStd;
        polCaliTime = [polCaliStartTime, polCaliStopTime];
        polCaliAttri = polCalAttri532;
    else
        polCaliEta = p.Results.default_polCaliEta;
        polCaliEtaStd = p.Results.default_polCaliEtaStd;
        polCaliFac = (1 + transRatio(flagTot532)) ./ (1 + transRatio(flagCro532)) * polCaliEta;
        polCaliFacStd = (1 + transRatio(flagTot532)) ./ (1 + transRatio(flagCro532)) * polCaliEtaStd;
        polCaliTime = [polCaliStartTime532, polCaliStopTime532];
        polCaliAttri = polCalAttri532;
    end

case '1064nm'
    % polarization calibration at 1064 nm
    flagTot1064 = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagTotalChannel;
    flagCro1064 = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagCrossChannel;

    if (~ any(flagTot1064)) || (~ any(flagCro1064))
        warning('Cross or total channel at 1064 nm does not exist.');
        return;
    end

    sigTot1064 = squeeze(data.signal(flagTot1064, :, :));
    bgTot1064 = squeeze(data.bg(flagTot1064, :, :));
    sigCro1064 = squeeze(data.signal(flagCro1064, :, :));
    bgCro1064 = squeeze(data.bg(flagCro1064, :, :));

    [polCaliEta1064, polCaliEtaStd1064, polCaliFac1064, polCaliFacStd1064, polCaliStartTime1064, polCaliStopTime1064, polCalAttri1064] = depolCali(...
        sigTot1064, bgTot1064, sigCro1064, bgCro1064, time, ...
        data.depol_cal_ang_p_time_start, data.depol_cal_ang_p_time_end, ...
        data.depol_cal_ang_n_time_start, data.depol_cal_ang_n_time_end, ...
        transRatio(flagTot1064), transRatio(flagCro1064), ...
        [p.Results.depolCaliMinBin, p.Results.depolCaliMaxBin], ...
        p.Results.depolCaliMinSNR, p.Results.depolCaliMaxSig, ...
        p.Results.relStdDPlus, p.Results.relStdDMinus, ...
        p.Results.depolCaliSegLen, p.Results.depolCaliSmWin);
    polCalAttri1064.polCaliEta = polCaliEta1064;
    polCalAttri1064.polCaliEtaStd = polCaliEtaStd1064;
    polCalAttri1064.polCaliFac = polCaliFac1064;
    polCalAttri1064.polCaliFacStd = polCaliFacStd1064;
    polCalAttri1064.polCaliStartTime = polCaliStartTime1064;
    polCalAttri1064.polCaliStopTime = polCaliStopTime1064;

    if exist(p.Results.dbFile, 'file') == 2
        [polCaliEta, polCaliEtaStd, polCaliStartTime, polCaliStopTime] = selectDepolConst(...
            polCaliEta1064, polCaliEtaStd1064, ...
            polCaliStartTime1064, polCaliStopTime1064, ...
            mean(time), p.Results.dbFile, p.Results.pollyType, '1064', ...
            'flagUsePrevDepolConst', p.Results.flagUsePrevDepolConst, ...
            'flagDepolCali', p.Results.flagDepolCali, ...
            'deltaTime', datenum(0, 1, 7), ...
            'default_polCaliEta', p.Results.default_polCaliEta, ...
            'default_polCaliEtaStd', p.Results.default_polCaliEtaStd);
        polCaliFac = (1 + transRatio(flagTot1064)) ./ (1 + transRatio(flagCro1064)) * polCaliEta;
        polCaliFacStd = (1 + transRatio(flagTot1064)) ./ (1 + transRatio(flagCro1064)) * polCaliEtaStd;
        polCaliTime = [polCaliStartTime, polCaliStopTime];
        polCaliAttri = polCalAttri1064;
    else
        polCaliEta = p.Results.default_polCaliEta;
        polCaliEtaStd = p.Results.default_polCaliEtaStd;
        polCaliFac = (1 + transRatio(flagTot1064)) ./ (1 + transRatio(flagCro1064)) * polCaliEta;
        polCaliFacStd = (1 + transRatio(flagTot1064)) ./ (1 + transRatio(flagCro1064)) * polCaliEtaStd;
        polCaliTime = [polCaliStartTime1064, polCaliStopTime1064];
        polCaliAttri = polCalAttri1064;
    end

otherwise
    error('Unknown wavelength %s for polarization calibration.', p.Results.wavelength);
end

end
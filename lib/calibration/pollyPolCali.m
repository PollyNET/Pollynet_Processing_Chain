function [polCaliFac, polCaliFacStd, polCaliTime, polCaliAttri] = pollyPolCali(data, varargin)
% POLLYPOLCALI calibrate the PollyXT cross channels for 355 and 532 nm
% with ±45° method.
% USAGE:
%    [polCaliFac355, polCaliFacStd355, polCaliFac532, polCaliFacStd532, polCaliAttri] = pollyPolCali(data)
% INPUTS:
%    data: struct
%        More detailed information can be found in doc/pollynet_processing_program.md
% KEYWORDS:
% OUTPUTS:
%     output
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
addRequired(p, 'TransRatio', @isnumeric);
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
addParameter(p, 'pollyVersion', 'polly', @ischar);
addParameter(p, 'flagUsePrevDepolConst', false, @islogical);
addParameter(p, 'flagDepolCali', true', @islogical);
addParameter(p, 'default_depolconst', NaN, @isnumeric);
addParameter(p, 'default_depolconstStd', NaN, @isnumeric);

parse(p, data, varargin{:});

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

    if (~ flag(flagTot355)) || (~ flag(flagCro355))
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
        TransRatio(flagTot355), TransRatio(flagCro355), ...
        [p.Results.depolCaliMinBin, p.Results.depolCaliMaxBin], ...
        p.Results.depolCaliMinSNR, p.Results.depolCaliMaxSig, ...
        p.Results.relStdDPlus, p.Results.relStdDMinus, ...
        p.Results.depolCaliSegLen, p.Results.depolCaliSmWin);
    polCalAttri355.polCaliFac355 = polCaliFac355;
    polCalAttri355.polCaliFacStd355 = polCaliFacStd355;
    polCalAttri355.polCaliStartTime355 = polCaliStartTime355;
    polCalAttri355.polCaliStopTime355 = polCaliStopTime355;

    if exist(p.Results.dbFile, 'file') == 2
        [polCaliFac, polCaliFacStd, polCaliStartTime, polCaliStopTime] = select_depolconst(...
            polCaliFac355, polCaliFacStd355, ...
            polCaliStartTime355, polCaliStopTime355, ...
            mean(time), p.Results.dbFile, p.Results.pollyVersion, '355', ...
            'flagUsePrevDepolConst', p.Results.flagUsePreviousDepolCali, ...
            'flagDepolCali', p.Results.flagDepolCali, ...
            'deltaTime', datenum(0, 1, 7), ...
            'default_depolconst', p.Results.depolCaliConst355, ...
            'default_depolconstStd', p.Results.depolCaliConstStd355);
        polCaliTime = [polCaliStartTime, polCaliStopTime];
        polCaliAttri = polCalAttri355;
    else
        polCaliFac = polCaliFac355;
        polCaliFacStd = polCaliFacStd355;
        polCaliTime = [polCaliStartTime355, polCaliStopTime355];
        polCaliAttri = polCalAttri355;
    end

case '532nm'
    % polarization calibration at 532 nm
    flagTot532 = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
    flagCro532 = data.flagFarRangeChannel & data.flag532nmChannel & data.flagCrossChannel;

    if (~ flag(flagTot532)) || (~ flag(flagCro532))
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
        TransRatio(flagTot532), TransRatio(flagCro532), ...
        [p.Results.depolCaliMinBin, p.Results.depolCaliMaxBin], ...
        p.Results.depolCaliMinSNR, p.Results.depolCaliMaxSig, ...
        p.Results.relStdDPlus, p.Results.relStdDMinus, ...
        p.Results.depolCaliSegLen, p.Results.depolCaliSmWin);
    polCalAttri532.polCaliFac532 = polCaliFac532;
    polCalAttri532.polCaliFacStd532 = polCaliFacStd532;
    polCalAttri532.polCaliStartTime532 = polCaliStartTime532;
    polCalAttri532.polCaliStopTime532 = polCaliStopTime532;

    if exist(p.Results.dbFile, 'file') == 2
        [polCaliFac, polCaliFacStd, polCaliStartTime, polCaliStopTime] = select_depolconst(...
            polCaliFac532, polCaliFacStd532, ...
            polCaliStartTime532, polCaliStopTime532, ...
            mean(time), p.Results.dbFile, p.Results.pollyVersion, '532', ...
            'flagUsePrevDepolConst', p.Results.flagUsePreviousDepolCali, ...
            'flagDepolCali', p.Results.flagDepolCali, ...
            'deltaTime', datenum(0, 1, 7), ...
            'default_depolconst', p.Results.depolCaliConst532, ...
            'default_depolconstStd', p.Results.depolCaliConstStd532);
        polCaliTime = [polCaliStartTime, polCaliStopTime];
        polCaliAttri = polCalAttri532;
    else
        polCaliFac = polCaliFac532;
        polCaliFacStd = polCaliFacStd532;
        polCaliTime = [polCaliStartTime532, polCaliStopTime532];
        polCaliAttri = polCalAttri532;
    end
otherwise
    error('Unknown wavelgnth %s for polarization calibration.', p.Results.wavelength);
end

end
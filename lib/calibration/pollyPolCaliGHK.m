function [polCaliEta, polCaliEtaStd, polCaliTime, polCaliAttri] = pollyPolCaliGHK(data, K ,flagTot,flagCro,wavelength, varargin)
% POLLYPOLCALI calibrate the PollyXT cross channels for 355, 532 and 1064 nm with Delta90° method.
%
% USAGE:
%    [polCaliEta, polCaliEtaStd,  polCaliTime, polCaliAttri] = pollyPolCaliGHK(data, K, flagTot, flagCro )
%
% INPUTS:
%    data: struct
%       data
%    K: array
%        K from the GHK parameters for each channel.
%   flagTot: 
%       marks the total channel of the respective wavelength
%   flagCro: 
%       marks the cross channel of the respective wavelength
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
%    polCaliTime: 2-element array
%        time of depolarization calibration.
%    polCaliAttri: struct
%        polly polarization calibration attributes.
%
% HISTORY:
%    - 2018-12-17: First edition by Zhenping
%    - 2019-08-28: Add flag to control whether to do polarization calibration.
%    - 2020-04-18: Generalise the interface.
%    - 2024-08-28: Transfrom to GHK parameters using only eta and not V* (polCaliFac) any more 
%
% .. Authors: - zhenping@tropos.de, haarig@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'data', @isstruct);
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
    warning('Cross or total channel at ',string(wavelength),' does not exist.');
    return;
end
sigTot = squeeze(data.signal(flagTot, :, :));
bgTot = squeeze(data.bg(flagTot, :, :));
sigCro = squeeze(data.signal(flagCro, :, :));
bgCro = squeeze(data.bg(flagCro, :, :));

switch p.Results.wavelength

case '355nm'
    % polarization calibration at 355 nm
    [polCaliEta355, polCaliEtaStd355, polCaliStartTime355, polCaliStopTime355, cali_status, polCalAttri355] = depolCaliGHK(...
        sigTot, bgTot, sigCro, bgCro, time, ...
        data.depol_cal_ang_p_time_start, data.depol_cal_ang_p_time_end, ...
        data.depol_cal_ang_n_time_start, data.depol_cal_ang_n_time_end, ...
        K, ...
        [p.Results.depolCaliMinBin, p.Results.depolCaliMaxBin], ...
        p.Results.depolCaliMinSNR, p.Results.depolCaliMaxSig, ...
        p.Results.relStdDPlus, p.Results.relStdDMinus, ...
        p.Results.depolCaliSegLen, p.Results.depolCaliSmWin);
    polCalAttri355.polCaliEta = polCaliEta355;
    polCalAttri355.polCaliEtaStd = polCaliEtaStd355;
    polCalAttri355.polCaliStartTime = polCaliStartTime355;
    polCalAttri355.polCaliStopTime = polCaliStopTime355;
    polCaliAttri = polCalAttri355;
    %If calibration was not successfull, look first in data base and if it does not exist, take the default value
    if cali_status == 0 
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
            polCalAttri355.polCaliEta = polCaliEta;
            polCalAttri355.polCaliEtaStd = polCaliEtaStd;
            polCaliAttri = polCalAttri355;
            print_msg('Defaut eta at 355 nm is used.\n', 'flagTimestamp', true);
        end
    end

    
case '532nm'
    % polarization calibration at 532 nm
    [polCaliEta, polCaliEtaStd, polCaliStartTime, polCaliStopTime, cali_status, polCalAttri532] = depolCaliGHK(...
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
    polCalAttri532.polCaliStartTime = polCaliStartTime;
    polCalAttri532.polCaliStopTime = polCaliStopTime;
    polCaliAttri = polCalAttri532;
    if cali_status == 0
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
            polCalAttri532.polCaliEta = polCaliEta;
            polCalAttri532.polCaliEtaStd = polCaliEtaStd;
            polCaliAttri = polCalAttri532;
            print_msg('Defaut eta at 532 nm is used.\n', 'flagTimestamp', true);
        end
    end

case '1064nm'
     % polarization calibration at 1064 nm
    [polCaliEta, polCaliEtaStd, polCaliStartTime, polCaliStopTime,cali_status, polCalAttri1064] = depolCaliGHK(...
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
    polCaliAttri = polCalAttri1064;
    if cali_status == 0
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
            polCalAttri1064.polCaliEta = polCaliEta;
            polCalAttri1064.polCaliEtaStd = polCaliEtaStd;
            polCaliAttri = polCalAttri1064;
            print_msg('Defaut eta at 1064 nm is used.\n', 'flagTimestamp', true);
        end
    end
otherwise
    error('Unknown wavelength %s for polarization calibration.', p.Results.wavelength);
end


end
function [wvconst, wvconstStd, globalAttri] = pollyWVCali(height, sig387, bg387, sig407, E_tot_1064_IWV, E_tot_1064_cali, E_tot_1064_cali_std, wvCaliStarttime, wvCaliStoptime, IWV, flagWVCali, flag407On, trans387, trans407, rhoAir, varargin)
% POLLYWVCALI water vapor calibration.
% USAGE:
%    [wvconst, wvconstStd, globalAttri] = pollyWVCali(height, sig387, bg387, ...
%       sig407, E_tot_1064_IWV, E_tot_1064_cali, E_tot_1064_cali_std, ...
%       wvCaliStarttime, wvCaliStoptime, IWV, flagWVCali, flag407On, ...
%       trans387, trans407, rhoAir)
% INPUTS:
%    height: numeric
%        height. (m)
%    sig387: numeric
%        signal at 387 nm.
%    bg387: numeric
%        background at 387 nm
%    sig407: numeric
%        signal at 407 nm
%    E_tot_1064_IWV: numeric
%        integral 1064 nm signal when external IWV measurements were done.
%    E_tot_1064_cali: numeric
%        integral 1064 nm signal.
%    E_tot_1064_cali_std: numeric
%    wvCaliStarttime: numeric
%    wvCaliStoptime: numeric
%    IWV: numeric
%    flagWVCali: logical
%    flag407On: logical
%    trans387: numeric
%    trans407: numeric
%    rhoAir: numeric
% KEYWORDS
%    hWVCaliBase: numeric
%    hFullOL387: numeric
%    minSNRWVCali: numeric
% OUTPUTS:
%    wvconst: array
%        water vapor calibration constant. [g/kg] 
%    wvconstStd: array
%        uncertainty of water vapor calibration constant. [g/kg]
%    globalAttri: struct
%        cali_start_time: array
%            water vapor calibration start time. [datenum]
%        cali_stop_time: array
%            water vapor calibration stop time. [datenum]
%        WVCaliInfo: cell
%            calibration information for each calibration period.
%        IntRange: matrix
%            index of integration range for calculate the raw IWV from lidar.
% REFERENCES:
%    Dai, G., Althausen, D., Hofer, J., Engelmann, R., Seifert, P., Bühl, J., Mamouri, R.-E., Wu, S., and Ansmann, A.: Calibration of Raman lidar water vapor profiles by means of AERONET photometer observations and GDAS meteorological data, Atmospheric Measurement Techniques, 11, 2735-2748, 2018.
% EXAMPLE:
% HISTORY:
%   2018-12-26: First Edition by Zhenping
%   2019-08-08: Add the sunrise and sunset to exclude the low SNR 
%               calibration periods.
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'height', @isnumeric);
addRequired(p, 'sig387', @isnumeric);
addRequired(p, 'bg387', @isnumeric);
addRequired(p, 'sig407', @isnumeric);
addRequired(p, 'E_tot_1064_IWV', @isnumeric);
addRequired(p, 'E_tot_1064_cali', @isnumeric);
addRequired(p, 'E_tot_1064_cali_std', @isnumeric);
addRequired(p, 'wvCaliStarttime', @isnumeric);
addRequired(p, 'wvCaliStoptime', @isnumeric);
addRequired(p, 'IWV', @islogical);
addRequired(p, 'flagWVCali', @islogical);
addRequired(p, 'flag407On', @islogical);
addRequired(p, 'trans387', @isnumeric);
addRequired(p, 'trans407', @isnumeric);
addRequired(p, 'rhoAir', @isnumeric);

addParameter(p, 'hWVCaliBase', 0, @isnumeric);
addParameter(p, 'hWVCaliTop', 4000, @isnumeric);
addParameter(p, 'hFullOL387', 600, @isnumeric);
addParameter(p, 'minSNRWVCali', 5, @isnumeric);

parse(p, height, sig387, bg387, sig407, E_tot_1064_IWV, E_tot_1064_cali, E_tot_1064_cali_std, wvCaliStarttime, wvCaliStoptime, IWV, flagWVCali, flag407On, trans387, trans407, rhoAir, varargin{:});

wvconst = NaN;
wvconstStd = NaN;
globalAttri = struct();
globalAttri.cali_start_time = wvCaliStarttime;
globalAttri.cali_stop_time = wvCaliStoptime;
globalAttri.WVCaliInfo = '407 off';
globalAttri.IntRange = [NaN, NaN];

flagNotEnough407Prf = false;
flagLowSNR = false;
flagNoIWVMeas = false;
flagNotMeteorStable = false;

%% determine whether 407 nm channel was turn on during the calibration period
if sum(flag407On & flagWVCali) < 10
    fprintf('No enough water vapor measurement during %s to %s.\n', ...
        datestr(wvCaliStarttime, 'yyyymmdd HH:MM'), ...
        datestr(wvCaliStoptime, 'HH:MM'));
    flagNotEnough407Prf = true;
    thisWVCaliInfo = 'No enough water vapor measurements.';
end

%% determine whehter there was collocated IWV measurement
if isnan(IWV)
    fprintf('No close IWV measurement during %s to %s.\n', ...
        datestr(wvCaliStarttime, 'yyyymmdd HH:MM'), ...
        datestr(wvCaliStoptime, 'HH:MM'));
    flagNoIWVMeas = true;
    thisWVCaliInfo = 'No close IWV measurement';
end

% smooth the signal
smoothWidth = 10;
sig387 = transpose(smooth(sig387, smoothWidth));
bg387 = transpose(smooth(bg387, smoothWidth));
sig407 = transpose(smooth(sig407, smoothWidth));

snr387 = pollySNR(sig387, bg387) * sqrt(smoothWidth);

hIntBaseInd = find(height >= p.Results.hWVCaliBase, 1);
hIntTopInd = find(height >= p.Results.hWVCaliTop, 1);
if isempty(hIntBaseInd)
    hIntBaseInd = 3;
end
if isempty(hIntTopInd)
    hIntTopInd = 1000;
end

% index with complete overlap
hFullOLInd = find(height >= p.Results.hFullOL387, 1);
if isempty(hFullOLInd) 
    hFullOLInd = 70;
end

% search the index with low SNR
hIndxLowSNR387 = find(snr387(hFullOLInd:end) <= p.Results.minSNRWVCali, 1);
if isempty(hIndxLowSNR387)
    fprintf('Signal is too noisy for water calibration during %s to %s.\n', ...
        datestr(wvCaliStarttime, 'yyyymmdd HH:MM'), ...
        datestr(wvCaliStoptime, 'HH:MM'));
    flagLowSNR = true;
    thisWVCaliInfo = 'Signal at 387nm is too noisy.';
elseif (height(hIndxLowSNR387 + hFullOLInd - 1) <= p.Results.hWVCaliBase)
    fprintf('Signal is too noisy for water calibration during %s to %s.\n', ...
        datestr(wvCaliStarttime, 'yyyymmdd HH:MM'), ...
        datestr(wvCaliStoptime, 'HH:MM'));
    flagLowSNR = true;
    thisWVCaliInfo = 'Signal at 387nm channel is too noisy.';
else
    hIndxLowSNR387 = hIndxLowSNR387 + hFullOLInd - 1;
    if height(hIndxLowSNR387) <= p.Results.hWVCaliTop
        fprintf(['Integration top is less than %dm for water ', ...
            'calibration during %s to %s.\n'], p.Results.hWVCaliTop, ...
            datestr(wvCaliStarttime, 'yyyymmdd HH:MM'), ...
            datestr(wvCaliStoptime, 'HH:MM'));
        flagLowSNR = true;
        thisWVCaliInfo = 'Signal at 387 nm channel is too noisy.';
    end
    thisIntRange = [hIntBaseInd, hIntTopInd];
end

%% determine whether the water vapor measurements were performed at daytime
flagDaytimeMeas = false;
meanT_WVmeas = mean([wvCaliStarttime, wvCaliStoptime]);
if (meanT_WVmeas < sunsetTime) && (meanT_WVmeas > sunriseTime)
    flagDaytimeMeas = true;
    fprintf(['Water vapor measurements were performed during ', ...
        'daytime from %s to %s.\n'], ...
        datestr(wvCaliStarttime, 'yyyymmdd HH:MM'), ...
        datestr(wvCaliStoptime, 'HH:MM'));
    flagLowSNR = true;
    thisWVCaliInfo = 'Measurements at daytime.';
end

%% determine meteorological stability
if ~ flagNoIWVMeas
    if (abs(E_tot_1064_IWV - E_tot_1064_cali) / E_tot_1064_IWV > 0.2) || ...
        ((E_tot_1064_cali_std / E_tot_1064_cali) > 0.2)
        fprintf(['Meteorological condition is not stable enough for ', ...
            'the calibration']);
        flagNotMeteorStable = true;
        thisWVCaliInfo = 'Meteorological condition is not stable.';
    end
end

%% wv calibration
if (~ flagLowSNR) && (~ flagNoIWVMeas) && (~ flagNotEnough407Prf) && ...
    (~ flagDaytimeMeas) && (~ flagNotMeteorStable)
    IWV_Cali = IWV;   % kg*m{-2}

    wvmrRaw = sig407 ./ sig387 .* trans387 ./ trans407;
    IWVRaw = nansum(wvmrRaw(hIntBaseInd:hIntTopInd) .* rhoAir(hIntBaseInd:hIntTopInd) .* ...
                    [height(hIntBaseInd), diff(height(hIntBaseInd:hIntTopInd))]) / 1e6;   % 1000 kg*m^{-2}

    wvconst = IWV_Cali ./ IWVRaw;   % g*kg^{-1}
    wvconstStd = 0;   % TODO: this can be done by taking into account of
                            % the uncertainty of IWV by AERONET and the signal
                            % uncertainty by lidar.
end

globalAttri.WVCaliInfo{end + 1} = thisWVCaliInfo;
globalAttri.IntRange = thisIntRange;

end
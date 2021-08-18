function [depCal_P_Ang_time_start, depCal_P_Ang_time_end, depCal_N_Ang_time_start, depCal_N_Ang_time_end, maskDepCal] = pollyPolCaliTime(depCalAng, mTime, init_depAng, maskDepCalAng)
% POLLYPOLCALITIME Retrieve the time for the polly depolarization calibration 
% period. depolarization calibration: 5 min (+45°) + 5 min (-45°) + 0.5 min 
% (which I don't know why)
% USAGE:
%    [depCal_P_Ang_time_start, depCal_N_Ang_time_start, maskDepCal] = 
%          pollyPolCaliTime(depCalAng, mTime, init_depAng, maskDepCalAng)
% INPUTS:
%    depCalAng: array
%        depolarization calibration angle. [degree]
%    mTime: array
%        time for each profile. [datenum] 
%    init_depAng: float
%        initial depolarization calibration angle. [degree] 
%    maskDepCalAng: cell
%        mask for positive and negative calibration profile.
%        e.g., {'none', 'none', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 
%                'p', 'none', 'none', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 
%                'n', 'none'};   % 'p' for positive angle, 
%             %'n' for negative angle and 'none' for invalid profile.
% OUTPUTS:
%    depCal_P_Ang_time_start: scalar
%        time for the first profile with valid positive angle depolarization 
%        calibration. [datenum]
%    depCal_P_Ang_time_end: scalar
%        time for the last profile with valid positive angle depolarization 
%        calibration. [datenum]
%    depCal_N_Ang_time_start: scalar
%        time for the first profile with valid negative angle depolarization 
%        calibration. [datenum]
%    depCal_N_Ang_time_end: scalar
%        time for the last profile with valid negative angle depolarization 
%        calibration. [datenum]
%    maskDepCal: logical array
%        profile mask for depolarization calibration.
% EXAMPLE:
% HISTORY:
%    2021-04-21: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

depCal_N_Ang_time_start = [];
depCal_N_Ang_time_end = [];
depCal_P_Ang_time_start = [];
depCal_P_Ang_time_end = [];
maskDepCal = false(size(mTime));

if isempty(depCalAng)
    % depCalAng is empty, which means the polly does not support auto depol
    % calibration
    maskDepCal = transpose(maskDepCal);
    return;
end

if ~ exist('maskDepCalAng', 'var')
    maskDepCalAng = {'none', 'none', 'p', 'p', 'p', 'p', 'p', 'p', 'p', ...
                     'p', 'none', 'none', 'n', 'n', 'n', 'n', 'n', 'n', ...
                     'n', 'n', 'none'};   % the mask for postive and negative 
                                          % calibration angle. 'none' means 
                                          % invalid profiles with different 
                                          % depol_cal_angle
end

% mask the profile
flagPDepCal = false(1, length(maskDepCalAng));
flagNDepCal = false(1, length(maskDepCalAng));
for iProf = 1:length(maskDepCalAng)
    if strcmpi(maskDepCalAng{iProf}, 'p')
        flagPDepCal(iProf) = true;
    elseif strcmpi(maskDepCalAng{iProf}, 'n')
        flagNDepCal(iProf) = true;
    end
end

flagDepCal = ~ (abs(depCalAng - init_depAng) <= 0.5);   % the profile will be 
                                                        % treated as depol cali 
                                                        % profile if it has 
                                                        % different 
                                                        % depol_cal_ang than 
                                                        % the init_depAng
maskDepCal = flagDepCal;

%% search the calibration periods
valuesFlagDepCal = zeros(size(flagDepCal));
valuesFlagDepCal(flagDepCal) = 1.0;
valuesFlagDepCal(~ flagDepCal) = NaN;
[depCalPeriods, nDepCalPeriods] = label(valuesFlagDepCal);

for iDepCalPeriod = 1:nDepCalPeriods

    flagIDepCal = (depCalPeriods == iDepCalPeriod);   % flag for the ith 
                                                      % calibration period.
    tIDepCal = mTime(flagIDepCal);

    if sum(flagIDepCal) ~= length(maskDepCalAng)
        warning(['The depol cal profiles between %s and %s ' ...
                 'are not compatible with your settings. Please check the ' ...
                 '''maskDepCalAng'' in the polly config file.'], ...
                 datestr(tIDepCal(1), 'HH:MM'), ...
                 datestr(tIDepCal(end), 'HH:MM'));
        return;
    end

    % time for all positive & negative depolarization calibration profiles
    t_all_p_depCal = tIDepCal(flagPDepCal);
    t_all_n_depCal = tIDepCal(flagNDepCal);

    if isempty(t_all_n_depCal) || isempty(t_all_p_depCal)
        warning(['There are no profiles for p/n depolarization ' ...
                 'calibration. Please check the data.']);
        return;
    end

    depCal_P_Ang_time_start = [depCal_P_Ang_time_start, t_all_p_depCal(1)];
    depCal_P_Ang_time_end = [depCal_P_Ang_time_end, t_all_p_depCal(end)];
    depCal_N_Ang_time_start = [depCal_N_Ang_time_start, t_all_n_depCal(1)];
    depCal_N_Ang_time_end = [depCal_N_Ang_time_end, t_all_n_depCal(end)];
end

end
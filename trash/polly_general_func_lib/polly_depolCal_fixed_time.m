function [depCal_P_Ang_time_start, depCal_P_Ang_time_end, depCal_N_Ang_time_start, depCal_N_Ang_time_end, maskDepCal] = polly_depolCal_fixed_time(mTime, depCal_p_start, depCal_p_end, depCal_m_start, depCal_m_end)
%POLLY_DEPOLCAL_FIXED_TIME Retrieve the time for the polly depolarization calibration 
%period, according to configurations.
%Example:
%   [p_start, p_end, m_start, m_end, maskDepCal] = 
%   polly_depolCal_fixed_time(depCalAng, depCal_p_start, depCal_p_end, depCal_m_start, depCal_m_end)
%Inputs:
%   mTime: array
%       time for each profile. [datenum] 
%   depCal_p_start: cell
%       start time for positive depolarization calibration angle. (i.e., {"05:00:00"})
%   depCal_p_end: cell
%       stop time for positive depolarization calibration angle. (i.e., {"05:05:30"})
%   depCal_m_start: cell
%       start time for negative depolarization calibration angle. (i.e., {"05:10:00"})
%   depCal_m_end: cell
%       stop time for negative depolarization calibration angle. (i.e., {"05:15:30"})
%Outputs:
%   depCal_P_Ang_time_start: scalar
%       time for the first profile with valid positive angle depolarization 
%       calibration. [datenum]
%   depCal_P_Ang_time_end: scalar
%       time for the last profile with valid positive angle depolarization 
%       calibration. [datenum]
%   depCal_N_Ang_time_start: scalar
%       time for the first profile with valid negative angle depolarization 
%       calibration. [datenum]
%   depCal_N_Ang_time_end: scalar
%       time for the last profile with valid negative angle depolarization 
%       calibration. [datenum]
%   maskDepCal: logical array
%       profile mask for depolarization calibration.
%History:
%   202--09-11. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

depCal_N_Ang_time_start = [];
depCal_N_Ang_time_end = [];
depCal_P_Ang_time_start = [];
depCal_P_Ang_time_end = [];
maskDepCal = false(size(transpose(mTime)));

if isempty(depCal_p_start) || isempty(depCal_p_end) || ...
   isempty(depCal_m_start) || isempty(depCal_m_end)
    return;
end

if (length(depCal_p_start) ~= length(depCal_p_end)) || ...
   (length(depCal_p_end) ~= length(depCal_m_start)) || ...
   (length(depCal_m_start) ~= length(depCal_m_end))
   warning('Incompatible settings for depolarization calibration time.');
   return;
end

timestamp_wo_date = mod(mTime, 1);   % timestamp without date information.
p_depcal_mask = false(size(mTime));
m_depcal_mask = false(size(mTime));
for iDepCal = 1:length(depCal_p_start)

    % determine the timestamp and mask for each available depolarization calibration period
    if length(depCal_p_start{iDepCal}) == 8
        % regular time for each day
        p_start_dn = mod(datenum(depCal_p_start{iDepCal}, 'HH:MM:SS'), 1);
        p_end_dn = mod(datenum(depCal_p_end{iDepCal}, 'HH:MM:SS'), 1);
        m_start_dn = mod(datenum(depCal_m_start{iDepCal}, 'HH:MM:SS'), 1);
        m_end_dn = mod(datenum(depCal_m_end{iDepCal}, 'HH:MM:SS'), 1);

        p_depcal_mask = p_depcal_mask | ((timestamp_wo_date >= p_start_dn) & (timestamp_wo_date < p_end_dn));
        m_depcal_mask = m_depcal_mask | ((timestamp_wo_date >= m_start_dn) & (timestamp_wo_date < m_end_dn));

    elseif length(depCal_p_start{iDepCal}) == 17
        % specific time for the given date and time
        p_start_dn = datenum(depCal_p_start{iDepCal}, 'yyyymmdd HH:MM:SS');
        p_end_dn = datenum(depCal_p_end{iDepCal}, 'yyyymmdd HH:MM:SS');
        m_start_dn = datenum(depCal_m_start{iDepCal}, 'yyyymmdd HH:MM:SS');
        m_end_dn = datenum(depCal_m_end{iDepCal}, 'yyyymmdd HH:MM:SS');

        p_depcal_mask = p_depcal_mask | ((mTime >= p_start_dn) & (mTime < p_end_dn));
        m_depcal_mask = m_depcal_mask | ((mTime >= m_start_dn) & (mTime < m_end_dn));
    else
    end

end

% mask connected depolarization calibration time
p_depcal_mask_num = double(p_depcal_mask);
m_depcal_mask_num = double(m_depcal_mask);
p_depcal_mask_num(p_depcal_mask_num == 0) = NaN;
m_depcal_mask_num(m_depcal_mask_num == 0) = NaN;
[L_p, num_p] = label(p_depcal_mask_num);
[L_m, num_m] = label(m_depcal_mask_num);

if num_p ~= num_m
    warning('Incompatible depolarization calibration periods at postive and negative calibration angles');
    return;
end

maskDepCal = transpose(p_depcal_mask | m_depcal_mask);
for iCal = 1:num_m
    i_p_depcal_time = mTime(L_p == iCal);   % timestamp for the ith depolarization calibration at positive angle.
    depCal_P_Ang_time_start = cat(2, depCal_P_Ang_time_start, i_p_depcal_time(1));
    depCal_P_Ang_time_end = cat(2, depCal_P_Ang_time_end, i_p_depcal_time(end));

    i_m_depcal_time = mTime(L_m == iCal);   % timestamp for the ith depolarization calibration at negative angle.
    depCal_N_Ang_time_start = cat(2, depCal_N_Ang_time_start, i_m_depcal_time(1));
    depCal_N_Ang_time_end = cat(2, depCal_N_Ang_time_end, i_m_depcal_time(end));
end

end
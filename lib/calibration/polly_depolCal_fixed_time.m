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

if isempty(depCal_p_start) || isempty(depCal_p_end) || isempty(depCal_m_start) || isempty(depCal_m_end)
   return;
end
% convert timestamp to matlab datenum
 % p_start_dn = datenum([depCal_p_start{:}], 'HH:MM:SS')- datenum('00:00:00', 'HH:MM:SS');   % ATTENTION: no date information
% p_end_dn = datenum([depCal_p_end{:}], 'HH:MM:SS')- datenum('00:00:00', 'HH:MM:SS');
% m_start_dn = datenum([depCal_m_start{:}], 'HH:MM:SS')- datenum('00:00:00', 'HH:MM:SS');
% m_end_dn = datenum([depCal_m_end{:}], 'HH:MM:SS')- datenum('00:00:00', 'HH:MM:SS');

p_start_dn = mod(datenum([depCal_p_start{:}], 'HH:MM:SS'), 1);   % ATTENTION: no date information
p_end_dn = mod(datenum([depCal_p_end{:}], 'HH:MM:SS'), 1);
m_start_dn = mod(datenum([depCal_m_start{:}], 'HH:MM:SS'), 1);
m_end_dn = mod(datenum([depCal_m_end{:}], 'HH:MM:SS'), 1);
timestamp_wo_date = mod(mTime, 1);
 
% determine the timestamp and mask for each available depolarization calibration period
p_depcal_mask = false(size(mTime));
 
for iDepCal = 1:length(p_start_dn)
    p_depcal_mask = p_depcal_mask | ((timestamp_wo_date >= p_start_dn(iDepCal)) & (timestamp_wo_date < p_end_dn(iDepCal)));
end
 
m_depcal_mask = false(size(mTime));
 
for iDepCal = 1:length(m_start_dn)
   m_depcal_mask = m_depcal_mask | ((timestamp_wo_date >= m_start_dn(iDepCal)) & (timestamp_wo_date < m_end_dn(iDepCal)));
end

% mask connected depolarization calibration time
[L_p, num_p] = label(p_depcal_mask);
[L_m, num_m] = label(m_depcal_mask);

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
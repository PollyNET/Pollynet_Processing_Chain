function [] = pollynet_process_history_data(pollyType, startTime, endTime, saveFolder, todoFolder)
%pollynet_process_history_data process hitorical pollyType data by Pollynet Processing program
%   Example:
%       [] = pollynet_process_history_data(pollyType, startTime, endTime)
%   Inputs:
%       pollyType: char  
%           set the instrument type"
%           - pollyxt_lacros"
%           - pollyxt_tropos"
%           - pollyxt_noa"
%           - pollyxt_fmi"
%           - pollyxt_uw"
%           - pollyxt_dwd"
%           - pollyxt_tjk"
%           - arielle"
%           - polly_1v2"
%       startTime: char
%           start date with format of 'yyyymmdd' 
%       endTime: char
%           end date with format of 'yyyymmdd' 
%       saveFolder: char
%           polly data folder. 
%           e.g., /oceanethome/pollyxt
%       todoFolder: char
%           the todolist folder.
%           e.g., /home/picasso/Pollynet_Processing_Chain/todo_filelist
%   Outputs:
%       
%   History:
%       2019-01-24. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

projectDir = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectDir, 'lib'));
addpath(projectDir);

% convert the string date to matlab datenum
startTime = datenum(startTime, 'yyyymmdd');
endTime = datenum(endTime, 'yyyymmdd');

if endTime < startTime
    error('end time must be larger than start time.')
end

for thisDate = startTime:endTime

    [thisYear, thisMonth, thisDay] = datevec(thisDate);

    % some comments
    fprintf('Start to process the %s data at %s.\n', pollyType, datestr(thisDate, 'yyyy-mm-dd'));
    fprintf('Still left: %d days\n', int32(endTime - thisDate));

    % extract data and write to file_infonew.txt
    write_daily_to_filelist(pollyType, saveFolder, todoFolder, thisYear, thisMonth, thisDay, writeMode)

    % activate the processing program
    pollynet_processing_chain_main;
    
end

end
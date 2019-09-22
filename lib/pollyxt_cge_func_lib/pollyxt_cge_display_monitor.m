function [] = pollyxt_cge_display_monitor(data, taskInfo, config)
%pollyxt_cge_display_monitor display the values of sensors.
%   Example:
%       [] = pollyxt_cge_display_monitor(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2019-01-05. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global campaignInfo defaults processInfo

if isempty(data.rawSignal)
    return;
end

% go to different visualization mode
if strcmpi(processInfo.visualizationMode, 'matlab')
    % TODO

elseif strcmpi(processInfo.visualizationMode, 'python')
    
    fprintf('Display the results with Python.\n');
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    %% display monitor status
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    monitorStatus = data.monitorStatus;
    figDPI = processInfo.figDPI;
    mTime = data.mTime;
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'monitorStatus', 'processInfo', 'campaignInfo', 'taskInfo', 'xtick', 'xtickstr', 'mTime', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_cge_display_monitor.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyxt_cge_display_monitor.py');
    end
    delete(tmpFile);
    
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end
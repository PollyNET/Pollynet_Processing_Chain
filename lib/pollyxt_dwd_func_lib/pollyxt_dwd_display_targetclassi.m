function [] = pollyxt_dwd_display_targetclassi(data, taskInfo, config)
%pollyxt_dwd_display_targetclassi display the target classification reuslts
%   Example:
%       [] = pollyxt_dwd_display_targetclassi(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2018-12-30. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

if strcmpi(processInfo.visualizationMode, 'matlab')
    %% initialization 
    fileTC = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_TC.png', rmext(taskInfo.dataFilename)));

    %% visualization
    load('TC_colormap.mat')

    % 355 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.6, 0.6]);   % mainframe

    TC_mask = double(data.tc_mask);
    p1 = pcolor(data.mTime, data.height, TC_mask); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([0, 11]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 12000]);
    xlabel('UTC');
    ylabel('Height (m)');
    title(sprintf('Target Classification for %s at %s', campaignInfo.name, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2000:12000, 'yminortick', 'on');
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

    % colorbar
    TC_TickLabels = {'No signal', ...
                    'Clean atmosphere', ...
                    'Non-typed particles/low conc.', ...
                    'Aerosol: small', ...
                    'Aerosol: large, spherical', ...
                    'Aerosol: mixture, partly non-spherical', ...
                    'Aerosol: large, non-spherical', ...
                    'Cloud: non-typed', ...
                    'Cloud: water droplets', ...
                    'Cloud: likely water droplets', ...
                    'Cloud: ice crystals', ...
                    'Cloud: likely ice crystals'};
    c = colorbar('position', [0.71, 0.15, 0.01, 0.6]); 
    colormap(TC_colormap);
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '');
    set(c, 'TickDir', 'out', 'Box', 'on');
    set(c, 'ytick', (0.5:1:11.5)/12*11, 'yticklabel', TC_TickLabels);

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

    export_fig(gcf, fileTC, '-transparent', '-r300', '-painters');
    close();

elseif strcmpi(processInfo.visualizationMode, 'python')
    
    fprintf('Display the results with Python.\n');
    pyFolder = fileparts(mfilename('fullpath'));
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    TC_mask = data.tc_mask;
    height = data.height;
    time = data.mTime;
    figDPI = processInfo.figDPI;
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    %% display rcs 
    save(fullfile(tmpFolder, 'tmp.mat'), 'figDPI', 'TC_mask', 'height', 'time', 'processInfo', 'campaignInfo', 'taskInfo', 'xtick', 'xtickstr');
    tmpFile = fullfile(tmpFolder, 'tmp.mat');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_dwd_display_targetclassi.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyxt_dwd_display_targetclassi.py');
    end
    delete(fullfile(tmpFolder, 'tmp.mat'));
    
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end
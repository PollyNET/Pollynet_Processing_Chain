function polly_1v2_display_depolcali(data, config, taskInfo, attri)
%POLLY_1V2_DISPLAY_DEPOLCALI display the depolarization calibration results
%Example:
%   polly_1v2_display_depolcali(data, config, taskInfo, attri)
%Inputs:
%   data, config, taskInfo, attri
%History:
%   2018-12-29. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

global processInfo campaignInfo

imgFormat = config.imgFormat;

if strcmpi(processInfo.visualizationMode, 'matlab')

    %% 532 nm
    % interate over the cali periods
    for iCali = 1:length(attri.depCalAttri532.caliTime)  
        wavelength = 532; 
        time = data.mTime;
        alt = data.height;
        sig_t_p = attri.depCalAttri532.sig_t_p{iCali};
        sig_t_m = attri.depCalAttri532.sig_t_m{iCali};
        sig_x_p = attri.depCalAttri532.sig_x_p{iCali};
        sig_x_m = attri.depCalAttri532.sig_x_m{iCali};
        caliHIndxRange = attri.depCalAttri532.caliHIndxRange{iCali};
        indx_45m = attri.depCalAttri532.indx_45m{iCali};
        indx_45p = attri.depCalAttri532.indx_45p{iCali};
        dplus = attri.depCalAttri532.dplus{iCali};
        dminus = attri.depCalAttri532.dminus{iCali};
        segmentLen = attri.depCalAttri532.segmentLen{iCali};
        indx = attri.depCalAttri532.indx{iCali};
        mean_dplus_tmp = attri.depCalAttri532.mean_dplus_tmp{iCali};
        std_dplus_tmp = attri.depCalAttri532.std_dplus_tmp{iCali};
        mean_dminus_tmp = attri.depCalAttri532.mean_dminus_tmp{iCali};
        std_dminus_tmp = attri.depCalAttri532.std_dminus_tmp{iCali};
        TR_t = attri.depCalAttri532.TR_t{iCali};
        TR_x = attri.depCalAttri532.TR_x{iCali};
        segIndx = attri.depCalAttri532.segIndx{iCali};
        caliTime = attri.depCalAttri532.caliTime{iCali};

        fileDepolCali532 = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%d_DepolCali_532.%s', datestr(caliTime, 'yyyymmdd-HHMM'), wavelength, imgFormat));

        % visualize calibration process
        figure('position', [0, 0, 600, 600], 'Units', 'Pixels', 'visible', 'off');

        subplot(121);
        p1 = semilogx(sig_t_p, alt, '-b', 'LineWidth', 1, 'DisplayName', 'Sig_{el, +45\circ}'); hold on;
        p2 = semilogx(sig_t_m, alt, '--b', 'LineWidth', 1, 'DisplayName', 'Sig_{el, -45\circ}');
        p3 = semilogx(sig_x_p, alt, '-r', 'LineWidth', 1, 'DisplayName', 'Sig_{x, +45\circ}'); 
        p4 = semilogx(sig_x_m, alt, '--r', 'LineWidth', 1, 'DisplayName', 'Sig_{x, -45\circ}');
        ylim(alt(caliHIndxRange));
        ylabel('Height (m)');
        xlabel('Signal (.a.u)');
        text(1.2, 1.03, sprintf('Depolarization Calibration for %dnm at %s - %s', wavelength, datestr(data.mTime(indx_45p(1) - 1), 'yyyymmdd HH:MM'), datestr(time(indx_45m(end) + 1), 'HH:MM')), 'fontweight', 'bold', 'Units', 'Normal', 'HorizontalAlignment', 'center');
        grid();
        set(gca, 'xminortick', 'on', 'YMinorTick', 'on');
        l = legend([p1, p2, p3, p4], 'Location', 'NorthEast');

        subplot(122);
        p1 = plot(dplus, alt(caliHIndxRange(1):caliHIndxRange(2)), '-b', 'LineWidth', 1, 'DisplayName', 'Ratio_{+45\circ}'); hold on;
        p2 = plot(dminus, alt(caliHIndxRange(1):caliHIndxRange(2)), '-r', 'LineWidth', 1, 'DisplayName', 'Ratio_{-45\circ}'); hold on;
        plot([0, 1e10], alt([indx + caliHIndxRange(1) - 1, indx + caliHIndxRange(1) - 1]), '--k');
        plot([0, 1e10], alt([indx + segmentLen + caliHIndxRange(1) - 1, indx + segmentLen + caliHIndxRange(1) - 1]), '--k');
        ylim(alt(caliHIndxRange));
        xlim([0.1*min([dplus; dminus]), 3*max([dplus; dminus])]);
        xlabel('Ratio');
        set(gca, 'xminortick', 'on', 'YMinorTick', 'on');
        text(0.2, 0.8, sprintf('mean_{dplus}=%6.2f, std_{dplus}=%5.2f\nmean_{dminus}=%6.2f, std_{dminus}=%5.2f\nK=%6.4f, delta_K=%8.6f', ...
                mean_dplus_tmp(segIndx), std_dplus_tmp(segIndx), mean_dminus_tmp(segIndx), ...
                std_dminus_tmp(segIndx), (1 + TR_t) ./ (1 + TR_x) .* sqrt(mean_dplus_tmp(segIndx) .* mean_dminus_tmp(segIndx)), ...
                (1 + TR_t) ./ (1 + TR_x) ./ sqrt(mean_dplus_tmp(segIndx) .* mean_dminus_tmp(segIndx)) .* 0.5 .* (mean_dplus_tmp(segIndx) .* std_dminus_tmp(segIndx) + mean_dminus_tmp(segIndx) .* std_dplus_tmp(segIndx))), ...
                'Units', 'Normalized', 'fontsize', 8);
        grid();
        legend([p1, p2], 'Location', 'NorthEast');

        text(0.67, -0.08, sprintf(['%s' char(10) '%s' char(10) 'Version %s'], campaignInfo.location, campaignInfo.name, processInfo.programVersion), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

        export_fig(gcf, fileDepolCali532, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close();

    end
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

    %% interate over the cali periods
    % 532 nm
    for iCali = 1:length(attri.depCalAttri532.caliTime)  
        wavelength = 532; 
        time = data.mTime;
        height = data.height;
        sig_t_p = attri.depCalAttri532.sig_t_p{iCali};
        sig_t_m = attri.depCalAttri532.sig_t_m{iCali};
        sig_x_p = attri.depCalAttri532.sig_x_p{iCali};
        sig_x_m = attri.depCalAttri532.sig_x_m{iCali};
        caliHIndxRange = attri.depCalAttri532.caliHIndxRange{iCali};
        indx_45m = attri.depCalAttri532.indx_45m{iCali};
        indx_45p = attri.depCalAttri532.indx_45p{iCali};
        dplus = attri.depCalAttri532.dplus{iCali};
        dminus = attri.depCalAttri532.dminus{iCali};
        segmentLen = attri.depCalAttri532.segmentLen{iCali};
        indx = attri.depCalAttri532.indx{iCali};
        mean_dplus_tmp = attri.depCalAttri532.mean_dplus_tmp{iCali};
        std_dplus_tmp = attri.depCalAttri532.std_dplus_tmp{iCali};
        mean_dminus_tmp = attri.depCalAttri532.mean_dminus_tmp{iCali};
        std_dminus_tmp = attri.depCalAttri532.std_dminus_tmp{iCali};
        TR_t = attri.depCalAttri532.TR_t{iCali};
        TR_x = attri.depCalAttri532.TR_x{iCali};
        segIndx = attri.depCalAttri532.segIndx{iCali};
        caliTime = attri.depCalAttri532.caliTime{iCali};
        figDPI = processInfo.figDPI;

        %% display rcs 
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'wavelength', 'time', 'height', 'sig_t_p', 'sig_t_m', 'sig_x_p', 'sig_x_m', 'caliHIndxRange', 'indx_45m', 'indx_45p', 'dplus', 'dminus', 'segmentLen', 'indx', 'mean_dplus_tmp', 'std_dplus_tmp', 'mean_dminus_tmp', 'std_dminus_tmp', 'TR_t', 'TR_x', 'segIndx', 'caliTime', 'processInfo', 'campaignInfo', 'taskInfo', 'imgFormat', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'polly_1v2_display_depolcali.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'polly_1v2_display_depolcali.py');
        end
        delete(tmpFile);
    end

else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end
function [] = arielle_display_depolcali(data, taskInfo, attri)
%arielle_display_depolcali display the depolarization calibration results
%   Example:
%       [] = arielle_display_depolcali(attri)
%   Inputs:
%       attri
%   Outputs:
%       
%   History:
%       2018-12-29. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo


%% 355 nm
% interate over the cali periods
for iCali = 1:length(attri.depCalAttri355.thisCaliTime)  
	wavelength = 355; 
	time = data.mTime;
	alt = data.height;
	sig_t_p = attri.depCalAttri355.sig_t_p{iCali};
	sig_t_m = attri.depCalAttri355.sig_t_m{iCali};
	sig_x_p = attri.depCalAttri355.sig_x_p{iCali};
	sig_x_m = attri.depCalAttri355.sig_x_m{iCali};
	caliHIndxRange = attri.depCalAttri355.caliHIndxRange{iCali};
	indx_45m = attri.depCalAttri355.indx_45m{iCali};
	indx_45p = attri.depCalAttri355.indx_45p{iCali};
	dplus = attri.depCalAttri355.dplus{iCali};
	dminus = attri.depCalAttri355.dminus{iCali};
	segmentLen = attri.depCalAttri355.segmentLen{iCali};
	indx = attri.depCalAttri355.indx{iCali};
	mean_dplus_tmp = attri.depCalAttri355.mean_dplus_tmp{iCali};
	std_dplus_tmp = attri.depCalAttri355.std_dplus_tmp{iCali};
	mean_dminus_tmp = attri.depCalAttri355.mean_dminus_tmp{iCali};
	std_dminus_tmp = attri.depCalAttri355.std_dminus_tmp{iCali};
	TR_t = attri.depCalAttri355.TR_t{iCali};
	TR_x = attri.depCalAttri355.TR_x{iCali};
	segIndx = attri.depCalAttri355.segIndx{iCali};
	thisCaliTime = attri.depCalAttri355.thisCaliTime{iCali};

	fileOverlap355 = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%d.png', datestr(thisCaliTime, 'yyyymmdd-HHMM'), wavelength));

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
	set(l, 'FontSize', 6);

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
	l = legend([p1, p2], 'Location', 'NorthEast');
	set(l, 'FontSize', 6);

	text(0.67, -0.08, sprintf(['%s' char(10) '%s' char(10) 'Version %s'], campaignInfo.location, taskInfo.pollyVersion, processInfo.programVersion), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

	set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

	export_fig(gcf, fileOverlap355, '-transparent', '-r300');
	close();

end

%% 532 nm
% interate over the cali periods
for iCali = 1:length(attri.depCalAttri532.thisCaliTime)  
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
	thisCaliTime = attri.depCalAttri532.thisCaliTime{iCali};

	fileOverlap532 = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%d.png', datestr(thisCaliTime, 'yyyymmdd-HHMM'), wavelength));

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

	text(0.67, -0.08, sprintf(['%s' char(10) '%s' char(10) 'Version %s'], campaignInfo.location, taskInfo.pollyVersion, processInfo.programVersion), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

	set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

	export_fig(gcf, fileOverlap532, '-transparent', '-r300');
	close();

end

end
function [fig] = display_labview_results(file, yLim, errorbarInterval)
%DISPLAY_LABVIEW_RESULTS display thelabview retrieving results.
%   Example:
%       [fig] = display_labview_results(file, yLim, errorbarInterval)
%   Inputs:
%       file: char
%           the absolute path of the file which contains the data from LabView program. 
%       yLim: array [2 elements] 
%           height range for the figure. [km]
%       errorbarInterval: integer
%           interval for each error bar.
%   Outputs:
%       fig: handle
%           handle of the figure.
%   History:
%       2019-02-18. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if exist(file, 'file') ~= 2
    error('file does not exist.\n%s', file);
end

if ~ exist('yLim', 'var')
    yLim = [0, 10];
end

if ~ exist('errorbarInterval', 'var')
    errorbarInterval = 40;
end

%% read results
labviewData = read_results_from_Holger(file);
infoFile = [file(1:end-4), '-info.txt'];
[startTime, endTime, smoothWin] = extract_datetime_from_labviewfile(infoFile);
smoothWinAngExt = 1;

labviewData = labviewData(int32(smoothWin/2):(end - int32(smoothWin/2)), :);

%% data visualization
figure('Position', [0, 20, 800, 400], 'Units', 'Pixels');

subPos = subfigPos([0.06, 0.15, 0.9, 0.8], 1, 5);

% backscatter
subplot('Position', subPos(1, :), 'Units', 'Normalized');
heightBscFR355 = labviewData(:, 1);
bscFR355 = labviewData(:, 2);
errBscFR355 = labviewData(:, 3);
p1 = plot(bscFR355, heightBscFR355, 'LineStyle', '-', 'Color', [10, 79, 255]/255, 'LineWidth', ...
          1.5, 'DisplayName', '355nm FR'); hold on;
errorbar(bscFR355(1:errorbarInterval:end), heightBscFR355(1:errorbarInterval:end), ...
              errBscFR355(1:errorbarInterval:end), 'horizontal', 'color', [10, 79, 255]/255, ...
              'LineStyle', 'none', 'LineWidth', 1);

% bsc 355nm NR
heightBscNR355 = labviewData(:, 60);
bscNR355 = labviewData(:, 61);
errBscNR355 = labviewData(:, 62);
p2 = plot(bscNR355, heightBscNR355, 'LineStyle', '-', 'Color', [9, 230, 255]/255, ...
          'LineWidth', 1, 'DisplayName', '355nm NR'); hold on;
errorbar(bscNR355(1:errorbarInterval:end), heightBscNR355(1:errorbarInterval:end), ...
              errBscNR355(1:errorbarInterval:end), 'horizontal', 'color', [9, 230, 255]/255, ...
              'LineStyle', 'none', 'LineWidth', 1);

% bsc 532nm FR
heightBscFR532 = labviewData(:, 1);
bscFR532 = labviewData(:, 4);
errBscFR532 = labviewData(:, 5);
p3 = plot(bscFR532, heightBscFR532, 'LineStyle', '-', 'Color', [72, 163, 52]/255, ...
          'LineWidth', 1.5, 'DisplayName', '532nm FR'); hold on;
errorbar(bscFR532(1:errorbarInterval:end), heightBscFR532(1:errorbarInterval:end), ...
              errBscFR532(1:errorbarInterval:end), 'horizontal', 'color', [72, 163, 52]/255, ...
              'LineStyle', 'none', 'LineWidth', 1);

% bsc 532nm NR
heightBscNR532 = labviewData(:, 39);
bscNR532 = labviewData(:, 40);
errBscNR532 = labviewData(:, 41);
p4 = plot(bscNR532, heightBscNR532, 'LineStyle', '-', 'Color', [132, 252, 106]/255, ...
          'LineWidth', 1, 'DisplayName', '532nm NR'); hold on;
errorbar(bscNR532(1:errorbarInterval:end), heightBscNR532(1:errorbarInterval:end), ...
              errBscNR532(1:errorbarInterval:end), 'horizontal', 'color', [132, 252, 106]/255, ...
              'LineStyle', 'none', 'LineWidth', 1);

% bsc 1064nm FR
heightBscFR1064 = labviewData(:, 1);
bscFR1064 = labviewData(:, 6);
errBscFR1064 = labviewData(:, 7);
p5 = plot(bscFR1064, heightBscFR1064, 'LineStyle', '-', 'Color', [255, 8, 78]/255, ...
          'LineWidth', 1.5, 'DisplayName', '1064nm FR'); hold on;
errorbar(bscFR1064(1:errorbarInterval:end), heightBscFR1064(1:errorbarInterval:end), ...
              errBscFR1064(1:errorbarInterval:end), 'horizontal', 'color', [255, 8, 78]/255, ...
              'LineStyle', 'none', 'LineWidth', 1);
xlim([0, 1.5]);
ylim(yLim);
ax = gca;
ax.FontSize = 10;
xlabel('Bsc. coef. (Mm^{-1}Sr^{-1})');
ylabel('Height (km)')
set(gca, 'XTick', 0:0.5:1, 'XMinorTick', 'on', 'YMinorTick', 'on');
l = legend([p1, p2, p3, p4, p5], 'Location', 'NorthEast');
l.Box = 'on';

% extinction
subplot('Position', subPos(2, :), 'Units', 'Normalized');
% Ext 355nm FR
heightExtFR355 = labviewData(:, 1);
ExtFR355 = labviewData(:, 8);
errExtFR355 = labviewData(:, 9);
p1 = plot(ExtFR355, heightExtFR355, 'LineStyle', '-', 'Color', [10, 79, 255]/255, ...
          'LineWidth', 1.5, 'DisplayName', '355nm FR'); hold on;
errorbar(ExtFR355(1:errorbarInterval:end), heightExtFR355(1:errorbarInterval:end), ...
              errExtFR355(1:errorbarInterval:end), 'horizontal', 'color', [10, 79, 255]/255, ...
              'LineStyle', 'none', 'LineWidth', 1);

% Ext 355nm NR
heightExtNR355 = labviewData(:, 60);
ExtNR355 = labviewData(:, 63);
errExtNR355 = labviewData(:, 64);
p2 = plot(ExtNR355, heightExtNR355, 'LineStyle', '-', 'Color', [9, 230, 255]/255, ...
          'LineWidth', 1, 'DisplayName', '355nm NR'); hold on;
errorbar(ExtNR355(1:errorbarInterval:end), heightExtNR355(1:errorbarInterval:end), ...
              errExtNR355(1:errorbarInterval:end), 'horizontal', 'color', [9, 230, 255]/255, ...
              'LineStyle', 'none', 'LineWidth', 1);

% Ext 532nm FR
heightExtFR532 = labviewData(:, 1);
ExtFR532 = labviewData(:, 10);
errExtFR532 = labviewData(:, 11);
p3 = plot(ExtFR532, heightExtFR532, 'LineStyle', '-', 'Color', [72, 163, 52]/255, ...
          'LineWidth', 1.5, 'DisplayName', '532nm FR'); hold on;
errorbar(ExtFR532(1:errorbarInterval:end), heightExtFR532(1:errorbarInterval:end), ...
              errExtFR532(1:errorbarInterval:end), 'horizontal', 'color', [72, 163, 52]/255, ...
              'LineStyle', 'none', 'LineWidth', 1);

% Ext 532nm NR
heightExtNR532 = labviewData(:, 39);
ExtNR532 = labviewData(:, 42);
errExtNR532 = labviewData(:, 43);
p4 = plot(ExtNR532, heightExtNR532, 'LineStyle', '-', 'Color', [132, 252, 106]/255, ...
          'LineWidth', 1, 'DisplayName', '532nm NR'); hold on;
errorbar(ExtNR532(1:errorbarInterval:end), heightExtNR532(1:errorbarInterval:end), ...
              errExtNR532(1:errorbarInterval:end), 'horizontal', 'color', [132, 252, 106]/255, ...
              'LineStyle', 'none', 'LineWidth', 1);

xlim([0, 300]);
ylim(yLim);
ax = gca;
ax.FontSize = 10;
xlabel('Ext. coef. (Mm^{-1})');
set(gca, 'XTick', 50:100:250, 'XMinorTick', 'on', 'YMinorTick', 'on', 'YTickLabel', '');
l = legend([p1, p2, p3, p4], 'Location', 'NorthEast');
l.Box = 'on';

% lidar ratio
subplot('Position', subPos(3, :), 'Units', 'Normalized');
% LR 355nm FR
heightLRFR355 = labviewData(:, 1);
LRFR355 = labviewData(:, 12);
errLRFR355 = labviewData(:, 13);
p1 = plot(LRFR355, heightLRFR355, 'LineStyle', '-', 'Color', [10, 79, 255]/255, ...
          'LineWidth', 1.5, 'DisplayName', '355nm FR'); hold on;
errorbar(LRFR355(1:errorbarInterval:end), heightLRFR355(1:errorbarInterval:end), ...
              errLRFR355(1:errorbarInterval:end), 'horizontal', 'color', [10, 79, 255]/255, ...
              'LineStyle', 'none', 'LineWidth', 1);

% LR 355nm NR
heightLRNR355 = labviewData(:, 60);
LRNR355 = labviewData(:, 65);
errLRNR355 = labviewData(:, 66);
p2 = plot(LRNR355, heightLRNR355, 'LineStyle', '-', 'Color', [9, 230, 255]/255, ...
          'LineWidth', 1, 'DisplayName', '355nm NR'); hold on;
errorbar(LRNR355(1:errorbarInterval:end), heightLRNR355(1:errorbarInterval:end), ...
              errLRNR355(1:errorbarInterval:end), 'horizontal', 'color', [9, 230, 255]/255, ...
              'LineStyle', 'none', 'LineWidth', 1);

% LR 532nm FR
heightLRFR532 = labviewData(:, 1);
LRFR532 = labviewData(:, 14);
errLRFR532 = labviewData(:, 15);
p3 = plot(LRFR532, heightLRFR532, 'LineStyle', '-', 'Color', [72, 163, 52]/255, ...
          'LineWidth', 1.5, 'DisplayName', '532nm FR'); hold on;
errorbar(LRFR532(1:errorbarInterval:end), heightLRFR532(1:errorbarInterval:end), ...
              errLRFR532(1:errorbarInterval:end), 'horizontal', 'color', [72, 163, 52]/255, ...
              'LineStyle', 'none', 'LineWidth', 1);

% LR 532nm NR
heightLRNR532 = labviewData(:, 39);
LRNR532 = labviewData(:, 44);
errLRNR532 = labviewData(:, 45);
p4 = plot(LRNR532, heightLRNR532, 'LineStyle', '-', 'Color', [132, 252, 106]/255, ...
          'LineWidth', 1, 'DisplayName', '532nm NR'); hold on;
errorbar(LRNR532(1:errorbarInterval:end), heightLRNR532(1:errorbarInterval:end), ...
         errLRNR532(1:errorbarInterval:end), 'horizontal', 'color', [132, 252, 106]/255, ...
         'LineStyle', 'none', 'LineWidth', 1);

xlim([0, 100]);
ylim(yLim);
ax = gca;
ax.FontSize = 10;
xlabel('Lidar ratio (Sr)');
set(gca, 'XTick', 20:20:80, 'XMinorTick', 'on', 'YMinorTick', 'on', 'YTickLabel', '');
l = legend([p1, p2, p3, p4], 'Location', 'NorthEast');
l.Box = 'on';

% angstroem exponent
subplot('Position', subPos(4, :), 'Units', 'Normalized');
% ang ext 355 532
height = labviewData(:, 1);
ratio = smooth(labviewData(:, 8), smoothWinAngExt) ./ smooth(labviewData(:, 10), smoothWinAngExt);
ratio(ratio <= 0) = NaN;
ang_ext_355_532 = log(ratio) ./ log(532/355);
err_ang_ext_355_532 = labviewData(:, 17);
p1 = plot(ang_ext_355_532, height, 'LineStyle', '-', 'Color', 'k', ...
          'LineWidth', 1.5, 'DisplayName', '$\mathrm\AA_{ext-355/532}$'); hold on;
errorbar(ang_ext_355_532(1:errorbarInterval:end), height(1:errorbarInterval:end), ...
              err_ang_ext_355_532(1:errorbarInterval:end), 'horizontal', 'color', 'k', ...
              'LineStyle', 'none', 'LineWidth', 1);

% ang bsc 355 532
height = labviewData(:, 1);
ang_bsc_355_532 = labviewData(:, 18);
err_ang_bsc_355_532 = labviewData(:, 19);
p2 = plot(ang_bsc_355_532, height, 'LineStyle', '-', 'Color', 'b', ...
          'LineWidth', 1.5, 'DisplayName', '$\mathrm\AA_{bsc-355/532}$'); hold on;
errorbar(ang_bsc_355_532(1:errorbarInterval:end), height(1:errorbarInterval:end), ...
              err_ang_bsc_355_532(1:errorbarInterval:end), 'horizontal', 'color', 'b', ...
              'LineStyle', 'none', 'LineWidth', 1);

% ang bsc 532 1064
height = labviewData(:, 1);
ang_bsc_532_1064 = labviewData(:, 20);
err_ang_bsc_532_1064 = labviewData(:, 21);
p3 = plot(ang_bsc_532_1064, height, 'LineStyle', '-', 'Color', 'r', ...
          'LineWidth', 1.5, 'DisplayName', '$\mathrm\AA_{bsc-532/1064}$'); hold on;
errorbar(ang_bsc_532_1064(1:errorbarInterval:end), height(1:errorbarInterval:end), ...
              err_ang_bsc_532_1064(1:errorbarInterval:end), 'horizontal', 'color', 'r', ...
              'LineStyle', 'none', 'LineWidth', 1);

% ang bsc NR 355 532 
height = labviewData(:, 60);
ang_bsc_355_532_NR = labviewData(:, 70);
err_ang_bsc_355_532_NR = labviewData(:, 71);
p4 = plot(ang_bsc_355_532_NR, height, 'LineStyle', '-', 'Color', 'r', ...
          'LineWidth', 1.5, 'DisplayName', '$\mathrm\AA_{bsc-355/532} NR$'); hold on;
errorbar(ang_bsc_355_532_NR(1:errorbarInterval:end), height(1:errorbarInterval:end), ...
              err_ang_bsc_355_532_NR(1:errorbarInterval:end), 'horizontal', 'color', 'y', ...
              'LineStyle', 'none', 'LineWidth', 1);

% ang ext NR 355 532 
height = labviewData(:, 60);
ang_ext_355_532_NR = labviewData(:, 72);
err_ang_ext_355_532_NR = labviewData(:, 73);
p5 = plot(ang_ext_355_532_NR, height, 'LineStyle', '-', 'Color', 'c', ...
          'LineWidth', 1.5, 'DisplayName', '$\mathrm\AA_{ext-355/532} NR$'); hold on;
errorbar(ang_ext_355_532_NR(1:errorbarInterval:end), height(1:errorbarInterval:end), ...
              err_ang_ext_355_532_NR(1:errorbarInterval:end), 'horizontal', 'color', 'r', ...
              'LineStyle', 'none', 'LineWidth', 1);

xlim([-2, 3]);
ylim(yLim);
ax = gca;
ax.FontSize = 10;
xlabel('Ang. exponent');
set(gca, 'XTick', -1:1:2, 'XMinorTick', 'on', 'YMinorTick', 'on', 'YTickLabel', '');
l = legend([p1, p2, p3, p4, p5], 'Location', 'NorthEast');
l.Box = 'on';
l.Interpreter = 'latex';

% depol ratio
subplot('Position', subPos(5, :), 'Units', 'Normalized');
% vol 355
heightVol355 = labviewData(:, 31);
vol355 = labviewData(:, 32);
errVol355 = labviewData(:, 33);
p1 = plot(vol355, heightVol355, 'LineStyle', '-', 'Color', [10, 79, 255]/255, ...
          'LineWidth', 1.5, 'DisplayName', '\delta_{vol, 355}'); hold on;
errorbar(vol355(1:errorbarInterval:end), heightVol355(1:errorbarInterval:end), ...
              errVol355(1:errorbarInterval:end), 'horizontal', 'color', [10, 79, 255]/255, ...
              'LineStyle', 'none', 'LineWidth', 1);

% par 355
heightPar355 = labviewData(:, 34);
par355 = labviewData(:, 35);
errPar355 = labviewData(:, 36);
p2 = plot(par355, heightPar355, 'LineStyle', '-', 'Color', [9, 230, 255]/255, ...
          'LineWidth', 1, 'DisplayName', '\delta_{par, 355}'); hold on;
errorbar(par355(1:errorbarInterval:end), heightPar355(1:errorbarInterval:end), ...
              errPar355(1:errorbarInterval:end), 'horizontal', 'color', [9, 230, 255]/255, ...
              'LineStyle', 'none', 'LineWidth', 1);

% vol 532
heightVol532 = labviewData(:, 22);
vol532 = labviewData(:, 23);
errVol532 = labviewData(:, 24);
p3 = plot(vol532, heightVol532, 'LineStyle', '-', 'Color', [72, 163, 52]/255, ...
          'LineWidth', 1.5, 'DisplayName', '\delta_{vol, 532}'); hold on;
errorbar(vol532(1:errorbarInterval:end), heightVol532(1:errorbarInterval:end), ...
              errVol532(1:errorbarInterval:end), 'horizontal', 'color', [72, 163, 52]/255, ...
              'LineStyle', 'none', 'LineWidth', 1);

% par 532
heightPar532 = labviewData(:, 25);
par532 = labviewData(:, 26);
errPar532 = labviewData(:, 27);
p4 = plot(par532, heightPar532, 'LineStyle', '-', 'Color', [132, 252, 106]/255, ...
          'LineWidth', 1, 'DisplayName', '\delta_{par, 532}'); hold on;
errorbar(par532(1:errorbarInterval:end), heightPar532(1:errorbarInterval:end), ...
              errPar532(1:errorbarInterval:end), 'horizontal', 'color', [132, 252, 106]/255, ...
              'LineStyle', 'none', 'LineWidth', 1);

xlim([0, 0.4]);
ylim(yLim);
ax = gca;
ax.FontSize = 10;
xlabel('Depol. ratio');
set(gca, 'XTick', 0.1:0.1:0.3, 'XMinorTick', 'on', 'YMinorTick', 'on', 'YTickLabel', '');
l = legend([p1, p2, p3, p4], 'Location', 'NorthEast');
l.Box = 'on';

text(-2.3, 1.03, sprintf('Averaged from %s to %s (smooth %d)', ...
     datestr(startTime, 'yyyymmdd HH:MM'), datestr(endTime, 'HH:MM'), smoothWin), ...
     'Units', 'Normalized', 'FontWeight', 'Bold');

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');

end
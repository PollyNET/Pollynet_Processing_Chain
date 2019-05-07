function [time, height, res] = read_processed_data(instrument, parameter, tRange, hRange, resFolder)
%read_processed_data read the processed data from pollynet processing program in the given range.
%   Example:
%       [time, height, res] = read_processed_data(instrument, parameter, tRange, hRange, resFolder)
%   Inputs:
%       instrument: str
%           polly instrument. {'pollyxt_lacros', 'pollyxt_noa', 'pollyxt_tropos', 'pollyxt_fmi', 'arielle'} 
%       parameter: str
%           the label of the parameter which you want to extract.
%       tRange: 2-element array (datenum)
%           start time and end time of the extraction. 
%       hRange: 2-element array 
%           spatial range. [km]
%       resFolder: str
%           the folder of saving the processign results.
%   Outputs:
%       time, height, res
%   History:
%       2019-04-10. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if ~ exist('hRange', 'var')
    hRange = [0, 25];
end

if ~ exist('resFolder', 'var')
    resFolder = 'C:\Users\zhenping\Desktop\Picasso\results';
end

time = [];
height = [];
res = [];

switch parameter
case 'data'
    
    signal = [];
    bg = [];
    for iDay = fix(tRange(1)):fix(tRange(2))
        files = listfile(fullfile(resFolder, instrument, datestr(double(iDay), 'yyyymmdd')), '\w*.mat');
        for iFile = 1:length(files)
            fprintf('Reading %s.\n', files{iFile});
            load(files{iFile});
            height = data.height;
            time = [time, data.mTime];
            height = data.height;
            signal = cat(3, signal, data.signal);
            bg = cat(3, bg, data.bg);
        end
    end

    indx = (time >= tRange(1)) & (time <= tRange(2));
    res.signal = signal(:, :, indx);
    res.bg = bg(:, :, indx);
    res.mTime = time(indx);
    res.height = height;
    time = time(indx);

case 'LC_aeronet_1064nm'
    
    for iDay = fix(tRange(1)):fix(tRange(2))
        files = listfile(fullfile(resFolder, instrument, datestr(double(iDay), 'yyyymmdd')), '\w*_lc.nc');
        for iFile = 1:length(files)
            fprintf('Reading %s.\n', files{iFile});
            time = [time, ncread(files{iFile}, 'datetime')];
            res = [res, ncread(files{iFile}, 'LC_aeronet_1064nm')];
        end
    end

    indx = (time >= tRange(1)) & (time <= tRange(2));
    res = res(indx);
    time = time(indx);

case 'LC_aeronet_355nm'
    
    for iDay = fix(tRange(1)):fix(tRange(2))
        files = listfile(fullfile(resFolder, instrument, datestr(double(iDay), 'yyyymmdd')), '\w*_lc.nc');
        for iFile = 1:length(files)
            fprintf('Reading %s.\n', files{iFile});
            time = [time, ncread(files{iFile}, 'datetime')];
            res = [res, ncread(files{iFile}, 'LC_aeronet_355nm')];
        end
    end

    indx = (time >= tRange(1)) & (time <= tRange(2));
    res = res(indx);
    time = time(indx);

case 'LC_aeronet_532nm'
    
    for iDay = fix(tRange(1)):fix(tRange(2))
        files = listfile(fullfile(resFolder, instrument, datestr(double(iDay), 'yyyymmdd')), '\w*_lc.nc');
        for iFile = 1:length(files)
            fprintf('Reading %s.\n', files{iFile});
            time = [time, ncread(files{iFile}, 'datetime')];
            res = [res, ncread(files{iFile}, 'LC_aeronet_532nm')];
        end
    end

    indx = (time >= tRange(1)) & (time <= tRange(2));
    res = res(indx);
    time = time(indx);

case 'LC_klett_1064nm'
    
    for iDay = fix(tRange(1)):fix(tRange(2))
        files = listfile(fullfile(resFolder, instrument, datestr(double(iDay), 'yyyymmdd')), '\w*_lc.nc');
        for iFile = 1:length(files)
            fprintf('Reading %s.\n', files{iFile});
            time = [time, ncread(files{iFile}, 'datetime')];
            res = [res, ncread(files{iFile}, 'LC_klett_1064nm')];
        end
    end

    indx = (time >= tRange(1)) & (time <= tRange(2));
    res = res(indx);
    time = time(indx);

case 'LC_klett_355nm'
    
    for iDay = fix(tRange(1)):fix(tRange(2))
        files = listfile(fullfile(resFolder, instrument, datestr(double(iDay), 'yyyymmdd')), '\w*_lc.nc');
        for iFile = 1:length(files)
            fprintf('Reading %s.\n', files{iFile});
            time = [time, ncread(files{iFile}, 'datetime')];
            res = [res, ncread(files{iFile}, 'LC_klett_355nm')];
        end
    end

    indx = (time >= tRange(1)) & (time <= tRange(2));
    res = res(indx);
    time = time(indx);

case 'LC_klett_532nm'
    
    for iDay = fix(tRange(1)):fix(tRange(2))
        files = listfile(fullfile(resFolder, instrument, datestr(double(iDay), 'yyyymmdd')), '\w*_lc.nc');
        for iFile = 1:length(files)
            fprintf('Reading %s.\n', files{iFile});
            time = [time, ncread(files{iFile}, 'datetime')];
            res = [res, ncread(files{iFile}, 'LC_klett_532nm')];
        end
    end

    indx = (time >= tRange(1)) & (time <= tRange(2));
    res = res(indx);
    time = time(indx);

case 'LC_raman_1064nm'
    
    for iDay = fix(tRange(1)):fix(tRange(2))
        files = listfile(fullfile(resFolder, instrument, datestr(double(iDay), 'yyyymmdd')), '\w*_lc.nc');
        for iFile = 1:length(files)
            fprintf('Reading %s.\n', files{iFile});
            time = [time, ncread(files{iFile}, 'datetime')];
            res = [res, ncread(files{iFile}, 'LC_raman_1064nm')];
        end
    end

    indx = (time >= tRange(1)) & (time <= tRange(2));
    res = res(indx);
    time = time(indx);

case 'LC_raman_355nm'
    
    for iDay = fix(tRange(1)):fix(tRange(2))
        files = listfile(fullfile(resFolder, instrument, datestr(double(iDay), 'yyyymmdd')), '\w*_lc.nc');
        for iFile = 1:length(files)
            fprintf('Reading %s.\n', files{iFile});
            time = [time, ncread(files{iFile}, 'datetime')];
            res = [res, ncread(files{iFile}, 'LC_raman_355nm')];
        end
    end

    indx = (time >= tRange(1)) & (time <= tRange(2));
    res = res(indx);
    time = time(indx);

case 'LC_raman_532nm'
    
    for iDay = fix(tRange(1)):fix(tRange(2))
        files = listfile(fullfile(resFolder, instrument, datestr(double(iDay), 'yyyymmdd')), '\w*_lc.nc');
        for iFile = 1:length(files)
            fprintf('Reading %s.\n', files{iFile});
            time = [time, ncread(files{iFile}, 'datetime')];
            res = [res, ncread(files{iFile}, 'LC_raman_532nm')];
        end
    end

    indx = (time >= tRange(1)) & (time <= tRange(2));
    res = res(indx);
    time = time(indx);

case 'attenuated_backscatter_1064nm'
    
    for iDay = fix(tRange(1)):fix(tRange(2))
        files = listfile(fullfile(resFolder, instrument, datestr(double(iDay), 'yyyymmdd')), '\w*_att_bsc.nc');
        for iFile = 1:length(files)
            fprintf('Reading %s.\n', files{iFile});
            time = [time; ncread(files{iFile}, 'time')];
            height = ncread(files{iFile}, 'altitude');
            res = [res, ncread(files{iFile}, 'attenuated_backscatter_1064nm')];
        end
    end

    indx = (time >= tRange(1)) & (time <= tRange(2));
    res = res(:, indx);
    time = time(indx);

case 'attenuated_backscatter_355nm'
    
    for iDay = fix(tRange(1)):fix(tRange(2))
        files = listfile(fullfile(resFolder, instrument, datestr(double(iDay), 'yyyymmdd')), '\w*_att_bsc.nc');
        for iFile = 1:length(files)
            fprintf('Reading %s.\n', files{iFile});
            time = [time; ncread(files{iFile}, 'time')];
            height = ncread(files{iFile}, 'altitude');
            res = [res, ncread(files{iFile}, 'attenuated_backscatter_355nm')];
        end
    end

    indx = (time >= tRange(1)) & (time <= tRange(2));
    res = res(:, indx);
    time = time(indx);

case 'attenuated_backscatter_532nm'
    
    for iDay = fix(tRange(1)):fix(tRange(2))
        files = listfile(fullfile(resFolder, instrument, datestr(double(iDay), 'yyyymmdd')), '\w*_att_bsc.nc');
        for iFile = 1:length(files)
            fprintf('Reading %s.\n', files{iFile});
            time = [time; ncread(files{iFile}, 'time')];
            height = ncread(files{iFile}, 'altitude');
            res = [res, ncread(files{iFile}, 'attenuated_backscatter_532nm')];
        end
    end

    indx = (time >= tRange(1)) & (time <= tRange(2));
    res = res(:, indx);
    time = time(indx);

case 'target_classification'
    
    for iDay = fix(tRange(1)):fix(tRange(2))
        files = listfile(fullfile(resFolder, instrument, datestr(double(iDay), 'yyyymmdd')), '\w*_target_classification.nc');
        for iFile = 1:length(files)
            fprintf('Reading %s.\n', files{iFile});
            time = [time; ncread(files{iFile}, 'time')];
            height = ncread(files{iFile}, 'altitude');
            res = [res, ncread(files{iFile}, 'target_classification')];
        end
    end

    indx = (time >= tRange(1)) & (time <= tRange(2));
    res = res(:, indx);
    time = time(indx);

case 'volume_depolarization_ratio_355nm'
    
    for iDay = fix(tRange(1)):fix(tRange(2))
        files = listfile(fullfile(resFolder, instrument, datestr(double(iDay), 'yyyymmdd')), '\w*_vol_depol.nc');
        for iFile = 1:length(files)
            fprintf('Reading %s.\n', files{iFile});
            time = [time; ncread(files{iFile}, 'time')];
            height = ncread(files{iFile}, 'altitude');
            res = [res, ncread(files{iFile}, 'volume_depolarization_ratio_355nm')];
        end
    end

    indx = (time >= tRange(1)) & (time <= tRange(2));
    res = res(:, indx);
    time = time(indx);

case 'volume_depolarization_ratio_532nm'
    
    for iDay = fix(tRange(1)):fix(tRange(2))
        files = listfile(fullfile(resFolder, instrument, datestr(double(iDay), 'yyyymmdd')), '\w*_vol_depol.nc');
        for iFile = 1:length(files)
            fprintf('Reading %s.\n', files{iFile});
            time = [time; ncread(files{iFile}, 'time')];
            height = ncread(files{iFile}, 'altitude');
            res = [res, ncread(files{iFile}, 'volume_depolarization_ratio_532nm')];
        end
    end

    indx = (time >= tRange(1)) & (time <= tRange(2));
    res = res(:, indx);
    time = time(indx);
otherwise
    warning('Unkown parameter.');
end

end
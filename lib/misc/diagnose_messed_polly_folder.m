% check the raw data folder of polly to find the folders with data files from
% multiple pollys.
%
% Author: Zhenping Yin
% Date: 2020-12-15
%

clc; close all;

projectDir = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectDir, 'lib')));
addpath(genpath(fullfile(projectDir, 'include')));

% parameter initialization
pollys = {'arielle', 'polly_1v2', 'pollyxt_cyp', 'pollyxt_dwd', 'pollyxt_fmi', 'pollyxt_lacros', 'pollyxt_noa', 'pollyxt_tau',' pollyxt_tjk', 'pollyxt_tropos', 'pollyxt_uw'};
polly_identifiers = {'ari', '1v2', 'cyp', 'dwd', 'fmi', 'lacros', 'noa', 'tau', 'tjk', 'tropos', 'uwa'};
polly_rootdir = '/data/level0/polly';

% searching
wrong_files = cell(0);
wrong_folders = cell(0);
for iPolly = 1:length(pollys)
    fprintf('Finished %6.2f%%: now at %s\n', (iPolly - 1) / length(pollys) * 100, pollys{iPolly});

    % list all data files
    pollyDataFiles = listfile(fullfile(polly_rootdir, pollys{iPolly}, 'data_zip'), '.*.nc.zip', 2);

    % compare polly identifiers
    for iFile = 1:length(pollyDataFiles)
        split_res = regexp(basename(pollyDataFiles{iFile}), '_', 'split');

        if length(split_res) < 5
            continue;
        end

        if regexp(lower(split_res{5}), lower(polly_identifiers{iPolly}))
            continue;
        else
            wrong_files = cat(1, wrong_files, pollyDataFiles{iFile});
            wrong_folders = cat(1, wrong_folders, fileparts(pollyDataFiles{iFile}));
        end
    end
end

% output results
unique_wrong_folders = unique(wrong_folders);
fprintf('Number of problematic folders: %d\n', length(unique_wrong_folders));
for iFolder = 1:length(unique_wrong_folders)
    fprintf('[%d] %s\n', iFolder, unique_wrong_folders{iFolder});
end

#!/bin/bash
# This script is used to convert all the SQLite DB files of lidar calibration
# data to ASCII files in batch mode.
# Usage:
#   ./convert_caliDB_2_ASCII.sh /pollyhome/Picasso/results_new

cwd="$( cd "$(dirname "$0")"; pwd -P )"
PATH=${PATH}:$cwd

# results folder of Picasso
RESULTS_FOLDER="$1"

matlab -nodisplay -nodesktop -nosplash <<ENDMATLAB

fprintf('\n');

resultsFolder = '$RESULTS_FOLDER';
projectFolder = fileparts(fileparts('$cwd'));

addpath(genpath(fullfile(projectFolder, 'lib')));

subFolders = listdir(resultsFolder);

for iFolder = 1:length(subFolders)

    dbFiles = listfile(subFolders{iFolder}, '\w*.db');

    for iDBFile = 1:length(dbFiles)
        fprintf('Converting %s\n', dbFiles{iDBFile});
        dbBasename = basename(dbFiles{iDBFile});
        extract_cali_results(dbFiles{iDBFile}, subFolders{iFolder}, 'prefix', [dbBasename(1:(end-3)), '_']);
    end

end

exit;

ENDMATLAB

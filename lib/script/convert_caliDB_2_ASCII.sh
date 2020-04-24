#!/bin/bash
# This script is used to convert the SQLite DB of lidar calibration data to
# ASCII files.

cwd="$( cd "$(dirname "$0")"; pwd -P )"
PATH=${PATH}:$cwd

RESULTS_FOLDER="$1"

matlab -nodisplay -nodesktop -nosplash | tail -n +11 <<ENDMATLAB

resultsFolder = '$RESULTS_FOLDER';
projectFolder = fileparts(fileparts('$cwd'));

addpath(genpath(fullfile(projectFolder, 'lib')));

subFolders = listdir(resultsFolder);

for iFolder = 1:length(subFolders)

    dbFiles = listfile(subFolders{iFolder}, '\w*.db');

    for iDBFile = 1:length(dbFiles)
        dbBasename = basename(dbFiles{iDBFile});
        extract_cali_results(dbFiles{iDBFile}, subFolders{iFolder}, 'prefix', dbBasename(1:(end-3)));
    end

end

ENDMATLAB
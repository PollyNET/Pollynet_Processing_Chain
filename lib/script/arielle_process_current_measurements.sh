#!/bin/bash
# This script will help to process the current polly data with using Pollynet processing chain

cwd="$( cd "$(dirname "$0")" ; pwd -P )"
PATH=${PATH}:$cwd


# parameter initialization
POLLY_TYPE="arielle"
POLLY_FOLDER="/oceanethome/pollyxt"
POLLYNET_CONFIG_FILE="pollynet_processing_chain_config.json"

echo "\nCurrent time: "
date

echo -e "\nInitial settings:\nPOLLY_FOLDER=$POLLY_FOLDER\nPOLLY_TYPE=$POLLY_TYPE\nPOLLYNET_CONFIG_FILE=$POLLYNET_CONFIG_FILE\n\n"

matlab -nodisplay -nodesktop -nosplash << ENDMATLAB

POLLYNET_PROCESSING_DIR = fileparts(fileparts('$cwd'));
addpath(POLLYNET_PROCESSING_DIR, 'lib');
cd(POLLYNET_PROCESSING_DIR);

clc;
pollyFile = search_polly_file('$POLLY_FOLDER', now, datenum(0, 1, 0, 24, 0, 0), true);
if isempty(pollyFile)
    exit;
end

for iFile = 1:length(pollyFile)
    write_single_to_filelist('$POLLY_TYPE', pollyFile{iFile}, fullfile(POLLYNET_PROCESSING_DIR,  'config', '$POLLYNET_CONFIG_FILE'), 'w');
    pollynet_processing_chain_main(fullfile(POLLYNET_PROCESSING_DIR,  'config', '$POLLYNET_CONFIG_FILE'));
end

exit;

ENDMATLAB

echo "Finish"

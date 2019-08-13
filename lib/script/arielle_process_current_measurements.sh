#!/bin/bash
# This script will help to process the current polly data with using Pollynet processing chain

cwd=$(dirname "$0")
PATH=${PATH}:$cwd
PATH=${PATH}:/usr/programming/matlab/matlab-2014a/bin

# parameter initialization
POLLY_TYPE="arielle"
POLLY_FOLDER="/oceanethome/pollyxt"
POLLYNET_CONFIG_FILE="/home/picasso/Pollynet_Processing_Chain/config/pollynet_processing_chain_config.json"

echo "\nCurrent time: "
date

echo -e "\nInitial settings:\nPOLLY_FOLDER=$POLLY_FOLDER\nPOLLY_TYPE=$POLLY_TYPE\nPOLLYNET_CONFIG_FILE=$POLLYNET_CONFIG_FILE\n\n"

matlab -nodisplay -nodesktop -nosplash << ENDMATLAB

clc;
pollyFile = search_polly_file('$POLLY_FOLDER', now, datenum(0, 1, 0, 24, 0, 0), true);
if isempty(pollyFile)
    exit;
end

for iFile = 1:length(pollyFile)
    write_single_to_filelist('$POLLY_TYPE', pollyFile{iFile}, '$POLLYNET_CONFIG_FILE', 'w');
    pollynet_processing_chain_main('$POLLYNET_CONFIG_FILE');
end

exit;

ENDMATLAB

echo "Finish"

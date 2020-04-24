#!/bin/bash
# This script will help to process the current polly data with using Pollynet processing chain

cwd="$( cd "$(dirname "$0")" ; pwd -P )"
PATH=${PATH}:$cwd


# parameter initialization
POLLY_FOLDER="/oceanethome/pollyxt"
POLLY_TYPE="arielle"
POLLYNET_CONFIG_FILE="pollynet_processing_chain_config.json"

echo "\nCurrent time: "
date +"%Y-%m-%d"

a=$(date +"%Y-%m-%d")
year=$(echo $a | cut -b1-4)
month=$(echo $a | cut -b6-7)
day=$(echo $a | cut -b9-10)

echo -e "\nInitial settings:\nPOLLY_FOLDER=$POLLY_FOLDER\nPOLLY_TYPE=$POLLY_TYPE\nPOLLYNET_CONFIG_FILE=$POLLYNET_CONFIG_FILE\nYear=$year\nmonth=$month\nday=$day\n\n"

matlab -nodisplay -nodesktop -nosplash << ENDMATLAB

POLLYNET_PROCESSING_DIR = fileparts(fileparts('$cwd'));
addpath(POLLYNET_PROCESSING_DIR, 'lib');
cd(POLLYNET_PROCESSING_DIR);

clc;

write_daily_to_filelist('$POLLY_TYPE', '$POLLY_FOLDER', fullfile(POLLYNET_PROCESSING_DIR,  'config', '$POLLYNET_CONFIG_FILE'), '$year', '$month', '$day', 'w');
pollynet_processing_chain_main(fullfile(POLLYNET_PROCESSING_DIR,  'config', '$POLLYNET_CONFIG_FILE'));

exit;

ENDMATLAB

echo "Finish"

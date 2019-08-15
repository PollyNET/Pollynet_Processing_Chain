#!/bin/bash
# This script will help to process the current polly data with using Pollynet processing chain

cwd=$(dirname "$0")
PATH=${PATH}:$cwd
PATH=${PATH}:/usr/programming/matlab/matlab-2014a/bin

# parameter initialization
POLLY_FOLDER="/oceanethome/pollyxt"
POLLY_TYPE="arielle"
POLLYNET_CONFIG_FILE="/home/picasso/Pollynet_Processing_Chain/config/pollynet_processing_chain_config.json"

echo "\nCurrent time: "
date +"%Y-%m-%d"

a=$(date +"%Y-%m-%d")
year=$(echo $a | cut -b1-4)
month=$(echo $a | cut -b6-7)
day=$(echo $a | cut -b9-10)

echo -e "\nInitial settings:\nPOLLY_FOLDER=$POLLY_FOLDER\nPOLLY_TYPE=$POLLY_TYPE\nPOLLYNET_CONFIG_FILE=$POLLYNET_CONFIG_FILE\nYear=$year\nmonth=$month\nday=$day\n\n"

matlab -nodisplay -nodesktop -nosplash << ENDMATLAB

clc;

write_daily_to_filelist('$POLLY_TYPE', '$POLLY_FOLDER', '$POLLYNET_CONFIG_FILE', '$year', '$month', '$day', 'w');
pollynet_processing_chain_main('$POLLYNET_CONFIG_FILR');

exit;

ENDMATLAB

echo "Finish"

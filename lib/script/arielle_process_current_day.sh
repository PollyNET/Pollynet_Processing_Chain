#!/bin/bash
# This script will help to process the current polly data with using Pollynet processing chain

# parameter initialization
POLLY_FOLDER="/oceanethome/pollyxt"
POLLY_TYPE="arielle"
TODOLISTFOLDER="/home/picasso/Pollynet_Processing_Chain/todo_filelist"

echo "\nCurrent time: "
date +"%Y-%m-%d"

a=$(date +"%Y-%m-%d")
year=$(echo $a | cut -b1-4)
month=$(echo $a | cut -b6-7)
day=$(echo $a | cut -b9-10)

echo -e "\nInitial settings:\nPOLLY_FOLDER=$POLLY_FOLDER\nPOLLY_TYPE=$POLLY_TYPE\nTODOLISTFOLDER=$TODOLISTFOLDER\nYear=$year\nmonth=$month\nday=$day\n\n"

matlab -nodisplay -nodesktop -nosplash << ENDMATLAB

clc;

write_daily_to_filelist('$POLLY_TYPE', '$POLLY_FOLDER', '$TODOLISTFOLDER', '$year', '$month', '$day', 'w');
pollynet_processing_chain_main;

exit;

ENDMATLAB

echo "Finish"

#!/bin/bash
# This script will help to process the current polly data with using Pollynet processing chain

cwd=$(dirname "$0")
PATH=${PATH}:$cwd
PATH=${PATH}:/usr/programming/matlab/matlab-2014a/bin

# parameter initialization
POLLY_TYPE="arielle"
POLLY_FOLDER="/oceanethome/pollyxt"
TODOLISTFOLDER="/home/picasso/Pollynet_Processing_Chain/todo_filelist"

echo "\nCurrent time: "
date

echo -e "\nInitial settings:\nPOLLY_FOLDER=$POLLY_FOLDER\nPOLLY_TYPE=$POLLY_TYPE\nTODOLISTFOLDER=$TODOLISTFOLDER\n\n"

matlab -nodisplay -nodesktop -nosplash << ENDMATLAB

clc;
pollyFile = search_polly_file('$POLLY_FOLDER', now, datenum(0, 1, 0, 9, 0, 0), true);
if isempty(pollyFile)
    exit;
end

for iFile = 1:length(pollyFile)
    write_single_to_filelist('$POLLY_TYPE', pollyFile{iFile}, '$TODOLISTFOLDER', 'w');
    pollynet_processing_chain_main;
end

exit;

ENDMATLAB

echo "Finish"

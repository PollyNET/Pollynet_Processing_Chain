#!/bin/bash
# This script will help to process the current polly data with using Pollynet processing chain

# parameter initialization
POLLY_TYPE="arielle"
POLLY_FOLDER="/oceanethome/pollyxt"
TODOLISTFOLDER="/home/picasso/Pollynet_Processing_Chain/todo_filelist"

echo "\nCurrent time: "
date

echo -e "\nInitial settings:\nPOLLY_FOLDER=$POLLY_FOLDER\nPOLLY_TYPE=$POLLY_TYPE\nTODOLISTFOLDER=$TODOLISTFOLDER\n\n"

matlab -nodisplay -nodesktop -nosplash << ENDMATLAB

clc;
pollyFile = search_polly_file('$POLLY_FOLDER', now, datenum(0, 1, 0, 6, 0, 0));
if isempty(pollyFile)
    exit;
end

fprintf('Found the most current polly file: \n%s\n', pollyFile);
pause(1)
flagCont = input('Continue...? (yes|no) [ENTER]: ');

if strcmp(flagCont, 'yes')
    write_single_to_filelist('$POLLY_TYPE', pollyFile, '$TODOLISTFOLDER', 'w');
    pollynet_processing_chain_main;
else
    break;
end

exit;

ENDMATLAB

echo "Finish"

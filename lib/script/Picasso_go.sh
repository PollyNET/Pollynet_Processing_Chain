#!/bin/bash
# Process the current available polly data

cwd="$( cd "$(dirname "$0")" ; pwd -P )"
PATH=${PATH}:$cwd

PATH=${PATH}:/usr/programming/matlab/matlab-2014a/bin

# parameter definition
POLLYNET_CONFIG_FILE="pollynet_processing_chain_config.json"

# Unzip the polly data
/pollyhome/Picasso/script/locatenewfiles_newdb.pl

matlab -nodesktop -nosplash << ENDMATLAB

POLLYNET_PROCESSING_DIR = fileparts(fileparts('$cwd'));
pollynet_processing_chain_main(fullfile(POLLYNET_PROCESSING_DIR, 'config', '$POLLYNET_CONFIG_FILE'));

ENDMATLAB

/pollyhome/Picasso/pollyAPP/src/util/add_new_data2pollydb.pl /pollyhome/Picasso/done_filelist/done_filelist.txt

echo "Finish"

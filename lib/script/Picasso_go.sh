#!/bin/bash
# Process the current available polly data

cwd="$( cd "$(dirname "$0")" ; pwd -P )"
PATH=${PATH}:$cwd

PATH=${PATH}:/usr/programming/matlab/matlab-2014a/bin

# parameter definition
POLLYNET_CONFIG_FILE="pollynet_processing_chain_config.json"
POLLYAPP_CONFIG_FILE="/pollyhome/Picasso/pollyAPP/config/config.private";

matlab -nodesktop -nosplash << ENDMATLAB

POLLYNET_PROCESSING_DIR = fileparts(fileparts('$cwd'));

addpath(fullfile(POLLYNET_PROCESSING_DIR, 'lib'));
addlibpath;
addincludepath;

% unzip the file
locatenewfiles_newdb('$POLLYAPP_CONFIG_FILE', fullfile(POLLYNET_PROCESSING_DIR, 'config', '$POLLYNET_CONFIG_FILE'), '/pollyhome', 50000, now, datenum(0, 1, 4), true);

pollynet_processing_chain_main(fullfile(POLLYNET_PROCESSING_DIR, 'config', '$POLLYNET_CONFIG_FILE'));

ENDMATLAB

/pollyhome/Picasso/pollyAPP/src/util/add_new_data2pollydb.pl /pollyhome/Picasso/done_filelist/done_filelist.txt

echo "Finish"

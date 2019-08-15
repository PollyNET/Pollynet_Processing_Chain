#!/bin/bash
# Process the current available polly data

cwd="$( cd "$(dirname "$0")" ; pwd -P )"
PATH=${PATH}:$cwd

PATH=${PATH}:/usr/programming/matlab/matlab-2014a/bin

echo "Process the current available polly data"
YYYYMMDD=$(date --utc "+%Y%m%d" -d "today")

Year=$(echo ${YYYYMMDD} | cut -c1-4)
Month=$(echo ${YYYYMMDD} | cut -c5-6)
Day=$(echo ${YYYYMMDD} | cut -c7-8)
CWD=$(pwd)

echo "Processing $YYYYMMDD"

# parameter definition
POLLY_LIST="'arielle','pollyxt_lacros','polly_1v2','pollyxt_fmi','pollyxt_dwd','pollyxt_noa','pollyxt_tropos','pollyxt_uw','pollyxt_tjk'"
POLLY_ROOT_DIR="/pollyhome"
POLLYNET_CONFIG_FILE='pollynet_processing_chain_config.json'

matlab -nodesktop -nosplash << ENDMATLAB

POLLYNET_PROCESSING_DIR = fileparts(fileparts('$cwd'));
addpath(POLLYNET_PROCESSING_DIR, 'lib');
cd(POLLYNET_PROCESSING_DIR);

POLLY_LIST = {${POLLY_LIST}};

for iPolly = 1:length(POLLY_LIST)
    saveFolder = fullfile('$POLLY_ROOT_DIR', POLLY_LIST{iPolly});
    pollynet_process_history_data(POLLY_LIST{iPolly}, '$YYYYMMDD', '$YYYYMMDD', saveFolder, fullfile(POLLYNET_PROCESSING_DIR,  'config', '$POLLYNET_CONFIG_FILE'));
end
ENDMATLAB

echo "Finish"

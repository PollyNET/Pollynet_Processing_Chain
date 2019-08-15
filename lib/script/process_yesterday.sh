#!/bin/bash
# Process the current available polly data

cwd=$(dirname "$0")
PATH=${PATH}:$cwd

PATH=${PATH}:/usr/programming/matlab/matlab-2014a/bin

echo "Process the current available polly data"
YYYYMMDD=$(date --utc "+%Y%m%d" -d "yesterday")
pollyRoot="/pollyhome"

Year=$(echo ${YYYYMMDD} | cut -c1-4)
Month=$(echo ${YYYYMMDD} | cut -c5-6)
Day=$(echo ${YYYYMMDD} | cut -c7-8)

echo "Processing $YYYYMMDD"
echo "Year=$Year"
echo "Month=$Month"
echo "Day=$Day"

# parameter definition
POLLYLIST="'arielle','pollyxt_lacros','polly_1v2','pollyxt_fmi','pollyxt_dwd','pollyxt_noa','pollyxt_tropos','pollyxt_uw','pollyxt_tjk'"
POLLYNET_CONFIG_FILE='/pollyhome/Picasso/Pollynet_Processing_Chain/config/pollynet_processing_chain_config.json'

matlab -nodesktop -nosplash << ENDMATLAB
cd /pollyhome/Picasso/playground;
POLLYLIST = {${POLLYLIST}};

for iPolly = 1:length(POLLYLIST)
    pollynet_process_history_data(POLLYLIST{iPolly}, '$YYYYMMDD', '$YYYYMMDD', saveFolder, '%POLLYNET_CONFIG_FILE');
end
ENDMATLAB

echo "Finish"

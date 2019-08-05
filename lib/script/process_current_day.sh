#!/bin/bash
# Process the current available polly data

cwd=$(dirname "$0")
PATH=${PATH}:$cwd

PATH=${PATH}:/usr/programming/matlab/matlab-2014a/bin

echo "Process the current available polly data"
YYYYMMDD=$(date --utc "+%Y%m%d" -d "today")

Year=$(echo ${YYYYMMDD} | cut -c1-4)
Month=$(echo ${YYYYMMDD} | cut -c5-6)
Day=$(echo ${YYYYMMDD} | cut -c7-8)

echo "Processing $YYYYMMDD"

# parameter definition
pollyList="'arielle','pollyxt_lacros','polly_1v2','pollyxt_fmi','pollyxt_dwd','pollyxt_noa','pollyxt_tropos','pollyxt_uw','pollyxt_tjk'"
pollyRoot="/pollyhome"

matlab -nodesktop -nosplash << ENDMATLAB
cd /pollyhome/Picasso/playground;
addpath /pollyhome/Picasso/Pollynet_Processing_Chain/lib;
pollyList = {${pollyList}};

for iPolly = 1:length(pollyList)
	saveFolder = fullfile('$pollyRoot', pollyList{iPolly});
	todoFolder = '/pollyhome/Picasso/todo_filelist';
	pollynet_process_history_data(pollyList{iPolly}, '$YYYYMMDD', '$YYYYMMDD', saveFolder, todoFolder);
end
ENDMATLAB

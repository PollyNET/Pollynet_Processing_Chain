#!/bin/bash
# Process the current available polly data

cwd=$(dirname "$0")
PATH=${PATH}:$cwd

PATH=${PATH}:/usr/programming/matlab/matlab-2014a/bin

echo "Process the current available polly data"
YYYYMMDD=$(date --utc "+%Y%m%d" -d "today")

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
    pollyFile = search_polly_file(saveFolder, now, datenum(0, 1, 0, 9, 0, 0));

    if isempty(pollyFile)
        warning('No measurements within 12 hours.');
    else
        for iFile = 1:length(pollyFile)
            write_single_to_filelist('$POLLY_TYPE', pollyFile{iFile}, todoFolder, 'w');
            pollynet_processing_chain_main;
        end
    end
end
ENDMATLAB

echo "Finish"

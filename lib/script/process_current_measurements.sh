#!/bin/bash
# Process the current available polly data

cwd=$(dirname "$0")
PATH=${PATH}:$cwd

PATH=${PATH}:/usr/programming/matlab/matlab-2014a/bin

echo "Process the current available polly data"
YYYYMMDD=$(date --utc "+%Y%m%d" -d "today")

# parameter definition
POLLYLIST="'arielle','pollyxt_lacros','polly_1v2','pollyxt_fmi','pollyxt_dwd','pollyxt_noa','pollyxt_tropos','pollyxt_uw','pollyxt_tjk'"
POLLY_ROOT_DIR="/pollyhome"
POLLYNET_CONFIG_FILE='pollynet_processing_chain_config.json'

matlab -nodesktop -nosplash << ENDMATLAB

POLLYNET_PROCESSING_DIR = fileparts(fileparts('$CWD'));
addpath(POLLYNET_PROCESSING_DIR, 'lib');
cd(POLLYNET_PROCESSING_DIR);

POLLYLIST = {${POLLYLIST}};

for iPolly = 1:length(POLLYLIST)
    saveFolder = fullfile('$POLLY_ROOT_DIR', POLLYLIST{iPolly});
    pollyFile = search_polly_file(saveFolder, now, datenum(0, 1, 0, 9, 0, 0), true);

    if isempty(pollyFile)
        warning('No measurements within 12 hours.');
    else
        for iFile = 1:length(pollyFile)
            write_single_to_filelist(POLLYLIST{iPolly}, pollyFile{iFile}, '$POLLYNET_CONFIG_FILE', 'w');
            pollynet_processing_chain_main(fullfile(POLLYNET_PROCESSING_DIR,  'config', '$POLLYNET_CONFIG_FILE'));
        end
    end
end
ENDMATLAB

echo "Finish"

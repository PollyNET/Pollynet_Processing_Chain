#!/bin/bash
# This script will help to process the current polly data with using Pollynet processing chain

cwd=$(dirname "$0")
PATH=${PATH}:$cwd

#########################
# The command line help #
#########################
display_help() {
    echo "Usage: $0 [option...]" >&2
    echo 
    echo "Process the polly data at any give time."
    echo "   -p, --polly_type        set the instrument type"
    echo "                           - pollyxt_lacros"
    echo "                           - pollyxt_tropos"
    echo "                           - pollyxt_noa"
    echo "                           - pollyxt_fmi"
    echo "                           - pollyxt_uw"
    echo "                           - pollyxt_dwd"
    echo "                           - pollyxt_tjk"
    echo "                           - arielle"
    echo "                           - polly_1v2"
    echo "   -f, --polly_folder      specify the polly data folder"
    echo "                           e.g., '/oceanethome/pollyxt'"
    echo "   -h, --help              show help message"
    echo
    # echo some stuff here for the -a or --add-options 
    exit 1
}

# process the data
run_matlab() {

matlab -nodisplay -nodesktop -nosplash << ENDMATLAB

clc;

pollyFile = search_polly_file('$POLLY_FOLDER', now, datenum(0, 1, 0, 9, 0, 0));
if isempty(pollyFile)
    warning('No measurement data within 12 hours.\nCheck your folder setting: %s', '$POLLY_FOLDER');
    exit;
else 
    for iFile = 1:length(pollyFile)
        write_single_to_filelist('$POLLY_TYPE', pollyFile{iFile}, '$TODOLISTFOLDER', 'w');
        pollynet_processing_chain_main;
    end
end


exit;
ENDMATLAB

echo "Finish"
}

# parameter initialization
POLLY_FOLDER="/oceanethome/pollyxt"
POLLY_TYPE="arielle"
TODOLISTFOLDER="/pollyhome/Picasso/todo_filelist"

################################
# Check if parameters options  #
# are given on the commandline #
################################
while :
do
    case "$1" in

      -p | --polly_type)
          if [ $# -ne 0 ]; then
            POLLY_TYPE="$2"
          fi
          shift 2
          ;;

      -f | --polly_folder)
          if [ $# -ne 0 ]; then
            POLLY_FOLDER="$2"
          fi
          shift 2
          ;;

      -t | --todo_folder)
          if [ $# -ne 0 ]; then
              TODOLISTFOLDER="$2"
          fi
          shift 2
          ;;
  
      -h | --help)
          display_help  # Call your function
          exit 0
          ;;

      --) # End of all options
          shift
          break
          ;;
      -*)
          echo "Error: Unknown option: $1" >&2
          ## or call function display_help
          exit 1 
          ;;
      *)  # No more options
          break
          ;;
    esac
done

run_matlab

#!/bin/bash
# This script will help to process the history polly data with using Pollynet processing chain

cwd=$(dirname "$0")
PATH=${PATH}:$cwd

#########################
# The command line help #
#########################
display_help() {
  echo "Usage: $0 [option...] " >&2
  echo
  echo "Process the polly history data."
  echo "   -s, --start_date        set the start date for the polly data"
  echo "                           e.g., 20110101"
  echo "   -e, --end_date          set the end date for the polly data"
  echo "                           e.g., 20150101"
  echo "   -p, --polly_type        set the instrument type"
  echo "                           - pollyxt_lacros"
  echo "                           - pollyxt_tropos"
  echo "                           - pollyxt_noa"
  echo "                           - pollyxt_fmi"
  echo "                           - pollyxt_uw"
  echo "                           - pollyxt_dwd"
  echo "                           - pollyxt_tjk"
  echo "                           - pollyxt_tau"
  echo "                           - arielle"
  echo "                           - polly_1v2"
  echo "   -f, --polly_folder      specify the polly data folder"
  echo "                           e.g., '/pollyhome/pollyxt_lacros'"
  echo "   -c, --config_file       specify the pollynet processing file for the data processing"
  echo "                           e.g., 'pollynet_processing_chain_config.json'"
  echo "   -h, --help              show help message"
  echo
  # echo some stuff here for the -a or --add-options
  exit 1
}

# process the data
run_matlab() {
  echo -e "\nSettings:\nPOLLY_FOLDER=$POLLY_FOLDER\nPOLLY_TYPE=$POLLY_TYPE\nPOLLYNET_CONFIG_FILE=$POLLYNET_CONFIG_FILE\nSTART_DATE=$STARTDATE\nEND_DATE=$ENDDATE\n\n"

  matlab -nodisplay -nodesktop -nosplash <<ENDMATLAB

POLLYNET_PROCESSING_DIR = fileparts(fileparts('$cwd'));
cd(POLLYNET_PROCESSING_DIR);
addpath(fullfile(POLLYNET_PROCESSING_DIR, 'lib'));

clc;
pollynet_process_history_data('$POLLY_TYPE', '$STARTDATE', '$ENDDATE', '$POLLY_FOLDER', fullfile(POLLYNET_PROCESSING_DIR,  'config', '$POLLYNET_CONFIG_FILE'));
exit;
ENDMATLAB

  echo "Finish"
}

# parameter initialization
POLLY_FOLDER="/pollyhome/arielle"
POLLY_TYPE="arielle"
POLLYNET_CONFIG_FILE="pollynet_processing_chain_config.json"
STARTDATE="20190101"
ENDDATE="20190103"

################################
# Check if parameters options  #
# are given on the commandline #
################################
while :; do
  case "$1" in
  -s | --start_date)
    if [ $# -ne 0 ]; then
      STARTDATE="$2"
    fi
    shift 2
    ;;

  -e | --end_date)
    if [ $# -ne 0 ]; then
      ENDDATE="$2"
    fi
    shift 2
    ;;

  -f | --polly_folder)
    if [ $# -ne 0 ]; then
      POLLY_FOLDER="$2"
    fi
    shift 2
    ;;

  -p | --polly_type)
    if [ $# -ne 0 ]; then
      POLLY_TYPE="$2"
    fi
    shift 2
    ;;

  -c | --config_file)
    if [ $# -ne 0 ]; then
      POLLYNET_CONFIG_FILE="$2"
    fi
    shift 2
    ;;

  -h | --help)
    display_help # Call your function
    exit 0
    ;;

  --) # End of all options
    shift
    break
    ;;
  -*)
    echo "Error: Unknown option: $1" >&2
    ## or call function display_help
    exit exit 1
    ;;
  *) # No more options
    break
    ;;
  esac
done

run_matlab

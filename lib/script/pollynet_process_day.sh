#!/bin/bash
# This script will help to process the current polly data with using Pollynet processing chain

cwd=$(dirname "$0")
PATH=${PATH}:$cwd

#########################
# The command line help #
#########################
display_help() {
  echo "Usage: $0 [option...] {today|yesterday}" >&2
  echo
  echo "Process the polly data at any give time."
  echo "   -d, --yyyymmdd          set the date for the polly data"
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

get_date_today() {
  a=$(date +"%Y-%m-%d")
  year=$(echo $a | cut -b1-4)
  month=$(echo $a | cut -b6-7)
  day=$(echo $a | cut -b9-10)
}

get_date_yesterday() {
  a=$(date +"%Y-%m-%d" --date="yesterday")
  year=$(echo $a | cut -b1-4)
  month=$(echo $a | cut -b6-7)
  day=$(echo $a | cut -b9-10)
}

get_date_input() {
  a=$1
  year=$(echo $a | cut -b1-4)
  month=$(echo $a | cut -b5-6)
  day=$(echo $a | cut -b7-8)
}

# process the data
run_matlab() {
  echo -e "\nSettings:\nPOLLY_FOLDER=$POLLY_FOLDER\nPOLLY_TYPE=$POLLY_TYPE\nPOLLYNET_CONFIG_FILE=$POLLYNET_CONFIG_FILE\nYear=$year\nMonth=$month\nDay=$day\n\n"

  matlab -nodisplay -nodesktop -nosplash <<ENDMATLAB

POLLYNET_PROCESSING_DIR = fileparts(fileparts('$cwd'));
cd(POLLYNET_PROCESSING_DIR);
addpath(fullfile(POLLYNET_PROCESSING_DIR, 'lib'));

clc;

write_daily_to_filelist('$POLLY_TYPE', '$POLLY_FOLDER', '$POLLYNET_CONFIG_FILE', $year, $month, $day, 'w');

pollynet_processing_chain_main(fullfile(POLLYNET_PROCESSING_DIR,  'config', '$POLLYNET_CONFIG_FILE'));

exit;
ENDMATLAB

  echo "finish!"
}

# parameter initialization
POLLY_FOLDER="/oceanethome/pollyxt"
POLLY_TYPE="arielle"
POLLYNET_CONFIG_FILE="pollynet_processing_chain_config.json"
year="2000"
month="01"
day="01"

################################
# Check if parameters options  #
# are given on the commandline #
################################
while :; do
  case "$1" in
  -d | --yyyymmdd)
    if [ $# -ne 0 ]; then
      get_date_input "$2"
    fi
    shift 2
    ;;

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
    exit 1
    ;;
  *) # No more options
    break
    ;;
  esac
done

######################
# Check if parameter #
# is set too execute #
######################
case "$1" in
today)
  get_date_today
  ;;
yesterday)
  get_date_yesterday
  ;;
*) ;;

esac

run_matlab "$year" "$month" "$day"

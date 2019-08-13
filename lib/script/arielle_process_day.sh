#!/bin/bash
# This script will help to process the current polly data with using Pollynet processing chain

cwd=$(dirname "$0")
PATH=${PATH}:$cwd
PATH=${PATH}:/usr/programming/matlab/matlab-2014a/bin

#########################
# The command line help #
#########################
display_help() {
    echo "Usage: $0 [option...] {today|yesterday}" >&2
    echo 
    echo "Process the polly data at any give time."
    echo "   -d, --yyyymmdd          set the date for the polly data"
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
echo -e "\nInitial settings:\nPOLLY_FOLDER=$POLLY_FOLDER\nPOLLY_TYPE=$POLLY_TYPE\nPOLLYNET_CONFIG_FILE=$POLLYNET_CONFIG_FILE\n\n"

matlab -nodisplay -nodesktop -nosplash << ENDMATLAB

clc;

write_daily_to_filelist('$POLLY_TYPE', '$POLLY_FOLDER', '$POLLYNET_CONFIG_FILE', $1, $2, $3, 'w');
pollynet_processing_chain_main('POLLYNET_CONFIG_FILE');

exit;
ENDMATLAB

echo "Finish"
}

# parameter initialization
POLLY_FOLDER="/oceanethome/pollyxt"
POLLY_TYPE="arielle"
POLLYNET_CONFIG_FILE="/home/picasso/Pollynet_Processing_Chain/config/pollynet_processsing_chain_config.json"
year="2000"
month="01"
day="01"

################################
# Check if parameters options  #
# are given on the commandline #
################################
while :
do
    case "$1" in
      -d | --yyyymmdd)
          if [ $# -ne 0 ]; then
            get_date_input "$2"
            run_matlab "$year" "$month" "$day"
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

###################### 
# Check if parameter #
# is set too execute #
######################
case "$1" in
  today)
    get_date_today
    run_matlab "$year" "$month" "$day"
    ;;
  yesterday)
    get_date_yesterday
    run_matlab "$year" "$month" "$day"
    ;;
  *)
    display_help
    exit 1
    ;;
esac

exit

#!/bin/bash
# This script will help to process the history polly data with using Pollynet processing chain

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
    echo "                           - arielle"
    echo "                           - polly_1v2"
    echo "   -f, --polly_folder      specify the polly data folder"
    echo "                           e.g., '/pollyhome/pollyxt_lacros'"
    echo "   -h, --help              show help message"
    echo
    # echo some stuff here for the -a or --add-options 
    exit 1
}

# process the data
run_matlab() {
echo -e "\nSettings:\nPOLLY_FOLDER=$POLLY_FOLDER\nPOLLY_TYPE=$POLLY_TYPE\nTODOLISTFOLDER=$TODOLISTFOLDER\nSTART_DATE=$STARTDATE\nEND_DATE=ENDDATE\n\n"

matlab -nodisplay -nodesktop -nosplash << ENDMATLAB

clc;
pollynet_process_history_data('$POLLY_TYPE', '$STARTDATE', '$ENDDATE', '$POLLY_FOLDER', '$TOTOLISTFOLDER');
exit;
ENDMATLAB
}

# parameter initialization
POLLY_FOLDER="/pollyhome/arielle"
POLLY_TYPE="arielle"
TODOLISTFOLDER="/pollyhome/Picasso/Pollynet_Processing_Chain/todo_filelist"
STARTDATE="20190101"
ENDDATE="20190103"

################################
# Check if parameters options  #
# are given on the commandline #
################################
while :
do
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

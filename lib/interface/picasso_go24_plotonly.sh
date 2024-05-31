#! /usr/bin/bash

#########################
# The command line help #
#########################
display_help() {
  echo "Usage: $0 [option...] " >&2
  echo
  echo "Plotting of already processed polly level1 data."
  echo "   -s, --startdate	specify startdate YYYYMMDD"
  echo "   -e, --enddate        specify enddate YYYYMMDD"
  echo "   -d, --device         specify device, e.g. pollyxt_lacros"
  echo "   -c, --config_file    specify Picasso configuration file, e.g.: ~/Pollynet_Processing_Chain/config/pollynet_processing_chain_config_rsd2_andi.json"
  echo "   -r, --retrieval    specify retrieval to be plotted [choice:]"
  echo "   -h, --help           show help message"
  echo
  exit 1
}

## initialize parameters
PICASSO_CONFIG_FILE=""
RETRIEVAL="all"
#PICASSO_DIR_interface="$( cd "$(dirname "$0")" ; pwd -P )"
PICASSO_DIR="$(dirname "$(dirname "$PICASSO_DIR_interface")")"
#PICASSO_DIR="$(dirname "$(dirname "$( cd "$(dirname "$0")" ; pwd -P )")")"
#echo $PICASSO_DIR_interface
echo $PICASSO_DIR

################################
# Check if parameters options  #
# are given on the commandline #
################################
while :; do
  case "$1" in
  -s | --startdate)
    if [ $# -ne 0 ]; then
      STARTDATE="$2"
    fi
    shift 2
    ;;

  -e | --enddate)
    if [ $# -ne 0 ]; then
      ENDDATE="$2"
    fi
    shift 2
    ;;

  -d | --device)
    if [ $# -ne 0 ]; then
      DEVICE_LS="$2"
    fi
    shift 2
    ;;

  -c | --config_file)
    if [ $# -ne 0 ]; then
      PICASSO_CONFIG_FILE="$2"
    fi
    shift 2
    ;;

  --retrieval)
    if [ $# -ne 0 ]; then
      RETRIEVAL="$2"
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
    display_help
    exit exit 1
    ;;
  *) # No more options
    break
    ;;
  esac
done


# getting "doneListFile" from config_file
#PICASSO_DONE_FILE=`cat ${PICASSO_CONFIG_FILE} | jq -r ."doneListFile"`

# getting "pic_folder" from config_file
#PIC_FOLDER=`cat ${PICASSO_CONFIG_FILE} | jq -r ."pic_folder"`

# getting "python_folder" from config_file
PY_FOLDER=`cat ${PICASSO_CONFIG_FILE} | jq -r ."pyBinDir"`
echo $PY_FOLDER


create_date_ls() {
## create DATE_LS
    dates=()
    for (( date=STARTDATE; date <= ENDDATE; )); do
        dates+=( "$date" )
        date="$(date --date="$date +1 days" +'%Y%m%d')"
    done
    
    for i in ${dates[@]}; do
    	YYYY=${i:0:4}
    	MM=${i:4:2}
    	DD=${i:6:2}
    	YYYYMMDD=$YYYY$MM$DD
    	DATE_LS+=( "$YYYYMMDD" )
    done
}

main() {

	create_date_ls
	
	for DEVICE in ${DEVICE_LS[@]}; do
	    echo $DEVICE
	    for DATE in ${DATE_LS[@]}; do
	        echo $DATE	
            "$PY_FOLDER"python "$PICASSO_DIR"/lib/visualization/pypolly_display_all.py --date $DATE --device $DEVICE --picasso_config $PICASSO_CONFIG_FILE  --retrieval $RETRIEVAL
#            if [[ "$flagWriteIntoTodoList" == "true" ]];then
#            	check_todo_list_consistency
#	            write_job_into_todo_list $DEVICE $DATE ## writing job to todo_list
#            fi
#		    ## OPTION 1: process every single task???
#            if [[ "$flagProc" == "true" ]];then
#		        process_merged ## process actual merged file with picasso - written in todo_list
#            fi
#            if [[ "$flagDeleteMergedFiles" == "true" ]];then
#		        delete_level0_merged_file $DEVICE $DATE ## delete level0 24h-file
#                delete_laserlogbookfile $DEVICE $DATE ## delete laserlogbook-file
#		        delete_entry_from_todo_list $DEVICE $DATE ## delete entry from todo_list file
#            fi
	    done
	done

#exit 1

## execute main function
main

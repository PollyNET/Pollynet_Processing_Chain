#! /usr/bin/bash

#########################
# The command line help #
#########################
display_help() {
  echo "Usage: $0 [option...] " >&2
  echo
  echo "Process polly 24h-merged data listed in the fileinfo_new.txt file."
  echo "   -s, --startdate	specify startdate YYYYMMDD"
  echo "   -e, --enddate        specify enddate YYYYMMDD"
  echo "   -d, --device         specify device, e.g. pollyxt_lacros"
  echo "   -c, --config_file    specify Picasso configuration file, e.g.: ~/Pollynet_Processing_Chain/config/pollynet_processing_chain_config_rsd2_andi.json"
#  echo "   -o, --output         specify folder where to put merged nc-file, e.g.: ~/todo_filelist"
  echo "   --force_merging      specify whether files will be merged independently if attributes have changed or not; default: false"
  echo "   --todolist       write merged level0-file into todo-list (set to true or false); default: true"
  echo "   --matlab         specify location of matlab-executable; default is just set to: matlab"
  echo "   --proc 	        execute picasso-processing-chain (set to true or false); default: true"
  echo "   --delmerged      deleting merged files in the end (set to true or false); default: true"
#  echo "   --fproc 	        force to execute picasso-processing-chain even if job was already processed (entry in done-list exists)"
#  echo "   --plot_only 	        plot files, which were already processed and already stored in the results-folder (without processing again)"
  echo "   -h, --help           show help message"
  echo
  exit 1
}

## initialize parameters
FORCE_MERGING="false"
MATLABEXEC="matlab"
PICASSO_CONFIG_FILE=""
PICASSO_DIR_interface="$( cd "$(dirname "$0")" ; pwd -P )"
PICASSO_DIR="$(dirname "$(dirname "$PICASSO_DIR_interface")")"
#PICASSO_DIR="$(dirname "$(dirname "$( cd "$(dirname "$0")" ; pwd -P )")")"
echo $PICASSO_DIR_interface
echo $PICASSO_DIR
flagWriteIntoTodoList="true"
flagProc="true"
flagFProc="false"
flagDeleteMergedFiles="true"
flagPlotonly="false"
filename=""
filesize=""

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

  --force_merging)
    if [ $# -ne 0 ]; then
      FORCE_MERGING="$2"
    fi
    shift 2
    ;;

  --todolist)
    flagWriteIntoTodoList="$2"
    shift 2
    ;;

  --matlab)
    MATLABEXEC="$2"
    shift 2
    ;;

  --proc)
    flagProc="$2"
    shift 2
    ;;

  --fproc)
    flagFProc="true"
    shift 1
    ;;
  --delmerged)
    flagDeleteMergedFiles="$2"
    shift 2
    ;;

  --plot_only)
    flagPlotonly="true"
    shift 1
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


# getting "fileinfo_new" from config_file
PICASSO_TODO_FILE=`cat ${PICASSO_CONFIG_FILE} | jq -r ."fileinfo_new"`

# getting TODO_FOLDER from PICASSO_TODO_FILE
TODO_FOLDER=$(dirname "$PICASSO_TODO_FILE")

# getting "doneListFile" from config_file
PICASSO_DONE_FILE=`cat ${PICASSO_CONFIG_FILE} | jq -r ."doneListFile"`

# getting "flagEnableDataVisualization24h" from config_file
VIS24=`cat ${PICASSO_CONFIG_FILE} | jq -r ."flagEnableDataVisualization24h"`

# getting "pic_folder" from config_file
PIC_FOLDER=`cat ${PICASSO_CONFIG_FILE} | jq -r ."pic_folder"`

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
            merging $DEVICE $DATE ## merging of level0 files and put into todo-list
            if [[ "$flagWriteIntoTodoList" == "true" ]];then
            	check_todo_list_consistency
	            write_job_into_todo_list $DEVICE $DATE ## writing job to todo_list
            fi
            copy_level0_merged_file_to_level0b $DEVICE $DATE ## copy merged level0-24h-file to level0b
		    ## OPTION 1: process every single task???
            if [[ "$flagProc" == "true" ]];then
		        process_merged ## process actual merged file with picasso - written in todo_list
            fi
            if [[ "$flagDeleteMergedFiles" == "true" ]];then
		        delete_level0_merged_file $DEVICE $DATE ## delete level0 24h-file
                delete_laserlogbookfile $DEVICE $DATE ## delete laserlogbook-file
		        delete_entry_from_todo_list $DEVICE $DATE ## delete entry from todo_list file
            fi
	    done
	done

#exit 1

#	## OPTION 2: process after everything is written into todo_list???
#	process_merged ## process all merged files with picasso written in todo_list (inlcuding plotting with new 24h-plotting-method)
#	for DEVICE in ${DEVICE_LS[@]}; do
#	    for DATE in ${DATE_LS[@]}; do
#		 delete_level0_merged_file $DEVICE $DATE ## delete level0 24h-file
#        delete_laserlogbookfile $DEVICE $DATE ## delete laserlogbook-file
#		 delete_entry_from_todo_list $DEVICE $DATE ## delete entry from todo_list file
#	    done
#	done
}


get_polly_filename() {
	# $1=device, $2=date
	local device=$1
	local date=$2
    # /data/level0/polly/pollyxt_lacros/data_zip/201907
        local YYYY=${date:0:4}
	local MM=${date:4:2}
	local DD=${date:6:2}
	local input_path="/data/level0/polly/${device}/data_zip/${YYYY}${MM}"
	local searchpattern="${YYYY}_${MM}_${DD}*_*[0-9].nc.zip"
	local polly_files=`ls ${input_path}/${searchpattern}`
#	echo $polly_files
#	return ${polly_files}
	if [ ${#polly_files} -gt 1 ]; then
	    local filename=${polly_files##*/}
	    local filename=`echo ${filename} | cut -d _ -f 1,2,3,4,5`
#	    local filename=$(echo ${filename}) #| cut -d _ -f 1,2,3,4,5`
	    echo $filename
	else
	    :
	fi

}


merging() {
## define function of merging

    DEVICE=$1
    DATE=$2

    local OUTPUT_FOLDER=$TODO_FOLDER/$DEVICE/data_zip/${DATE:0:6}
    mkdir -p $OUTPUT_FOLDER ## create folder if not existing, else skip
    echo "start merging... "
    
    "$PY_FOLDER"python "$PICASSO_DIR_interface"/concat_pollyxt_lvl0.py -t $DATE -d $DEVICE -o $OUTPUT_FOLDER -f ${FORCE_MERGING^}
}

write_job_into_todo_list() {
## writing job to todo_list
    DEVICE=$1
    DATE=$2
    local OUTPUT_FOLDER=$TODO_FOLDER/$DEVICE/data_zip/${DATE:0:6}
    local filename=$(get_polly_filename $DEVICE $DATE)
#    echo $filename
    already_in_list=0
    if grep -q "$filename" $PICASSO_TODO_FILE
	then
                already_in_list=1
		echo "${filename} already in todo_list"
    elif [ -n "$filename" ] && [ "$already_in_list" -eq 0 ] ## check if variable string of $filename is greater than 0 and not already in list
        then
    		echo "add $filename to todo_list"
		#local filename2=`ls $OUTPUT_FOLDER | grep "${DATE:0:4}_${DATE:4:2}_${DATE:6:2}"`
                local filename2=$(ls ${OUTPUT_FOLDER}/${DATE:0:4}_${DATE:4:2}_${DATE:6:2}_*[0-9].nc | awk  -F '/' '{print $NF}')
	        local filesize=`stat -c %s $OUTPUT_FOLDER/$filename2`
	    	echo -n "$TODO_FOLDER, " >> $PICASSO_TODO_FILE
	    	echo -n "${DEVICE}/data_zip/${DATE:0:6}, " >> $PICASSO_TODO_FILE
	    	echo -n "$filename2, " >> $PICASSO_TODO_FILE
	    	echo -n "$filename2.zip, " >> $PICASSO_TODO_FILE
	    	echo -n "$filesize, " >> $PICASSO_TODO_FILE
	    	echo -n "${DEVICE}" >> $PICASSO_TODO_FILE
		echo ""  >> $PICASSO_TODO_FILE
    else
        echo "no files to add to todo_list"
    fi
}

check_todo_list_consistency() {
## check for invalid nomenclature in todo_list_file
    # Check if the file exists
    if [ ! -e "$PICASSO_TODO_FILE" ]; then
        touch $PICASSO_TODO_FILE
        #echo "File not found: $PICASSO_TODO_FILE"
        #exit 1
    fi

    temp_file="${PICASSO_TODO_FILE}_temp"
    touch $temp_file

    ## check the number occurancy of $delimiter_pattern and the length of each string-section inbetween the $delimiter_pattern 
    delimiter_pattern=", "
    number_of_sections=5
    min_section_length=4
    ## Read the file line by line
    while IFS= read -r line; do
        ## Process each line here
        count=$(echo "$line" | grep -o "$delimiter_pattern" | wc -l)
        ## check if the line has exactly $number_of_sections; if not, this line will be skipped
        if [ "$count" -eq "$number_of_sections" ]; then
                ## intersect line with delimiter $delimiter_pattern and put it into sections-list
		IFS="${delimiter_pattern}" read -r -a sections <<< "$line"
		all_sections_long_enough=true
                ## cycle through each section and check if the strings are longer than $min_section_length; if not, this line will be skipped
		for section in "${sections[@]}"; do
		    if [ "${#section}" -lt "$min_section_length" ]; then
		        all_sections_long_enough=false
		        break
		    fi
		done
            if [ "$all_sections_long_enough" = true ]; then
                echo $line >> $temp_file
            fi
        fi
    done < "$PICASSO_TODO_FILE"
    cp $temp_file $PICASSO_TODO_FILE
    rm $temp_file
    
}


process_merged() {
## define function of processing 24h-merged data using picasso

## check if TODO-List is empty
todolist_lines=$(wc -l ${PICASSO_TODO_FILE} | cut -d' ' -f1)
if [ "$todolist_lines" -eq 0 ]; then
    echo "TODO-list is empty"
else

echo -e "\nSettings:\nPICASSO_CONFIG_FILE=$PICASSO_CONFIG_FILE\n\n"

$MATLABEXEC -nodisplay -nodesktop -nosplash <<ENDMATLAB
cd $PICASSO_DIR;
initPicassoToolbox;
clc;
picassoProcTodolist('$PICASSO_CONFIG_FILE');
exit;
ENDMATLAB

echo "Finished processing."
fi
}

copy_level0_merged_file_to_level0b() {
## copy level0 24h-file to
	DEVICE=$1
	DATE=$2
	local OUTPUT_FOLDER=$TODO_FOLDER/$DEVICE/data_zip/${DATE:0:6}
	local merged_level0_file="${OUTPUT_FOLDER}/${DATE:0:4}_${DATE:4:2}_${DATE:6:2}*.nc"
    local level0b_folder=/data/level0b/polly24h/$DEVICE/${DATE:0:4}
    mkdir -p $level0b_folder
        if ls ${merged_level0_file} 1> /dev/null 2>&1; then
    	    echo "copy merged level0 file to level0b-folder: ${level0b_folder} ..."
            cp ${merged_level0_file} ${level0b_folder}/
            echo "done."
        else
            :  # Do nothing  
        fi
}

delete_level0_merged_file() {
## deleting level0 24h-file
	DEVICE=$1
	DATE=$2
	local OUTPUT_FOLDER=$TODO_FOLDER/$DEVICE/data_zip/${DATE:0:6}
	local merged_level0_file="${OUTPUT_FOLDER}/${DATE:0:4}_${DATE:4:2}_${DATE:6:2}*.nc"
        if ls ${merged_level0_file} 1> /dev/null 2>&1; then
    	    echo "deleting merged level0 file: ${merged_level0_file} ..."
    	    rm $merged_level0_file
            echo "done."
        else
            :  # Do nothing  
        fi
}

delete_entry_from_todo_list() {
## delete entry from todo_list file
    DEVICE=$1
    DATE=$2
    entry_exists=$(grep -c "${DEVICE}.*${DATE:0:4}_${DATE:4:2}_${DATE:6:2}" $PICASSO_TODO_FILE)
    if [ "$entry_exists" -eq 0 ]; then
        : # Do nothing
    else
        echo "deleting entry ${DEVICE} ${DATE} from todo_list... "
        sed -i "/${DEVICE}.*${DATE:0:4}_${DATE:4:2}_${DATE:6:2}/d" $PICASSO_TODO_FILE 
        sed -i "/, , .zip/d" $PICASSO_TODO_FILE ## just to be sure, that wrong/empty entries are deleted from list
        echo "done."
    fi
}

delete_laserlogbookfile() {
## deleting merged 24h-laserlogfile
	DEVICE=$1
	DATE=$2
	local OUTPUT_FOLDER=$TODO_FOLDER/$DEVICE/data_zip/${DATE:0:6}
	local laserlog_file="${OUTPUT_FOLDER}/${DATE:0:4}_${DATE:4:2}_${DATE:6:2}*laserlogbook.txt"
        if ls ${laserlog_file} 1> /dev/null 2>&1; then
   	    echo "deleting merged laserlogbook file: ${laserlog_file} ..."
	    rm $laserlog_file
	    echo "done."
        else
            : # Do nothing
        fi

}


## execute main function
main


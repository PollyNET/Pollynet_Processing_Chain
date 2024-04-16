<#
.SYNOPSIS
   This script concatenates polly level0 files, write them to the todo-list and process it.

.DESCRIPTION
   This script concatenates polly level0 files, write them to the todo-list and process it.

.PARAMETER startdate
   The start date.

.PARAMETER enddate
   The end date.

.PARAMETER device
   The specified Polly device.

.PARAMETER config_file
   The picasso configuration file.

.PARAMETER level0_folder
   The path to the level0 polly files

.PARAMETER force_merging
   Enable force merging (optional switch, default: false).

.PARAMETER todolist
   Add the merged level0 file to the todo-list for processing (optional switch, default: true).

.PARAMETER proc
   Execute processing the level0 files with the PollynetProcessingChain (Picasso) The process parameter (optional switch, default: true).

.PARAMETER delmerged 
Delete the merged level0 file in the end  (e.g. after processing) (optional switch, default: true).

.EXAMPLE
   .\lib\interface\picasso_go24.ps1  -startdate "20240308" -enddate "20240308" -device "arielle","pollyxt_cpv"
   -config_file "H:\Pollynet_Processing_Chain\config\pollynet_processing_chain_config_rsd2_24h_exp.json"
   -force_merging:$true -delmerged:$false -level0_folder "C:\_data\Picasso_IO\input"
#>


# Defining parameters
param(
    [Parameter(Mandatory=$true)]
    [string]$startdate,

    [Parameter(Mandatory=$true)]
    [string]$enddate,

    [Parameter(Mandatory=$true)]
    [string[]]$device,

    [Parameter(Mandatory=$false)]
    [string]$config_file = "",

    [Parameter(Mandatory=$false)]
    [string]$level0_folder = "H:\picasso_io",

    [switch]$todolist = $true,

    [switch]$proc = $true,

    [switch]$force_merging = $false,

    [switch]$delmerged = $true
)

$PICASSO_DIR_interface = $PSScriptRoot
$lib_dir = Split-Path -Path $PICASSO_DIR_interface -Parent
$PICASSO_DIR = Split-Path -Path $lib_dir -Parent
$config_dir = Join-Path -Path $lib_dir -ChildPath "config"
$picasso_default_config_file = Join-Path -Path $config_dir -ChildPath "pollynet_processing_chain_config.json"
$PICASSO_DIR_interface = Join-Path -Path $lib_dir  -ChildPath "interface" 



# Print the values of the parameters
Write-Host "Start Date: $startdate"
Write-Host "End Date: $enddate"
Write-Host "Device: $device"
Write-Host "Picasso Configuration File: $config_file"
Write-Host "Default Picasso Configuration File: $picasso_default_config_file"
Write-Host "Level0 folder: $level0_folder"
Write-Host "Force Merging: $force_merging"
Write-Host "Write to todolist: $todolist"
Write-Host "Processing: $proc"
Write-Host "Deleting merged file: $delmerged"



# reading picasso-config file
$PICASSO_CONFIG_FILE = $config_file
$PicassoConfigContent = Get-Content -Path $PICASSO_CONFIG_FILE -Raw
$PicassoConfigContentObject = $PicassoConfigContent | ConvertFrom-Json

$PICASSO_TODO_FILE = $PicassoConfigContentObject.fileinfo_new
$TODO_FOLDER = Split-Path -Path $PICASSO_TODO_FILE -Parent
$PY_FOLDER = $PicassoConfigContentObject.pyBinDir

Write-Host "Todolist-file: $PICASSO_TODO_FILE"
Write-Host "Python folder: $PY_FOLDER"

$OUTPUT_FOLDER= Join-Path -Path $TODO_FOLDER -ChildPath "$device"
$OUTPUT_FOLDER= Join-Path -Path $OUTPUT_FOLDER -ChildPath "data_zip"

$filename = ""
$filesize = ""

function main {
    # Parse start and end dates
    $startDateTime = [DateTime]::ParseExact($startdate, "yyyyMMdd", $null)
    $endDateTime = [DateTime]::ParseExact($enddate, "yyyyMMdd", $null)
    
    # Loop through dates
    $currentDate = $startDateTime
    while ($currentDate -le $endDateTime) {
        Write-Host "Date: $($currentDate.ToString('yyyyMMdd'))"
            # Loop through devices
            foreach ($dev in $device) {
                Write-Host "Device: $dev"
    
                # Call the merging function
#                merging -date $($currentDate.ToString('yyyyMMdd')) -device $dev

                if ($todolist -eq $true) {
                    # write job into todo-list
                    write_job_into_todo_list -date $($currentDate.ToString('yyyyMMdd')) -device $dev
                }
                if ($proc -eq $true) {
                    # processing by using the PollynetProcessingChain
                    process_merged
                }
            }
        $currentDate = $currentDate.AddDays(1)
}

}


function outputfolderpath {
    param(
        [string]$date,
        [string]$device
    )

    $date_sub = $date.Substring(0,6)
#    $OUTPUT_FOLDER= Join-Path -Path $TODO_FOLDER -ChildPath $device
#    $OUTPUT_FOLDER= Join-Path -Path $OUTPUT_FOLDER -ChildPath "data_zip"
    $outputFolderPath = Join-Path -Path $OUTPUT_FOLDER -ChildPath $date_sub
    # Create the output folder if it doesn't exist
    if (-not (Test-Path -Path $outputFolderPath -PathType Container)) {
        New-Item -Path $outputFolderPath -ItemType Directory | Out-Null
    }
    return $outputFolderPath
}

function merging {
    param(
        [string]$date,
        [string]$device
    )

    $outputFolderPath = outputfolderpath -date $date -device $device
    # Call Python script with arguments
    $PYTHON = Join-Path -Path $PY_FOLDER -ChildPath "python"
    $PYTHON_SCRIPT = Join-Path -Path $PICASSO_DIR_interface "concat_pollyxt_lvl0.py"
    Write-Host "$PYTHON_SCRIPT"
    & $PYTHON $PYTHON_SCRIPT -t $date -d $device -o $outputFolderPath -f $force_merging -r $level0_folder
}


function write_job_into_todo_list {
    param(
        [string]$date,
        [string]$device
    )

    $outputFolderPath = outputfolderpath -date $date -device $device
    Write-Host "Write job into Todolist-file: $PICASSO_TODO_FILE"

    $YYYY = $date.Substring(0,4)
    $MM = $date.Substring(4,2)
    $DD = $date.Substring(6,2)
    $dateformat = $YYYY + "_" + $MM + "_" + $DD

    # Search for files matching the patterns in the output folder
    $file = Get-ChildItem -Path $outputFolderPath -Filter "*$dateformat*.nc"
    $filesize = $file.Length
    $fileNameOnly = Split-Path -Path $file -Leaf
    $filename = $file.FullName
    $subfolder = $device+"\data_zip\"+$YYYY+$MM
    $zipfile = $fileNameOnly+".zip"

    # Concatenate the strings into a single string
    # /pollyhome/Bildermacher2/experimental, pollyxt_cpv/data_zip/202109, 2021_09_17_Fri_CPV_00_00_01.nc, 2021_09_17_Fri_CPV_00_00_01.nc.zip, 153959378, pollyxt_cpv
    $combinedString = "$TODO_FOLDER, $subfolder, $fileNameOnly, $zipfile, $filesize, $device"

    # Write the combined string to the file
    Set-Content -Path $PICASSO_TODO_FILE -Value $combinedString
}


function process_merged {

$batch_script="cd $PICASSO_DIR;initPicassoToolbox;clc;picassoProcTodolist('$PICASSO_CONFIG_FILE');exit"
& 'C:\Program Files\MATLAB\R2018a\bin\matlab.exe' -nosplash -nodesktop -r $batch_script
#cd $PICASSO_DIR;
#initPicassoToolbox;
#clc;
#picassoProcTodolist('$PICASSO_CONFIG_FILE');
#exit;

}

## call function main
main

#
#main() {
#
#	create_date_ls
#	
#	for DEVICE in ${DEVICE_LS[@]}; do
#	    echo $DEVICE
#	    for DATE in ${DATE_LS[@]}; do
#	        echo $DATE	
#            merging $DEVICE $DATE ## merging of level0 files and put into todo-list
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
#	    done
#	done
#
##exit 1
#
##	## OPTION 2: process after everything is written into todo_list???
##	process_merged ## process all merged files with picasso written in todo_list (inlcuding plotting with new 24h-plotting-method)
##	for DEVICE in ${DEVICE_LS[@]}; do
##	    for DATE in ${DATE_LS[@]}; do
##		 delete_level0_merged_file $DEVICE $DATE ## delete level0 24h-file
##        delete_laserlogbookfile $DEVICE $DATE ## delete laserlogbook-file
##		 delete_entry_from_todo_list $DEVICE $DATE ## delete entry from todo_list file
##	    done
##	done
#}
#
#
#get_polly_filename() {
#	# $1=device, $2=date
#	local device=$1
#	local date=$2
#    # /data/level0/polly/pollyxt_lacros/data_zip/201907
#        local YYYY=${date:0:4}
#	local MM=${date:4:2}
#	local DD=${date:6:2}
#	local input_path="/data/level0/polly/${device}/data_zip/${YYYY}${MM}"
#	local searchpattern="${YYYY}_${MM}_${DD}*_*[0-9].nc.zip"
#	local polly_files=`ls ${input_path}/${searchpattern}`
##	echo $polly_files
##	return ${polly_files}
#	if [ ${#polly_files} -gt 1 ]; then
#	    local filename=${polly_files##*/}
#	    local filename=`echo ${filename} | cut -d _ -f 1,2,3,4,5`
##	    local filename=$(echo ${filename}) #| cut -d _ -f 1,2,3,4,5`
#	    echo $filename
#	else
#	    :
#	fi
#
#}
#
#
#merging() {
### define function of merging
#
#    DEVICE=$1
#    DATE=$2
#
#    local OUTPUT_FOLDER=$TODO_FOLDER/$DEVICE/data_zip/${DATE:0:6}
#    mkdir -p $OUTPUT_FOLDER ## create folder if not existing, else skip
#    echo "start merging... "
#    
#    "$PY_FOLDER"python "$PICASSO_DIR_interface"/concat_pollyxt_lvl0.py -t $DATE -d $DEVICE -o $OUTPUT_FOLDER -f ${FORCE_MERGING^}
#}
#
#write_job_into_todo_list() {
### writing job to todo_list
#    DEVICE=$1
#    DATE=$2
#    local OUTPUT_FOLDER=$TODO_FOLDER/$DEVICE/data_zip/${DATE:0:6}
#    local filename=$(get_polly_filename $DEVICE $DATE)
##    echo $filename
#    already_in_list=0
#    if grep -q "$filename" $PICASSO_TODO_FILE
#	then
#                already_in_list=1
#		echo "${filename} already in todo_list"
#    elif [ -n "$filename" ] && [ "$already_in_list" -eq 0 ] ## check if variable string of $filename is greater than 0 and not already in list
#        then
#    		echo "add $filename to todo_list"
#		#local filename2=`ls $OUTPUT_FOLDER | grep "${DATE:0:4}_${DATE:4:2}_${DATE:6:2}"`
#                local filename2=$(ls ${OUTPUT_FOLDER}/${DATE:0:4}_${DATE:4:2}_${DATE:6:2}_*[0-9].nc | awk  -F '/' '{print $NF}')
#	        local filesize=`stat -c %s $OUTPUT_FOLDER/$filename2`
#	    	echo -n "$TODO_FOLDER, " >> $PICASSO_TODO_FILE
#	    	echo -n "${DEVICE}/data_zip/${DATE:0:6}, " >> $PICASSO_TODO_FILE
#	    	echo -n "$filename2, " >> $PICASSO_TODO_FILE
#	    	echo -n "$filename2.zip, " >> $PICASSO_TODO_FILE
#	    	echo -n "$filesize, " >> $PICASSO_TODO_FILE
#	    	echo -n "${DEVICE}" >> $PICASSO_TODO_FILE
#		echo ""  >> $PICASSO_TODO_FILE
#    else
#        echo "no files to add to todo_list"
#    fi
#}
#
#check_todo_list_consistency() {
### check for invalid nomenclature in todo_list_file
#    # Check if the file exists
#    if [ ! -e "$PICASSO_TODO_FILE" ]; then
#        touch $PICASSO_TODO_FILE
#        #echo "File not found: $PICASSO_TODO_FILE"
#        #exit 1
#    fi
#
#    temp_file="${PICASSO_TODO_FILE}_temp"
#    touch $temp_file
#
#    ## check the number occurancy of $delimiter_pattern and the length of each string-section inbetween the $delimiter_pattern 
#    delimiter_pattern=", "
#    number_of_sections=5
#    min_section_length=4
#    ## Read the file line by line
#    while IFS= read -r line; do
#        ## Process each line here
#        count=$(echo "$line" | grep -o "$delimiter_pattern" | wc -l)
#        ## check if the line has exactly $number_of_sections; if not, this line will be skipped
#        if [ "$count" -eq "$number_of_sections" ]; then
#                ## intersect line with delimiter $delimiter_pattern and put it into sections-list
#		IFS="${delimiter_pattern}" read -r -a sections <<< "$line"
#		all_sections_long_enough=true
#                ## cycle through each section and check if the strings are longer than $min_section_length; if not, this line will be skipped
#		for section in "${sections[@]}"; do
#		    if [ "${#section}" -lt "$min_section_length" ]; then
#		        all_sections_long_enough=false
#		        break
#		    fi
#		done
#            if [ "$all_sections_long_enough" = true ]; then
#                echo $line >> $temp_file
#            fi
#        fi
#    done < "$PICASSO_TODO_FILE"
#    cp $temp_file $PICASSO_TODO_FILE
#    rm $temp_file
#    
#}
#
#
#process_merged() {
### define function of processing 24h-merged data using picasso
#
### check if TODO-List is empty
#todolist_lines=$(wc -l ${PICASSO_TODO_FILE} | cut -d' ' -f1)
#if [ "$todolist_lines" -eq 0 ]; then
#    echo "TODO-list is empty"
#else
#
#echo -e "\nSettings:\nPICASSO_CONFIG_FILE=$PICASSO_CONFIG_FILE\n\n"
#
#matlab -nodisplay -nodesktop -nosplash <<ENDMATLAB
#cd $PICASSO_DIR;
#initPicassoToolbox;
#clc;
#picassoProcTodolist('$PICASSO_CONFIG_FILE');
#exit;
#ENDMATLAB
#
#echo "Finished processing."
#fi
#}
#
#delete_level0_merged_file() {
### deleting level0 24h-file
#	DEVICE=$1
#	DATE=$2
#	local OUTPUT_FOLDER=$TODO_FOLDER/$DEVICE/data_zip/${DATE:0:6}
#	local merged_level0_file="${OUTPUT_FOLDER}/${DATE:0:4}_${DATE:4:2}_${DATE:6:2}*.nc"
#        if ls ${merged_level0_file} 1> /dev/null 2>&1; then
#    	    echo "deleting merged level0 file: ${merged_level0_file} ..."
#    	    rm $merged_level0_file
#            echo "done."
#        else
#            :  # Do nothing  
#        fi
#}
#
#delete_entry_from_todo_list() {
### delete entry from todo_list file
#    DEVICE=$1
#    DATE=$2
#    entry_exists=$(grep -c "${DEVICE}.*${DATE:0:4}_${DATE:4:2}_${DATE:6:2}" $PICASSO_TODO_FILE)
#    if [ "$entry_exists" -eq 0 ]; then
#        : # Do nothing
#    else
#        echo "deleting entry ${DEVICE} ${DATE} from todo_list... "
#        sed -i "/${DEVICE}.*${DATE:0:4}_${DATE:4:2}_${DATE:6:2}/d" $PICASSO_TODO_FILE 
#        sed -i "/, , .zip/d" $PICASSO_TODO_FILE ## just to be sure, that wrong/empty entries are deleted from list
#        echo "done."
#    fi
#}
#
#delete_laserlogbookfile() {
### deleting merged 24h-laserlogfile
#	DEVICE=$1
#	DATE=$2
#	local OUTPUT_FOLDER=$TODO_FOLDER/$DEVICE/data_zip/${DATE:0:6}
#	local laserlog_file="${OUTPUT_FOLDER}/${DATE:0:4}_${DATE:4:2}_${DATE:6:2}*laserlogbook.txt"
#        if ls ${laserlog_file} 1> /dev/null 2>&1; then
#   	    echo "deleting merged laserlogbook file: ${laserlog_file} ..."
#	    rm $laserlog_file
#	    echo "done."
#        else
#            : # Do nothing
#        fi
#
#}
#
#
### execute main function
#main


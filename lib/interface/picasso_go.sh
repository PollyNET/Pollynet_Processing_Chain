#!/bin/bash
# This script will help to process the history polly data with using Pollynet processing chain

cwd="$( cd "$(dirname "$0")" ; pwd -P )"
PATH=${PATH}:$cwd

#########################
# The command line help #
#########################
display_help() {
  echo "Usage: $0 [option...] " >&2
  echo
  echo "Process polly history data."
  echo "   -s, --start_date        set the start date for the polly data"
  echo "                           e.g., 20110101"
  echo "   -e, --end_date          set the end date for the polly data"
  echo "                           e.g., 20150101"
  echo "   -p, --polly_type        set the instrument type (case-sensitive)"
  echo "                           - PollyXT_LACROS"
  echo "                           - PollyXT_TROPOS"
  echo "                           - PollyXT_NOA"
  echo "                           - PollyXT_FMI"
  echo "                           - PollyXT_UW"
  echo "                           - PollyXT_DWD"
  echo "                           - PollyXT_TJK"
  echo "                           - PollyXT_TAU"
  echo "                           - PollyXT_CYP"
  echo "                           - PollyXT_IfT"
  echo "                           - PollyXT_CGE"
  echo "                           - Polly_1st"
  echo "                           - arielle"
  echo "                           - Polly_1v2"
  echo "   -f, --polly_folder      specify the polly data folder"
  echo "                           e.g., '/pollyhome/pollyxt_lacros'"
  echo "   -c, --config_file       specify Picasso configuration file"
  echo "                           e.g., 'pollynet_processing_chain_config.json'"
  echo "   --auto                  start automatic data processing"
  echo "   --check_gdas            reprocess polly data when GDAS1 data is ready"
  echo "   --pollyapp_config       specify the path of 'config.private' for the pollyAPP"
  echo "   -h, --help              show help message"
  echo
  exit 1
}

# Process history data
process_history() {
  echo -e "\nSettings:\nPOLLY_FOLDER=$POLLY_FOLDER\nPOLLY_TYPE=$POLLY_TYPE\PICASSO_CONFIG_FILE=$PICASSO_CONFIG_FILE\nSTART_DATE=$STARTDATE\nEND_DATE=$ENDDATE\n\n"

  matlab -nodisplay -nodesktop -nosplash <<ENDMATLAB
PICASSO_DIR = fileparts(fileparts('$cwd'));
cd(PICASSO_DIR);
initPicassoToolbox;
clc;
picassoProcHistoryData('$STARTDATE', '$ENDDATE', '$POLLY_FOLDER', ...
    'PicassoConfigFile', '$PICASSO_CONFIG_FILE', ...
    'pollyType', '$POLLY_TYPE');
exit;
ENDMATLAB

  echo "Finish"
}

# Automatic data processing
auto_process() {
matlab -nodesktop -nosplash << ENDMATLAB
PICASSO_PATH = fileparts(fileparts('$cwd'));
cd(PICASSO_PATH);

% add path
initPicassoToolbox;

% load Picasso configuration
PicassoConfig = loadjson('$PICASSO_CONFIG_FILE');
% unzip the polly data
if $flagCheckGDAS
  % reprocessing with GDAS1 data
  writeTodoListAuto('$POLLYAPP_CONFIG_FILE', '$PICASSO_CONFIG_FILE', '$POLLY_FOLDER', PicassoConfig.minDataSize, now - datenum(0, 1, 2), datenum(0, 1, 4), $flagCheckGDAS);
else
  writeTodoListAuto('$POLLYAPP_CONFIG_FILE', '$PICASSO_CONFIG_FILE', '$POLLY_FOLDER', PicassoConfig.minDataSize, now, datenum(0, 1, 4), $flagCheckGDAS);
end

% running Picasso
picassoProcTodolist('$PICASSO_CONFIG_FILE');

% add done_filelist to the database
unix(['export PERL5LIB=' '$PERL5LIB' ';' '$PERL_BIN' ' ' '$ADDNEW_SCRIPT' ' ' PicassoConfig.doneListFile ';']);
ENDMATLAB

echo "Finish"
}

# parameter initialization
POLLY_FOLDER="/data/level0/polly"
POLLY_TYPE=""
PICASSO_CONFIG_FILE=""
STARTDATE="20190101"
ENDDATE="20190103"
flagCheckGDAS="false"
POLLYAPP_CONFIG_FILE="/pollyhome/Bildermacher2/pollyAPP/config/config.private"
POLLYAPP_PATH="/pollyhome/Bildermacher2/pollyAPP"
ADDNEW_SCRIPT="/pollyhome/Bildermacher2/pollyAPP/src/util/add_new_data2pollydb.pl"
PERL5LIB="/pollyhome/Bildermacher2/.perlbrew/libs/perl-5.22.2@devel/lib/perl5"
PERL_BIN="/pollyhome/Bildermacher2/perl5/perlbrew/perls/perl-5.22.2/bin/perl"

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
      PICASSO_CONFIG_FILE="$2"
    fi
    shift 2
    ;;

  --pollyapp_config)
    if [ $# -ne 0 ]; then
      POLLYAPP_CONFIG_FILE="$2"
    fi
    shift 2
    ;;

  --auto)
    flagAuto="true"
    shift 1
    ;;

  --check_gdas)
    flagCheckGDAS="true"
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
    exit exit 1
    ;;
  *) # No more options
    break
    ;;
  esac
done

if [ $flagAuto == "true" ]
then
    auto_process
else
    process_history
fi
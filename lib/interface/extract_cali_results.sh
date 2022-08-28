#!/bin/bash
# This script can be used to extract the calibration results from SQLite DB

cwd="$( cd "$(dirname "$0")"; pwd -P )"
PATH=${PATH}:$cwd

#########################
# The command line help #
#########################
display_help() {
    echo "Usage: $0 [option...]" >&2
    echo ""
    echo "Extract calibration tables from SQLite Database (DB)"
    echo "  -f, --dbfile           file path of the SQLite DB"
    echo "  -t, --tablename        table name"
    echo "                         - lidar_calibration_constant"
    echo "                         - depol_calibration_constant"
    echo "                         - wvconst_calibration_constant"
    echo "  -d, --sqlite_driver    sqlite driver"
    echo "                         - database_toolbox"
    echo "                         - java4sqlite"
    echo "  -o, --output           output directory"
    echo "  -p, --prefix           ASCII filename prefix"
    echo "  -h, --help             show help message"
    echo ""

    exit 1
}

# main program
run_matlab() {
    matlab -nodisplay -nodesktop -nosplash <<ENDMATLAB
PROJECTDIR = fileparts(fileparts('$cwd'));
cd(PROJECTDIR);
addpath(fullfile(PROJECTDIR, 'lib'));

clc;

extract_cali_results('$DBFILE', '$OUTPUT_DIR', 'tablename', '$TABLENAME', 'prefix', '$PREFIX', 'SQLiteReadMode', '$SQLITE_DRIVER');

exit;
ENDMATLAB
}

# initialization
DBFILE=""
OUTPUT_DIR=""
TABLENAME=""
PREFIX=""
SQLITE_DRIVER=""

################################
# Check if parameters options  #
# are given on the commandline #
################################
while :; do
  case "$1" in
  -d | --dbfile)
    if [ $# -ne 0 ]; then
      DBFILE="$2"
    fi
    shift 2
    ;;

  -o | --output)
    if [ $# -ne 0 ]; then
      OUTPUT_DIR="$2"
    fi
    shift 2
    ;;

  -t | --tablename)
    if [ $# -ne 0 ]; then
      TABLENAME="$2"
    fi
    shift 2
    ;;

  -d | --sqlite_driver)
    if [ $# -ne 0 ]; then
      SQLITE_DRIVER="$2"
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

run_matlab "$DBFILE" "$OUTPUT_DIR" "$TABLENAME" "$SQLITE_DRIVER"

#!/bin/bash
# Process the current available polly data
# main script for running Picasso on rsd server

cwd="$( cd "$(dirname "$0")" ; pwd -P )"
PATH=${PATH}:$cwd

#########################
# The command line help #
#########################
display_help() {
  echo "Usage: $0 [option...]" >&2
  echo
  echo "Start Picasso."
  echo "   -s, --server            specify which server you are working on."
  echo "                           - rsd1: old rsd server"
  echo "                           - rsd2: new rsd server (default)"
  echo "   -g, --check_gdas        flag to control whether to reprocess the data when GDAS if ready (true | false)"
  echo "   -c, --config_file       specify the pollynet processing file for the data processing"
  echo "                           e.g., 'pollynet_processing_chain_config.json'"
  echo "   -h, --help              show help message."
  echo
  # echo some stuff here for the -a or --add-options
  exit 1
}

# configurations
flagCheckGDAS="false"
CURRENT_SERVER="rsd2"
POLLYNET_CONFIG_FILE="pollynet_processing_chain_config_rsd2.json"

################################
# Check if parameters options  #
# are given on the commandline #
################################
while :; do
  case "$1" in
  
  -s | --server)
    if [ $# -ne 0 ]; then
      CURRENT_SERVER="$2"
    fi
    shift 2
    ;;
    
  -c | --config_file)
    if [ $# -ne 0 ]; then
      POLLYNET_CONFIG_FILE="$2"
    fi
    shift 2
    ;;

  -g | --check_gdas)
    if [ $# -ne 0 ]; then
      flagCheckGDAS="$2"
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

case $CURRENT_SERVER in
  rsd1)   # old rsd server
    POLLYAPP_CONFIG_FILE="/pollyhome/Picasso/pollyAPP/config/config.private"
    ADDNEW_SCRIPT="/pollyhome/Picasso/pollyAPP/src/util/add_new_data2pollydb.pl"
    POLLYAPP_PATH="/pollyhome/Picasso/pollyAPP"
    POLLY_DATA_PATH="/pollyhome"
    PERL5LIB="/pollyhome/Picasso/.perlbrew/libs/perl-5.22.2@devel/lib/perl5"
    PERL_BIN="/pollyhome/Picasso/perl5/perlbrew/perls/perl-5.22.2/bin/perl"
    ;;

  rsd2)   # new rsd server
    POLLYAPP_CONFIG_FILE="/pollyhome/Bildermacher2/pollyAPP/config/config.private"
    ADDNEW_SCRIPT="/pollyhome/Bildermacher2/pollyAPP/src/util/add_new_data2pollydb.pl"
    POLLYAPP_PATH="/pollyhome/Bildermacher2/pollyAPP"
    POLLY_DATA_PATH="/data/level0/polly"
    PERL5LIB="/pollyhome/Bildermacher2/.perlbrew/libs/perl-5.22.2@devel/lib/perl5"
    PERL_BIN="/pollyhome/Bildermacher2/perl5/perlbrew/perls/perl-5.22.2/bin/perl"
    source /pollyhome/Bildermacher2/picasso-env/bin/activate
    ;;

  *)
    echo "Unknown server"
    exit 1
    ;;
esac

matlab -nodesktop -nosplash << ENDMATLAB

POLLYNET_PROCESSING_PATH = fileparts(fileparts('$cwd'));
cd(POLLYNET_PROCESSING_PATH);

% add path
addpath(fullfile(POLLYNET_PROCESSING_PATH, 'lib'));
addlibpath;
addincludepath;

% load Picasso configuration
pollynetConfig = loadjson(fullfile(POLLYNET_PROCESSING_PATH, 'config', '$POLLYNET_CONFIG_FILE'));

% unzip the polly data
locatenewfiles_newdb('$POLLYAPP_CONFIG_FILE', fullfile(POLLYNET_PROCESSING_PATH, 'config', '$POLLYNET_CONFIG_FILE'), '$POLLY_DATA_PATH', pollynetConfig.minDataSize, now, datenum(0, 1, 4), $flagCheckGDAS);

% running Picasso
pollynet_processing_chain_main(fullfile(POLLYNET_PROCESSING_PATH, 'config', '$POLLYNET_CONFIG_FILE'));

% add done_filelist to the database
unix(['export PERL5LIB=' '$PERL5LIB' ';' '$PERL_BIN' ' ' '$ADDNEW_SCRIPT' ' ' pollynetConfig.doneListFile ';']);

ENDMATLAB

echo "Finish"

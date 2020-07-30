#!/bin/bash
# Process the current available polly data
# main script for running Picasso on rsd server

#new for rsd2 source activate, try and error
source /pollyhome/Bildermacher2/picasso-env/bin/activate
cwd="$( cd "$(dirname "$0")" ; pwd -P )"
PATH=${PATH}:$cwd


#########################
# The command line help #
#########################
display_help() {
  echo "Usage: $0 [option...]" >&2
  echo
  echo "Start Picasso."
  echo "   -p, --pollyapp_config   specify the path of 'config.private' for the pollyAPP"
  echo "   -g, --check_gdas        flag to control whether to reprocess the data when GDAS if ready (true | false)"
  echo "   -c, --config_file       specify the pollynet processing file for the data processing"
  echo "                           e.g., 'pollynet_processing_chain_config.json'"
  echo "   -h, --help              show help message"
  echo
  # echo some stuff here for the -a or --add-options
  exit 1
}

# configurations
POLLYNET_CONFIG_FILE="pollynet_processing_chain_config_rsd2.json"
POLLYAPP_CONFIG_FILE="/pollyhome/Bildermacher2/pollyAPP/config/config.private";
flagCheckGDAS="false"

################################
# Check if parameters options  #
# are given on the commandline #
################################
while :; do
  case "$1" in
  
  -p | --pollyapp_config)
    if [ $# -ne 0 ]; then
      POLLYAPP_CONFIG_FILE="$2"
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

matlab -nodesktop -nosplash << ENDMATLAB

POLLYNET_PROCESSING_DIR = fileparts(fileparts('$cwd'));
cd(POLLYNET_PROCESSING_DIR);

% add path
addpath(fullfile(POLLYNET_PROCESSING_DIR, 'lib'));
addlibpath;
addincludepath;

% load Picasso configuration
pollynetConfig = loadjson(fullfile(POLLYNET_PROCESSING_DIR, 'config', '$POLLYNET_CONFIG_FILE'));

% unzip the file
locatenewfiles_newdb('$POLLYAPP_CONFIG_FILE', fullfile(POLLYNET_PROCESSING_DIR, 'config', '$POLLYNET_CONFIG_FILE'), '/data/level0/polly', pollynetConfig.minDataSize, now, datenum(0, 1, 4), $flagCheckGDAS);

% running Picasso
pollynet_processing_chain_main(fullfile(POLLYNET_PROCESSING_DIR, 'config', '$POLLYNET_CONFIG_FILE'));

% add done_filelist to the database
unix(['export PERL5LIB=/pollyhome/Bildermacher2/.perlbrew/libs/perl-5.22.2@devel/lib/perl5;/pollyhome/Bildermacher2/perl5/perlbrew/perls/perl-5.22.2/bin/perl /pollyhome/Bildermacher2/pollyAPP/src/util/add_new_data2pollydb.pl ' pollynetConfig.doneListFile ';']);

ENDMATLAB

echo "Finish"

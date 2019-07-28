#!/bin/bash
# This script will help the user the change polly processing settings.

POLLY_CONFIG_FILE="/home/picasso/Pollynet_Processing_Chain/config/arielle_config_20190722.json"
CONFIG_DISC_FILE="/home/picasso/Pollynet_Processing_Chain/doc/pollynet_config.md"

while getopts ':h' option; do
	case "$option" in
		h) echo -e "\n\nSet up the polly setup file.\nDetailed information about the settings can be found in $CONFIG_DISC_FILE\n\n"
		   exit
		   ;;
		\?) echo "illegal option."
		    exit 1
		    ;;
	esac
done 

shift $((OPTIND - 1))
/bin/nano "$POLLY_CONFIG_FILE"

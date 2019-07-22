#!/bin/bash
# This script will help the user the change polly default settings.
# The settings include:
#	depolCaliConst532: depolarization calibration constant at 532 nm
#	depolCaliConstStd532: Uncertainty of the depolarization calibration constant at 532 nm
#	depolCaliConst355: depolarization calibration constant at 355 nm
#	depolCaliConstStd355: Uncertainty of the depolarization calibration constant at 355 nm
#	LC: lidar constants at each channel.
#	LCStd: Uncertainty of the lidar constants
#	overlapFile532: the filename which contains the default or pre-calculated overlap function at Far-Range 532 nm
#	overlapFile355: the filename which contains the default or pre-calculated overlap function at Far-Range 355 nm
#	molDepol532: molecular depolarization ratio at 532 nm. (You can either use theoritical value or real value.)
#	molDepolStd532: Uncertainty of molecular depolarization ratio at 532 nm.
#	molDepol355: molecular depolarization ratio at 355 nm. (You can either use theoritical value or real value.)
#	molDepolStd355: Uncertainty of molecular depolarization ratio at 355 nm.
#	wvconst: Water vapor calibration constant. (g*kg^-1)
#	wvconststd: Uncertainty of water vapor calibration constant. (g*kg^-1)

help="depolCaliConst532: depolarization calibration constant at 532 nm
\n	depolCaliConstStd532: Uncertainty of the depolarization calibration constant at 532 nm
\n	depolCaliConst355: depolarization calibration constant at 355 nm
\n	depolCaliConstStd355: Uncertainty of the depolarization calibration constant at 355 nm
\n	LC: lidar constants at each channel.
\n	LCStd: Uncertainty of the lidar constants
\n	overlapFile532: the filename which contains the default or pre-calculated overlap function at Far-Range 532 nm
\n	overlapFile355: the filename which contains the default or pre-calculated overlap function at Far-Range 355 nm
\n	molDepol532: molecular depolarization ratio at 532 nm. (You can either use theoritical value or real value.)
\n	molDepolStd532: Uncertainty of molecular depolarization ratio at 532 nm.
\n	molDepol355: molecular depolarization ratio at 355 nm. (You can either use theoritical value or real value.)
\n	molDepolStd355: Uncertainty of molecular depolarization ratio at 355 nm.
\n	wvconst: Water vapor calibration constant. (g*kg^-1)
\n	wvconststd: Uncertainty of water vapor calibration constant. (g*kg^-1)"

DEFAULT_FILE="/home/picasso/Pollynet_Processing_Chain/lib/pollyDefaults/arielle_defaults.json"

while getopts ':h' option; do
	case "$option" in
		h) echo -e "\n\nDescription for the defaults\n\n\n" $help "\n\n\n"
		   exit
		   ;;
		\?) echo "illegal option."
		    exit 1
		    ;;
	esac
done 

shift $((OPTIND - 1))
/bin/nano $DEFAULT_FILE


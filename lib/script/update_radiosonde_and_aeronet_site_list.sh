#!/bin/bash
# Update the radiosonde and AERONET site list everyday

PATH=${PATH}:/usr/programming/matlab/matlab-2014a/bin

echo "Updating the radiosonde and AERONET site list"

matlab -nodesktop -nosplash << ENDMATLAB

cd /pollyhome/Picasso/Pollynet_Processing_Chain/lib

download_aeronet_list
download_radiosonde_list

ENDMATLAB

echo "Finish the update!"

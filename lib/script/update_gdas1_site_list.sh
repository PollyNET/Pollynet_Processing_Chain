#!/bin/bash
# Update the gdas1 site list everyday

echo "Updating the gdas1 site list to $1"
ls /lacroshome/cloudnet/data/model/gdas1/ | cat >  $1

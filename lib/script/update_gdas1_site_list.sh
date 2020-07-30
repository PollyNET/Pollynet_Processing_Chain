#!/bin/bash
# Update the gdas1 site list everyday

echo "Updating the gdas1 site list to $1"
ls /data/level1a/model/gdas1/profiles/ | cat >  $1

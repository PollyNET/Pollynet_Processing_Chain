#!/bin/bash
# Process arielle data of yesterday

cwd=$(dirname "$0")
PATH=${PATH}:$cwd

echo "Processing yesterday"
YYYYMMDD=$(date --utc "+%Y%m%d" -d "yesterday")
arielle_process_day.sh -d $YYYYMMDD

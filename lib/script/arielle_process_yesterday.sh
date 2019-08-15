#!/bin/bash
# Process arielle data of yesterday

cwd="$( cd "$(dirname "$0")" ; pwd -P )"
PATH=${PATH}:$cwd

echo "Processing yesterday"
YYYYMMDD=$(date --utc "+%Y%m%d" -d "yesterday")
arielle_process_day.sh -d $YYYYMMDD

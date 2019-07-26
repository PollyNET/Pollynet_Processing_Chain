#!/bin/bash
#
# extend all the images in specified folder to certain image size using imagemagick
#
# Usage:
#   extend_plots_in_folder path width height background [suffix]
# Input:
#   path: the path for saving the images
#   width: number of pixels for the width
#   height: number of pixels for the height
#   background: background color for the padding area
#   [suffix]: suffix to each of the image.
# History:
#   2019-05-17. First edition by Zhenping

usage="$(basename "$0") [-h] [path width height background [suffix] [regexp]] 
program to  extend all the images in specified folder to certain image size
where:
    -h  show this help text
    [path width height background [suffix] [regexp]] resize the image"

width="1000"
height="500"
background="transparent"
suffix="test"
regexp="*"

while getopts "hc:" opt; do
    case ${opt} in
        h )
            echo "$usage"
            exit 0
            ;;
        c )
            ;;
        \? )
            exit 1
            ;;
    esac
done

if [ "$#" -ne 5 ] && [ "$#" -ne 4 ] && [ "$#" -ne 6 ]; then
    echo "Not enough inputs."
    echo "$usage"
    exit 1
fi

if [ "$#" -eq 5 ]; then
    suffix=$5
elif [ "$#" -eq 6 ]; then
    suffix=$5
    regexp=$6
fi

path=$1
width=$2
height=$3
background=$4

for file in $path/$regexp;
do
    echo "Converting $file"
    DIR=$(dirname "$file")
    filename=$(basename -- "$file")
    ext="${filename##*.}"
    filename="${filename%.*}"
    dst="$DIR/$filename$suffix.$ext"
    convert $file -resize "$width"x"$height" -background $background -compose Copy -gravity center -extent "$width"x"$height" $dst
done



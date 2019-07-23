#!/bin/bash
#
# extend the image size using imagemagick
#
# Usage:
#   extend_plot source width height background dst
# Input:
#   source: source file
#   width: number of pixels for the width
#   height: number of pixels for the height
#   background: background color for the padding area
#   dst: destination file
# History:
#   2019-05-17. First edition by Zhenping

usage="$(basename "$0") [-h] [source width height background dst] 
program to extend the image size
where:
    -h  show this help text
    [source width height background dst] resize the image"

width="1000"
height="500"
background="transparent"

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

if [ "$#" -ne 5 ]; then
    echo "Not enough inputs."
    echo "$usage"
    exit 1
fi

source=$1
width=$2
height=$3
background=$4
dst=$5

convert $source -resize "$width"x"$height" -background $background -compose Copy -gravity center -extent "$width"x"$height" $dst



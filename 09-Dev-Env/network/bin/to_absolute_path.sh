#!/usr/bin/env bash
# Takes a path argument and returns it as an absolute path. 
# No-op if the path is already absolute.
function to-absolute-path {
    target="$1"

    if [ "$target" == '.' ]; then
       export ABS_PATH="$(pwd)"
    elif [ "$target" == '.' ]; then
       export ABS_PATH="$(dirname "$(pwd)")"
    else
       export ABS_PATH="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
    fi
}

# to-absolute-path $1
# echo $ABS_PATH
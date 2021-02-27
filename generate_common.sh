#!/bin/bash

DUMP_FILE=stdout
function DumpOpen
{
    DUMP_FILE=$1
    echo -e "\c" > $DUMP_FILE
}

function DumpLine
{
    echo -e "$1" >> $DUMP_FILE
}

function DumpClose
{
    DUMP_FILE=stdout
}

function TransformInfoIni
{
    InfoIniPath=$1".ini"
    MacroPrefix=_
    OutputH=$1

    if [ -f $InfoIniPath ]; then
        cat $InfoIniPath |
        sed s/\;/"\/\/"/g |
        sed s/=/\ /g |
        sed s/"^ *"//g |
        sed s/"^\([a-z][a-z0-9_]*\)"/"#define $MacroPrefix\1"/g > $OutputH
        echo "$InfoIniPath converted."
    else
        >&2 echo "Error: Info ini file '$InfoIniPath' cannot be found!"
    fi
}

function CreateHeader
{
    RAW_HEADER_PATH=$1
    HEADER_PATH=$1".h"

    HEADER_CHANGED=$(diff -q -N $RAW_HEADER_PATH $HEADER_PATH)
    if [ "$HEADER_CHANGED" != "" ]; then
        cp $RAW_HEADER_PATH $HEADER_PATH
        echo "$HEADER_PATH has been created."
    else
        echo "$HEADER_PATH has not been touched."
    fi
}

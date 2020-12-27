#!/bin/bash

COMMON_HOME="$(cd "$( dirname "$0" )/.." && pwd)"
source $COMMON_HOME/generate_common.sh

# module basic parameters:
MODULE_ID=$1
MODULE_HOME="$(cd $2 && pwd)"
COMPONENT_HOME=$(cd $2 && git rev-parse --show-toplevel)
COMPONENT_ID="$(basename $COMPONENT_HOME)"
echo "Module Name       : $MODULE_ID"
echo "Module Home       : $MODULE_HOME"
echo "Component Name    : $COMPONENT_ID"
echo "Component Home    : $COMPONENT_HOME"

MODULE_ID_UPCASE=$(echo $MODULE_ID | tr '[:lower:]' '[:upper:]' | tr '-' '_')
COMPONENT_ID_UPCASE=$(echo $COMPONENT_ID | tr '[:lower:]' '[:upper:]')

MODULE_HEADER="$MODULE_HOME/module.h"
if [ -f $MODULE_HEADER ]; then
    echo "Header file '$MODULE_HEADER' found."
    exit 0
fi

DumpOpen $MODULE_HEADER
MODULE_H_GUARD=__SYMBOID_${COMPONENT_ID_UPCASE}_${MODULE_ID_UPCASE}_MODULE_H__
DumpLine "#ifndef $MODULE_H_GUARD"
DumpLine "#define $MODULE_H_GUARD"
DumpLine ""
DumpLine "#define MODULE_NAME \"$MODULE_ID\""
DumpLine "#define MODULE_PARENT_COMPONENT \"$COMPONENT_ID\""
DumpLine "#define MODULE_DESC \"$COMPONENT_ID-$MODULE_ID-module\""
DumpLine ""
DumpLine "#endif // $MODULE_H_GUARD"
DumpClose

echo "Header file '$MODULE_HEADER' generated."

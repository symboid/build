#!/bin/bash

COMMON_HOME="$(cd "$( dirname "$0" )/.." && pwd)"
source $COMMON_HOME/generate_common.sh

COMPONENT_NAME=$1
COMPONENT_HOME="$(cd "$( dirname "$0" )/../../$COMPONENT_NAME" && pwd)"
COMPONENT_REV_ID="$(cd $COMPONENT_HOME && git rev-list --max-count=1 HEAD)"
REVISION_STAMP="$COMPONENT_HOME/.revision.stamp"
if [ -f $REVISION_STAMP ]; then
    TS_REV_ID=$(cat $REVISION_STAMP)
    if [[ "$TS_REV_ID" == "$COMPONENT_REV_ID" ]]; then
        echo "No changes in component revision."
        exit 0
    fi
fi

DumpOpen $REVISION_STAMP
DumpLine $COMPONENT_REV_ID
DumpClose

echo "Component revision stamp '$REVISION_STAMP' updated."

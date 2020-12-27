#!/bin/bash

COMMON_HOME="$(cd "$( dirname "$0" )/.." && pwd)"
source $COMMON_HOME/generate_common.sh

if [ $# -lt 1 ]; then
    echo "!!! Component name must be specified! Exiting..."
    exit 1
fi

QT_VER_STRING=""
if [ $# -ge 1 ]; then
    QT_VER_STRING=$2
fi

# calculating component code revision:
COMPONENT_NAME=$1
COMPONENT_HOME="$(cd "$( dirname "$0" )/../../$COMPONENT_NAME" && pwd)"
COMPONENT_REV_NUM="$(cd $COMPONENT_HOME && git rev-list --count HEAD)"
COMPONENT_REV_ID="$(cd $COMPONENT_HOME && git rev-list --max-count=1 HEAD)"
echo "Component Name    : $COMPONENT_NAME"
echo "Component Home    : $COMPONENT_HOME"
echo "Component Rev Num : $COMPONENT_REV_NUM"
echo "Component Rev ID  : $COMPONENT_REV_ID"

SDK_HOME="$(cd "$( dirname "$0" )/../../sdk" && pwd)"
SDK_REV_ID="$(cd $SDK_HOME && git rev-list --max-count=1 HEAD)"
echo "SDK Rev ID        : $SDK_REV_ID"

# replacing trailing + with . if any
COMPONENT_REV_NUM=$(echo $COMPONENT_REV_NUM | sed s/\+/./)

# build time properties
COMPONENT_BUILD_TIMESTAMP=`date +%s`
COMPONENT_BUILD_DATE=`date +%Y.%m.%d`
echo "Build timestamp   : $COMPONENT_BUILD_TIMESTAMP ($COMPONENT_BUILD_DATE)"

COMPONENT_INI="$COMPONENT_HOME/component.ini"
if [ -f $COMPONENT_INI ]; then
    source $COMPONENT_INI
else
    echo "!!! Component config file '$COMPONENT_INI' cannot be found!"
    exit 1
fi

COMPONENT_DEPS=$(echo $COMPONENT_DEPS|sed s/,/\",\ \"/g)
# setting exact component id of qtre (with version)
COMPONENT_DEPS=$(echo $COMPONENT_DEPS|sed s/qtre/qtre$QT_VER_STRING/g)
if [ "$COMPONENT_DEPS" != "" ]; then
    COMPONENT_DEPS=$(echo \"${COMPONENT_DEPS}\")
fi

COMPONENT_VER_SERIAL=$COMPONENT_REV_NUM
COMPONENT_VER_STRING="$COMPONENT_VER_MAJOR.$COMPONENT_VER_MINOR.$COMPONENT_VER_PATCH.$COMPONENT_VER_SERIAL"

COMPONENT_JSON="$COMPONENT_HOME/component.json"
DumpOpen $COMPONENT_JSON
DumpLine "{"
DumpLine "\t\"component\": {"
DumpLine "\t\t\"id\": \"$COMPONENT_ID\","
DumpLine "\t\t\"title\": \"$COMPONENT_TITLE\","
DumpLine "\t\t\"swid\": $COMPONENT_SWID,"
DumpLine "\t\t\"revision\": {"
DumpLine "\t\t\t\"num\": $COMPONENT_REV_NUM,"
DumpLine "\t\t\t\"id\": \"$COMPONENT_REV_ID\","
if [[ "$COMPONENT_DEPS" == *"qdk"* ]]; then
DumpLine "\t\t\t\"qdk\": \"$QDK_REV_ID\","
fi
DumpLine "\t\t\t\"sdk\": \"$SDK_REV_ID\""
DumpLine "\t\t},"
DumpLine "\t\t\"version\": {"
DumpLine "\t\t\t\"major\": $COMPONENT_VER_MAJOR,"
DumpLine "\t\t\t\"minor\": $COMPONENT_VER_MINOR,"
DumpLine "\t\t\t\"patch\": $COMPONENT_VER_PATCH,"
DumpLine "\t\t\t\"serial\": $COMPONENT_VER_SERIAL,"
if [[ "$QT_VER_STRING" != "" ]]; then
DumpLine "\t\t\t\"qt\": \"$QT_VER_STRING\","
fi
DumpLine "\t\t\t\"string\": \"$COMPONENT_VER_STRING\""
DumpLine "\t\t},"
if [[ "$COMPONENT_LAUNCH_MODULE" != "" ]]; then
DumpLine "\t\t\"launch_module\": \"$COMPONENT_LAUNCH_MODULE\","
fi
if [[ "$COMPONENT_EULA_VERSION" != "" ]]; then
DumpLine "\t\t\"eula_version\": $COMPONENT_EULA_VERSION,"
fi
DumpLine "\t\t\"deps\": [ $COMPONENT_DEPS ],"
DumpLine "\t\t\"build\": {"
DumpLine "\t\t\t\"timestamp\": $COMPONENT_BUILD_TIMESTAMP,"
DumpLine "\t\t\t\"date\": \"$COMPONENT_BUILD_DATE\""
DumpLine "\t\t}"
DumpLine "\t}"
DumpLine "}"
DumpClose

echo "Property file '$COMPONENT_JSON' generated."

COMPONENT_ID_UPCASE=$(echo $COMPONENT_ID | tr '[:lower:]' '[:upper:]')

COMPONENT_HEADER="$COMPONENT_HOME/component.h"
DumpOpen $COMPONENT_HEADER
COMPONENT_H_GUARD=__SYMBOID_${COMPONENT_ID_UPCASE}_COMPONENT_H__
DumpLine "#ifndef $COMPONENT_H_GUARD"
DumpLine "#define $COMPONENT_H_GUARD"
DumpLine ""
DumpLine "#define COMPONENT_NAME \"$COMPONENT_ID\""
DumpLine "#define COMPONENT_SWID $COMPONENT_SWID"
DumpLine "#define COMPONENT_TITLE \"$COMPONENT_TITLE\""
DumpLine ""
DumpLine "#define COMPONENT_REV_NUM $COMPONENT_REV_NUM"
DumpLine "#define COMPONENT_REV_ID \"$COMPONENT_REV_ID\""
if [[ "$COMPONENT_DEPS" == *"qdk"* ]]; then
DumpLine "#define COMPONENT_REV_QDK \"$QDK_REV_ID\""
fi
DumpLine "#define COMPONENT_REV_SDK \"$SDK_REV_ID\""
DumpLine ""
DumpLine "#define COMPONENT_VER_MAJOR $COMPONENT_VER_MAJOR"
DumpLine "#define COMPONENT_VER_MINOR $COMPONENT_VER_MINOR"
DumpLine "#define COMPONENT_VER_PATCH $COMPONENT_VER_PATCH"
DumpLine "#define COMPONENT_VER_SERIAL $COMPONENT_REV_NUM"
if [[ "$QT_VER_STRING" != "" ]]; then
DumpLine "#define COMPONENT_VER_QT \"$QT_VER_STRING\""
fi
DumpLine "#define COMPONENT_VER_STRING \"$COMPONENT_VER_STRING\""
DumpLine ""
if [[ "$COMPONENT_LAUNCH_MODULE" != "" ]]; then
DumpLine "#define COMPONENT_LAUNCH_MODULE \"$COMPONENT_LAUNCH_MODULE\""
DumpLine ""
fi
if [[ "$COMPONENT_EULA_VERSION" != "" ]]; then
DumpLine "#define COMPONENT_EULA_VERSION $COMPONENT_EULA_VERSION"
DumpLine ""
fi
DumpLine "#define COMPONENT_DEPS { $COMPONENT_DEPS }"
DumpLine ""
DumpLine "#define COMPONENT_BUILD_TIMESTAMP $COMPONENT_BUILD_TIMESTAMP"
DumpLine "#define COMPONENT_BUILD_DATE \"$COMPONENT_BUILD_DATE\""
DumpLine ""
DumpLine "#endif // $COMPONENT_H_GUARD"
DumpClose

echo "Header file '$COMPONENT_HEADER' generated."

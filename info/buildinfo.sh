#!/bin/bash

function TransformInfoIni
{
    InfoIniPath=$1".ini"
    MacroPrefix=$2
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

    HEADER_CHANGED=`diff -q -N $RAW_HEADER_PATH $HEADER_PATH`
    if [ "$HEADER_CHANGED" != "" ]; then
        cp $RAW_HEADER_PATH $HEADER_PATH
        echo "$HEADER_PATH has been created."
    else
        echo "$HEADER_PATH has not been touched."
    fi
}

# selecting the HG vcs command:
HG=`which hg`
if [ "$HG"=="" ]; then
    HG=/usr/local/bin/hg
fi

# calculating SDK code revision:
SDK_HOME="$(cd "$( dirname "$0" )/../.." && pwd)"
SDK_REPO_REV="1000" #"$($HG id -n -r . $SDK_HOME)"
SDK_REV=$SDK_REPO_REV
echo "SDK Home : $SDK_HOME"
echo "SDK Repo Rev  : $SDK_REPO_REV"

# calculating APP code revision:
APP_HOME="$(pwd)"
APP_REPO_REV="$(cd $APP_HOME; $HG id -n -r .)"
APP_REV=$(expr $SDK_REPO_REV + $APP_REPO_REV)
echo "App Home : $APP_HOME"
echo "App Repo Rev  : $APP_REPO_REV"

# generating coderev.ini:
CODEREV_INI=$APP_HOME/coderev.ini
echo "" > $CODEREV_INI
echo "; code revision info:" >> $CODEREV_INI
echo "sdk_repo_rev=$SDK_REPO_REV" >> $CODEREV_INI
echo "app_repo_rev=$APP_REPO_REV" >> $CODEREV_INI
echo "app_serial_num=$APP_REV" >> $CODEREV_INI
echo "" >> $CODEREV_INI

# transformation of coderev.ini
CODEREV_RAW_H="$APP_HOME/coderev"
TransformInfoIni $CODEREV_RAW_H
CreateHeader $CODEREV_RAW_H

# transformation of appinfo.ini:
APP_HEADER_RAW_H="$APP_HOME/appinfo"
TransformInfoIni $APP_HEADER_RAW_H APP_
CreateHeader $APP_HEADER_RAW_H

# generating buildinfo.h
BUILD_INFO_RAW_H="$APP_HOME/buildinfo"
BUILD_INFO_GUARD="__BUILDINFO_H__"
echo "" > $BUILD_INFO_RAW_H
echo "#ifndef $BUILD_INFO_GUARD" >> $BUILD_INFO_RAW_H
echo "#define $BUILD_INFO_GUARD" >> $BUILD_INFO_RAW_H
echo "" >> $BUILD_INFO_RAW_H
echo "#include \"coderev.h\"" >> $BUILD_INFO_RAW_H
echo "#include \"appinfo.h\"" >> $BUILD_INFO_RAW_H
echo "#include \"hosting/mod/sysabout.h\"" >> $BUILD_INFO_RAW_H
echo "" >> $BUILD_INFO_RAW_H
echo "class AppBuildInfo : public Sh::BuildInfo" >> $BUILD_INFO_RAW_H
echo "{" >> $BUILD_INFO_RAW_H
echo "public:" >> $BUILD_INFO_RAW_H
echo "    virtual int serialNumber() const override" >> $BUILD_INFO_RAW_H
echo "    {" >> $BUILD_INFO_RAW_H
echo "        return app_serial_num;" >> $BUILD_INFO_RAW_H
echo "    }" >> $BUILD_INFO_RAW_H
echo "    virtual SyLiteral appShortId() const override" >> $BUILD_INFO_RAW_H
echo "    {" >> $BUILD_INFO_RAW_H
echo "        return APP_short_id;" >> $BUILD_INFO_RAW_H
echo "    }" >> $BUILD_INFO_RAW_H
echo "    virtual SyLiteral appPublisher() const override" >> $BUILD_INFO_RAW_H
echo "    {" >> $BUILD_INFO_RAW_H
echo "        return APP_publisher;" >> $BUILD_INFO_RAW_H
echo "    }" >> $BUILD_INFO_RAW_H
echo "    virtual SyLiteral appLongTitle() const override" >> $BUILD_INFO_RAW_H
echo "    {" >> $BUILD_INFO_RAW_H
echo "        return APP_long_title;" >> $BUILD_INFO_RAW_H
echo "    }" >> $BUILD_INFO_RAW_H
echo "    virtual SyLiteral appShortTitle() const override" >> $BUILD_INFO_RAW_H
echo "    {" >> $BUILD_INFO_RAW_H
echo "        return APP_short_title;" >> $BUILD_INFO_RAW_H
echo "    }" >> $BUILD_INFO_RAW_H
echo "    virtual int appMajorVer() const override" >> $BUILD_INFO_RAW_H
echo "    {" >> $BUILD_INFO_RAW_H
echo "        return APP_major_ver;" >> $BUILD_INFO_RAW_H
echo "    }" >> $BUILD_INFO_RAW_H
echo "    virtual int appMinorVer() const override" >> $BUILD_INFO_RAW_H
echo "    {" >> $BUILD_INFO_RAW_H
echo "        return APP_minor_ver;" >> $BUILD_INFO_RAW_H
echo "    }" >> $BUILD_INFO_RAW_H
echo "    virtual int appPatchVer() const override" >> $BUILD_INFO_RAW_H
echo "    {" >> $BUILD_INFO_RAW_H
echo "        return APP_patch_ver;" >> $BUILD_INFO_RAW_H
echo "    }" >> $BUILD_INFO_RAW_H
echo "};" >> $BUILD_INFO_RAW_H
echo "" >> $BUILD_INFO_RAW_H
echo "#endif // $BUILD_INFO_GUARD" >> $BUILD_INFO_RAW_H
echo "" >> $BUILD_INFO_RAW_H
CreateHeader $BUILD_INFO_RAW_H

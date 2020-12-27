#!/bin/bash

source "$SYS_ROOT/build/deploy/osx/config.sh"
source "$SYS_ROOT/build/deploy/osx/package.sh"

QTRE_BUNDLE_NAME="QtRE-$QT_VER.component"
QTRE_INSTALL_LOCATION="Library/Symboid/$QTRE_BUNDLE_NAME"
QTRE_FRAMEWORKS_LOCATION="$QTRE_INSTALL_LOCATION/Contents/Frameworks"
QT_LIB_DIR=$(cd "$QT_DIR/../lib" && pwd)

QtBasicLibs="QtCore QtGui QtWidgets QtQml QtQuick"

function QtDepsGen
{
    _BUNDLE_PATH="$1"
    _DEP_GEN_LOG="$PACKAGE_WORKING_DIR/qtdeps.log"
    "$QT_DIR/macdeployqt" "$_BUNDLE_PATH" -qmldir="$INSTALL_DIR/qml" -verbose=3 2> "$_DEP_GEN_LOG"
}

function QtMoveLibs
{
    _BUNDLE_PATH="$1"
    _BUNDLE_FRAMEWORKS="$_BUNDLE_PATH/Contents/Frameworks"
    _QTRE_FRAMEWORKS_DIR="$PACKAGE_ROOT/$QTRE_FRAMEWORKS_LOCATION"

    mkdir -p "$_QTRE_FRAMEWORKS_DIR"

    EchoSep
    for _FRAMEWORK in $QtBasicLibs; do
        EchoLine "Basic framework" "$_FRAMEWORK.framework"
        rm -rf "$_BUNDLE_FRAMEWORKS/$_FRAMEWORK.framework"
    done

    EchoSep
    _FRAMEWORKS=$(ls "$_BUNDLE_FRAMEWORKS")
    for _FRAMEWORK in $_FRAMEWORKS; do
        EchoLine "Additional framework" "$_FRAMEWORK"
        mv -f "$_BUNDLE_FRAMEWORKS/$_FRAMEWORK" "$_QTRE_FRAMEWORKS_DIR/$_FRAMEWORK"
    done

    rmdir "$_BUNDLE_FRAMEWORKS"
}

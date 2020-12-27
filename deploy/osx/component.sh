#!/bin/bash

source "$SYS_ROOT/build/deploy/osx/config.sh"
source "$SYS_ROOT/build/deploy/osx/package.sh"
source "$SYS_ROOT/build/deploy/osx/qt.sh"

function BundleAddProperty
{
    _PROPERTY_NAME="$1"
    _PROPERTY_TYPE="$2"
    _PROPERTY_VALUE="$3"

    /usr/libexec/PlistBuddy -c "Add :$_PROPERTY_NAME $_PROPERTY_TYPE $_PROPERTY_VALUE" "$BUNDLE_PLIST"
}

function BundleAddStringProperty
{
    _PROPERTY_NAME="$1"
    _PROPERTY_VALUE="$2"

    BundleAddProperty "$_PROPERTY_NAME" "string" "$_PROPERTY_VALUE"
}

function BundleAddBooleanProperty
{
    _PROPERTY_NAME="$1"
    _PROPERTY_VALUE="$2"

    BundleAddProperty "$_PROPERTY_NAME" "bool" "$_PROPERTY_VALUE"
}

function ComponentInit
{
    _BUNDLE_INSTALL_LOCATION="$1"
    _BUNDLE_IDENTIFIER="$2"

    BUNDLE_PATH="$PACKAGE_ROOT/$_BUNDLE_INSTALL_LOCATION"
    BUNDLE_PLIST="$BUNDLE_PATH/Contents/Info.plist"

    EchoSep
	echo "     |"
	echo "     |           $_BUNDLE_INSTALL_LOCATION"
	echo "     |"
	
	EchoConfig
	
    # reporting bundle parameters:
    EchoSep
    EchoVar "Bundle location" "$_BUNDLE_INSTALL_LOCATION"
    EchoVar "Bundle identifier" "$_BUNDLE_IDENTIFIER"
    EchoVar "Bundle title" "$COMPONENT_TITLE"
    EchoVar "Bundle path" "$BUNDLE_PATH"

    mkdir -p "$BUNDLE_PATH"
    mkdir "$BUNDLE_PATH/Contents"
    mkdir "$BUNDLE_PATH/Contents/MacOS"
    mkdir "$BUNDLE_PATH/Contents/Resources"
    cp "$SYS_ROOT/build/deploy/osx/Info.plist" "$BUNDLE_PLIST"
    cp "$SYS_ROOT/build/deploy/osx/empty.lproj" "$BUNDLE_PATH/Contents/Resources/empty.lproj"

    BundleAddStringProperty "CFBundleIdentifier" "$_BUNDLE_IDENTIFIER"

    if [[ "$COMPONENT_TITLE" != "" ]]; then
        BundleAddStringProperty "CFBundleName" "$COMPONENT_TITLE"
    fi

    EchoSep
}

function ApiInit
{

    BUNDLE_PATH="$PACKAGE_ROOT"

    EchoSep
    echo "     |"
    echo "     |           $COMPONENT_ID API "
    echo "     |"

    EchoConfig

    # reporting bundle parameters:
    EchoSep
    EchoVar "Bundle title" "$COMPONENT_TITLE"
    EchoVar "Bundle path" "$BUNDLE_PATH"

    mkdir -p "$BUNDLE_PATH"
    mkdir "$BUNDLE_PATH/bin"
    mkdir "$BUNDLE_PATH/lib"
    mkdir "$BUNDLE_PATH/include"

    EchoSep
}

function ComponentIcon
{
    _ICON_FILE_PATH="$1"
    cp "$_ICON_FILE_PATH" "$BUNDLE_PATH/Contents/Resources/AppIcon.icns"
    BundleAddStringProperty "CFBundleIconFile" "AppIcon"
}

function ComponentType
{
    _PACKAGE_TYPE=$1
    cp "$SYS_ROOT/build/deploy/osx/PkgInfo_${_PACKAGE_TYPE}" "$BUNDLE_PATH/Contents/PkgInfo"
    BundleAddStringProperty "CFBundlePackageType" "${_PACKAGE_TYPE}"
}

function ComponentExecutable
{
    _BUNDLE_EXECUTABLE=$1
    BundleAddStringProperty "CFBundleExecutable" "$_BUNDLE_EXECUTABLE"
}

SHARED_MODULES=

function ComponentModule
{
    SOURCE_BIN="$INSTALL_DIR/bin/$1"
    if [[ "$2" != "" ]];then
        TARGET_BASENAME=$2
        EchoLine "Deploying binary" "$SOURCE_BIN --> $TARGET_BASENAME"
    else
        TARGET_BASENAME=$1
        EchoLine "Deploying binary" "$SOURCE_BIN"
    fi
    TARGET_BIN="$BUNDLE_PATH/Contents/MacOS/$TARGET_BASENAME"

    cp "$SOURCE_BIN" "$TARGET_BIN"
    chmod +x "$TARGET_BIN"
    install_name_tool -id "$TARGET_BASENAME" "$TARGET_BIN"
    install_name_tool -add_rpath @executable_path "$TARGET_BIN"
    install_name_tool -add_rpath "/$QTRE_FRAMEWORKS_LOCATION" "$TARGET_BIN"

    #INTERNAL_DEPS=`otool -L "$TARGET_BIN" | sed -E "s/ \(.*$//g" | sed -E "s/^.//g"`
    for DEP_MODULE in $SHARED_MODULES; do
        # 1. filtering for dependencies containing $DEP_MODULE
        # 2. cutting the leading part formed like /path/to/dep/
        # 3. cutting the trailing part beginning with "."
        INTERNAL_DEP=`otool -L "$TARGET_BIN" | grep $DEP_MODULE | sed -E "s/ \(.*$//g" | sed "s/^.//g"`
        if [[ "$INTERNAL_DEP" != "" ]]; then
            EchoLine "    dep fix" "$INTERNAL_DEP --> @executable_path/$DEP_MODULE.dylib"
            install_name_tool -change "$INTERNAL_DEP" "@executable_path/$DEP_MODULE.dylib" "$TARGET_BIN"
        fi
    done

}

function ApiModule
{
    if [[ "$2" != "" ]]; then
        _FOLDER=$1
        _MODULE_NAME=$2
    else
        _MODULE_NAME=$1
    fi

    if [ -f "$INSTALL_DIR/bin/lib$_MODULE_NAME.dylib" ]; then
        EchoLine "Deploying module" "$_MODULE_NAME"
        cp "$INSTALL_DIR/bin/lib$_MODULE_NAME.dylib" "$BUNDLE_PATH/bin"
        cp -r "$INSTALL_DIR/include/$_MODULE_NAME" "$BUNDLE_PATH/include"
    elif [ -f "$INSTALL_DIR/lib/lib$_FOLDER$_MODULE_NAME.a" ]; then
        EchoLine "Deploying module" "$_FOLDER$_MODULE_NAME"
        cp "$INSTALL_DIR/lib/lib$_FOLDER$_MODULE_NAME.a" "$BUNDLE_PATH/lib"
        mkdir -p "$BUNDLE_PATH/include/$_FOLDER"
        cp -r "$INSTALL_DIR/include/$_FOLDER/$_MODULE_NAME" "$BUNDLE_PATH/include/$_FOLDER/$_MODULE_NAME"
    fi
}

function ApiModuleExe
{
    _MODULE_NAME=$1

    if [ -f "$INSTALL_DIR/bin/$_MODULE_NAME" ]; then
        EchoLine "Deploying module exe" "$_MODULE_NAME"
        cp "$INSTALL_DIR/bin/$_MODULE_NAME" "$BUNDLE_PATH/bin"
    fi
}

function ApiFile
{
    _SRC_FILE="$INSTALL_DIR/$1"
    _DIR_NAME=$(dirname "$1")
    _DST_DIR="$BUNDLE_PATH/$_DIR_NAME"
    EchoLine "Deploying file" "$1"
    mkdir -p "$_DST_DIR"
    cp -r "$_SRC_FILE" "$_DST_DIR/"
}

function ComponentModuleShared
{
    ComponentModule "$1.dylib"
    SHARED_MODULES="$SHARED_MODULES $1"
}

function ComponentLauncherLink
{
    _SYMLINK_SOURCE="/Library/Symboid/Platform.app/Contents/MacOS/launcher"
    _SYMLINK_TARGET="$BUNDLE_PATH/Contents/MacOS/$1"

    EchoLine "Symbolic link" "$1 --> $_SYMLINK_TARGET"
    ln -s "$_SYMLINK_SOURCE" "$_SYMLINK_TARGET"
}

function ComponentFile
{
    _SOURCE_FILE="$INSTALL_DIR/$1"
    _TARGET_FILE="$BUNDLE_PATH/Contents/$2"
    _TARGET_FOLDER=$(dirname "$_TARGET_FILE")

    EchoLine "Deploying file" "$_SOURCE_FILE --> $2"
    mkdir -p "$_TARGET_FOLDER"
    cp "$_SOURCE_FILE" "$_TARGET_FILE"
}

function ComponentDescriptor
{
    _COMPONENT_ID=$1

    # installing outside the "Contents" of bundle
    ComponentFile "conf/$_COMPONENT_ID/component.json" "../component.json"
}

function ComponentLocale
{
    _COMPONENT_ID=$1
    _LOCALE_ID=$2

    EchoLine "Deploying locale" "$_LOCALE_ID"
    cp -r "$SYS_ROOT/$_COMPONENT_ID/deploy/${_LOCALE_ID}.lproj" "$BUNDLE_PATH/Contents/Resources/${_LOCALE_ID}.lproj"
}

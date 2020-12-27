#!/bin/bash

source "$SYS_ROOT/build/deploy/osx/config.sh"

SYSTEM_PLIST="/Library/Symboid/System.plist"

function PackageName
{
    PACKAGE_NAME="$1"
    PACKAGE_WORKING_DIR="$BUILD_DIR/_packages/_${PACKAGE_NAME}_pkg"

    PACKAGE_ROOT="$PACKAGE_WORKING_DIR/root"
    # creating packageing root
    if [ -d "$PACKAGE_ROOT" ]; then
        rm -rf "$PACKAGE_ROOT"
    fi
    mkdir -p "$PACKAGE_ROOT"

    # log file path for packaging
    PACKAGE_BUILD_LOG="$PACKAGE_WORKING_DIR/build.log"
    rm -f "$PACKAGE_BUILD_LOG"

    # directory of scripts
    PACKAGE_SCRIPTS_DIR="$PACKAGE_WORKING_DIR/scripts"
    rm -rf "$PACKAGE_SCRIPTS_DIR"
    mkdir -p "$PACKAGE_SCRIPTS_DIR"

    # path of package to be built
    PACKAGE_PATH="$PACKAGE_DIR/$PACKAGE_NAME.pkg"
    rm -f "$PACKAGE_PATH"
}

function PackagePostInstall
{
    _POSTINSTALL_CMD="$1"

    # post install script of package installation
    _PACKAGE_POSTINSTALL_SCRIPT="$PACKAGE_SCRIPTS_DIR/postinstall"

    if [ ! -f "$_PACKAGE_POSTINSTALL_SCRIPT" ]; then
        echo "#!/bin/bash" >"$_PACKAGE_POSTINSTALL_SCRIPT"
        echo "" >>"$_PACKAGE_POSTINSTALL_SCRIPT"
        chmod +x "$_PACKAGE_POSTINSTALL_SCRIPT"
    fi

    echo "$_POSTINSTALL_CMD" >>"$_PACKAGE_POSTINSTALL_SCRIPT"
    echo "" >>"$_PACKAGE_POSTINSTALL_SCRIPT"

}

function PackageInstallDir
{
    _COMPONENT_INSTALL_DIR="$1"

    PackagePostInstall "defaults write $SYSTEM_PLIST $PACKAGE_NAME -dict-add install_dir \"$_COMPONENT_INSTALL_DIR\""
    PackagePostInstall "chmod +r $SYSTEM_PLIST"
}

function PackageBuild
{
    _PACKAGE_PLIST="$1"
    _PACKAGE_INSTALL_LOCATION="/"

    EchoSep
    EchoLine "Package Build" "$PACKAGE_PATH"
    EchoLine "    --install-location" "$_PACKAGE_INSTALL_LOCATION"
    EchoLine "    --root" "$PACKAGE_ROOT"
    EchoLine "    --scripts" "$PACKAGE_SCRIPTS_DIR"
    EchoLine "    --component-plist" "$_PACKAGE_PLIST"
    pkgbuild --install-location "$_PACKAGE_INSTALL_LOCATION" --root "$PACKAGE_ROOT" --component-plist "$_PACKAGE_PLIST" --scripts "$PACKAGE_SCRIPTS_DIR" "$PACKAGE_PATH" >"$PACKAGE_BUILD_LOG"
}

function PackageArchive
{
    _ARCHIVE_PATH="$PACKAGE_DIR/$PACKAGE_NAME.xar"
    _ARCHIVE_COMPRESSION="gzip"
    rm -rf "$_ARCHIVE_PATH"

    EchoSep
    EchoLine "Archiving via 'xar'" "$PACKAGE_ROOT"
    EchoLine "    --compression" "$_ARCHIVE_COMPRESSION"
    EchoLine "    --distribution" ""
    EchoLine "    -f" "$_ARCHIVE_PATH"

    _SAVE_PWD=$PWD
    cd "$PACKAGE_ROOT"
    xar -c --compression="$_ARCHIVE_COMPRESSION" --distribution -f "$_ARCHIVE_PATH" .
    cd "$_SAVE_PWD"
}

function DistroIncludeComponent
{
    _COMPONENT_NAME="$1"

    if [ "$LAZY_EMBED" == "NO" ] || [ ! -f "$PACKAGE_DIR/$_COMPONENT_NAME.pkg" ]; then
        _COMPONENT_SCRIPT="$SYS_ROOT/$_COMPONENT_NAME/deploy/macos-package.sh"
        #chmod +x "$_COMPONENT_SCRIPT"
        "$_COMPONENT_SCRIPT"
    else
        EchoSep
        echo "     |"
        echo "     |           Using existing package '$_COMPONENT_NAME.pkg'"
        echo "     |"
        EchoSep
    fi
}

function DistroBuild
{
    _DISTRO_COMPONENT="$1"
    _APP_NAME="$2"
    _DISTRO_XML="$SYS_ROOT/$_DISTRO_COMPONENT/deploy/macos-distro.xml"
    _DISTRO_RESOURCES="$PACKAGE_WORKING_DIR/resources"
    _DEV_ID="Developer ID Installer: Robert Torok (PQV5HYMPZJ)"

    # additional files: EULA
    rm -rf "$_DISTRO_RESOURCES"
    mkdir -p "$_DISTRO_RESOURCES"
# switched off until user settings can be accessed
#    cat "$SYS_ROOT/platform/qt/eula_template.html" | sed "s/\[\[APPNAME\]\]/$_APP_NAME/g" > "$_DISTRO_RESOURCES/eula_macos.html"

    EchoSep
    echo "     |"
    echo "     |           Distribution Package"
    echo "     |"
    EchoSep
    EchoLine "Distribution Build" "$PACKAGE_PATH"
    EchoLine "    --distribution" "$_DISTRO_XML"
    EchoLine "    --package-path" "$PACKAGE_DIR"
    EchoLine "    --resources" "$_DISTRO_RESOURCES"
    EchoLine "    --scripts" "$PACKAGE_SCRIPTS_DIR"
    if [[ "$WITH_SIGN" == "YES" ]]; then
        EchoLine "    --sign" "$_DEV_ID"
        productbuild --distribution "$_DISTRO_XML" --package-path "$PACKAGE_DIR" --resources "$_DISTRO_RESOURCES"  --scripts "$PACKAGE_SCRIPTS_DIR" --sign "$_DEV_ID" "$PACKAGE_PATH" >"$PACKAGE_BUILD_LOG"
    else
        productbuild --distribution "$_DISTRO_XML" --package-path "$PACKAGE_DIR" --resources "$_DISTRO_RESOURCES"  --scripts "$PACKAGE_SCRIPTS_DIR" "$PACKAGE_PATH" >"$PACKAGE_BUILD_LOG"
    fi
}

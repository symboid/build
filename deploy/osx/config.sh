#!/bin/bash

source "$SYS_ROOT/build/deploy/osx/echo.sh"

# parsing command line:
for i in "$@"; do
	case $i in
	
		--build-config=*)
		BUILD_CONFIG="${i#*=}"
		shift
		;;
		
		--build-dir=*)
		BUILD_DIR="${i#*=}"
		shift
		;;
		
		--package-dir=*)
		PACKAGE_DIR="${i#*=}"
		shift
		;;
		
		--install-dir=*)
		INSTALL_DIR="${i#*=}"
		shift
		;;
		
		--toolchain=*)
		BUILD_TOOLCHAIN="${i#*=}"
		shift
		;;
		
		--qt-ver=*)
		QT_VER="${i#*=}"
		shift
		;;

        --with-sign)
        WITH_SIGN="YES"
        shift
        ;;

        --compile-update)
        COMPILE_UPDATE="YES"
        shift
        ;;

        --lazy-embed)
        LAZY_EMBED="YES"
        shift
        ;;

		*)
		shift
		;;
	esac
done

# build parameters:
if [[ "$BUILD_CONFIG" == "" ]]; then
    BUILD_CONFIG="debug"
fi
if [[ "$BUILD_TOOLCHAIN" == "" ]]; then
    BUILD_TOOLCHAIN="clang_64"
fi
if [[ "$BUILD_DIR" == "" ]]; then
	BUILD_DIR="$SYS_ROOT/_build/$BUILD_CONFIG-$BUILD_TOOLCHAIN"
fi

# qt paramters:
if [[ "$QT_VER" == "" ]]; then
    QT_VER=5.7
fi
QT_ROOT="$(cd ~/Qt && pwd)"
QT_DIR="$QT_ROOT/$QT_VER/$BUILD_TOOLCHAIN/bin"

# other parameters
if [[ "$PACKAGE_DIR" == "" ]]; then
	PACKAGE_DIR="$SYS_ROOT/packages"
fi
if [[ "$INSTALL_DIR" == "" ]]; then
	INSTALL_DIR="$BUILD_DIR/_install"
fi
if [[ "$WITH_SIGN" == "" ]]; then
    WITH_SIGN="NO"
fi
if [[ "$COMPILE_UPDATE" == "" ]]; then
    COMPILE_UPDATE="NO"
fi
if [[ "$LAZY_EMBED" == "" ]]; then
    LAZY_EMBED="NO"
fi

function ChckDir
{
	DirName=$1
	DirPath=$2
	if [ ! -d "$DirPath" ]; then
		EchoError "$DirName does not exist at '$DirPath'!"
		EchoInfo "Exiting..."
		exit 1
	else
		EchoVar "$DirName" "$DirPath"
	fi
}

function EchoConfig
{
	# reporting build parameters:
	EchoSep
	EchoVar "Build config" "$BUILD_CONFIG"
	EchoVar "Build toolchain" "$BUILD_TOOLCHAIN"
    ChckDir "Build directory" "$BUILD_DIR"

	# reporting qt parameters:
	EchoSep
	EchoVar "Qt Version" "$QT_VER"
	ChckDir "Qt bin directory" "$QT_DIR"

    # reporting other parameters
    EchoSep
    ChckDir "Input directory" "$INSTALL_DIR"
    ChckDir "Package directory" "$PACKAGE_DIR"
}

export BUILD_CONFIG
export BUILD_TOOLCHAIN
export BUILD_DIR

export QT_VER
export PACKAGE_DIR
export INSTALL_DIR

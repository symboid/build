#!/bin/bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

function ComponentApiBegin
{
    COMPONENT_NAME=$1
    BUILD_DIR=$2
    local ARCHIVE_FOLDER=$3
    ARCHIVE_PATH=$ARCHIVE_FOLDER/$COMPONENT_NAME-api.tar
    echo "Creating $ARCHIVE_PATH..."
    printf '' | tar -cf $ARCHIVE_PATH --files-from -
}

function FileApi
{
    local FILE_PATH=$1
    if [ -f $ROOT_DIR/$FILE_PATH ]; then
        echo "Adding file $FILE_PATH"
        tar --append --file=$ARCHIVE_PATH  --directory=$ROOT_DIR $FILE_PATH
    else
        echo "File '$FILE_PATH' cannot be found!"
    fi
}

function FolderApi
{
    local FOLDER_PATH=$1
    local FILE_FILTER=$2
    if [ -d $ROOT_DIR/$FOLDER_PATH ]; then
        echo "Adding files $FILE_FILTER folder $FOLDER_PATH"
        tar --append --file=$ARCHIVE_PATH --directory=$ROOT_DIR $FOLDER_PATH
    else
        echo "Folder '$FOLDER_PATH' cannot be found!"
    fi
}

function ModuleApi
{
    local MODULE_NAME=$1
    FolderApi $COMPONENT_NAME/$MODULE_NAME *.h
#    FolderApi $BUILD_DIR/$COMPONENT_NAME/$MODULE_NAME *.dylib
}

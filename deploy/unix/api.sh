#!/bin/bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

function ComponentApiBegin
{
    COMPONENT_NAME=$1
    REL_BUILD_DIR=$2
    local REL_ARCHIVE_FOLDER=$3
    ARCHIVE_PATH=$ROOT_DIR/$REL_ARCHIVE_FOLDER/$COMPONENT_NAME-api.tar.gz
    ARCHIVE_TMP_DIR=$ROOT_DIR/$REL_ARCHIVE_FOLDER/$COMPONENT_NAME-api
    echo "Creating $ARCHIVE_PATH..."
    rm -rf $ARCHIVE_TMP_DIR
    mkdir -p $ARCHIVE_TMP_DIR
    
    FolderApi $REL_BUILD_DIR/build-install '*'
}

function ComponentApiEnd
{
    cd $ARCHIVE_TMP_DIR
    tar --create --gzip --file=$ARCHIVE_PATH *
    cd $(dirname $ARCHIVE_PATH)
    rm -rf $ARCHIVE_TMP_DIR
}

function FileApi
{
    local FILE_PATH=$1
    if [ -f $ROOT_DIR/$FILE_PATH ]; then
        echo "Adding file $FILE_PATH"
        mkdir -p $(dirname $ARCHIVE_TMP_DIR/$FILE_PATH)
        cp $ROOT_DIR/$FILE_PATH $ARCHIVE_TMP_DIR/$FILE_PATH
    else
        echo "File '$FILE_PATH' cannot be found!"
    fi
}

function FolderApi
{
    local REL_FOLDER_PATH=$1
    local FILE_FILTER=$2
    if [ -d $ROOT_DIR/$REL_FOLDER_PATH ]; then
        echo "Adding files $FILE_FILTER folder in $REL_FOLDER_PATH"
        mkdir -p $ARCHIVE_TMP_DIR/$REL_FOLDER_PATH
        cp -R $ROOT_DIR/$REL_FOLDER_PATH/$FILE_FILTER $ARCHIVE_TMP_DIR/$REL_FOLDER_PATH
    else
        echo "Folder '$ROOT_DIR/$REL_FOLDER_PATH' cannot be found!"
    fi
}

function ModuleApi
{
    local MODULE_NAME=$1
    FolderApi $COMPONENT_NAME/$MODULE_NAME '*.h'
#    FolderApi $REL_BUILD_DIR/$COMPONENT_NAME/$MODULE_NAME '*.so'
#    FolderApi $REL_BUILD_DIR/$COMPONENT_NAME/$MODULE_NAME '*.so.*'
#    FolderApi $REL_BUILD_DIR/$COMPONENT_NAME/$MODULE_NAME '*.dylib'
#    FolderApi $REL_BUILD_DIR/$COMPONENT_NAME/$MODULE_NAME '*.a'
}

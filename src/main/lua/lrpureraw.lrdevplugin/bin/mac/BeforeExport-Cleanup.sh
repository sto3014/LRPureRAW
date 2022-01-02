#!/usr/bin/env bash
# Will be executed before Lightroom starts to export the photos
# If this script returns an error (i.e. exit 1) the photos are not exported.
# If an error is returned Lightroom looks for a file named $ERROR and displays it's content
# in a dialog
# The following parameters will be passed to this script:
# 1. Error file - Error message which should be displayed in Lightroom
# 2. Source directory - if more than one, only the first one is passed.
# 3. Target directory
# 4. Count photos which will be exported.
# 5+ Photo(s) - Name only, without path but with suffix: ANY-PHOTO.NEF
ERROR_FILE=$1
SOURCE_DIR=$2
TARGET_DIR=$3
PHOTOS_COUNT=$4

if [ -d $TARGET_DIR ];
then
  rm -f $TARGET_DIR/*.* 2>$ERROR_FILE
  if [ -d $TARGET_DIR/DxO ];
  then
    unlink $TARGET_DIR/DxO 2>$ERROR_FILE
  fi
else
  echo Export directory $TARGET_DIR not found.>$ERROR_FILE
  exit 1
fi


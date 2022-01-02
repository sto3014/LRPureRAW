#!/usr/bin/env bash
# Will be executed after Lightroom has successfully exported all photos.
# If this script returns an error (i.e. exit 1) Lightroom displays an error message
# Lightroom looks for a file named $ERROR_FILE and displays it's content in this dialog
# The following parameters will be passed to this script:
# 1. Error file - Error message which should be displayed in Lightroom
# 2. Source directory - if more than one, only the first one is passed.
# 3. Target directory
# 4. Count exported images
# 5+ Image(s) - Name only, without path but with suffix: ANY-PHOTO.DNG
ERROR_FILE=$1
SOURCE_DIR=$2
TARGET_DIR=$3
PHOTOS_COUNT=$4

if [ -d $TARGET_DIR ];
then
  if [ -d $SOURCE_DIR ];
  then
    ln -s "$TARGET_DIR" "$TARGET_DIR/DxO" 2>$ERROR_FILE
  else
     echo Source directory $SOURCE_DIR not found.>$ERROR_FILE
     exit 2
  fi
else
  echo Export directory $SOURCE_DIR not found.>$ERROR_FILE
  exit 1
fi


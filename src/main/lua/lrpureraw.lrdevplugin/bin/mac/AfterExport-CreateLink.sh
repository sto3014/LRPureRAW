#!/usr/bin/env bash
# Will be executed after Lightroom has successfully exported all photos.
# If this script returns an error (i.e. exit 1) Lightroom displays an error message
# Lightroom looks for a file named $ERROR_FILE and displays it's content in this dialog
# The following parameters will be passed to this script:
# 1. Error file - Error message which should be displayed in Lightroom
# 2. Source directory - if more than one, only the first one is passed.
# 3. Target directory
# 4. Plugin Path
# 5. Count exported images
# 6+ Image(s) - Name only, without path but with suffix: ANY-PHOTO.DNG
ERROR_FILE=$1
SOURCE_DIR=$2
TARGET_DIR=$3
PLUGIN_PATH=$4
IMAGES_COUNT=$5
shift 5
IMAGES=$*
#
LOG_FILE=$SOURCE_DIR/LRPureRaw.log
#
echo After export start>>"$LOG_FILE"
echo ERROR_FILE = $ERROR_FILE>>"$LOG_FILE"
echo SOURCE_DIR = $SOURCE_DIR>>"$LOG_FILE"
echo TARGET_DIR = $TARGET_DIR>>"$LOG_FILE"
echo PLUGIN_PATH= $PLUGIN_PATH>>"$LOG_FILE"
echo IMAGES_COUNT = $IMAGES_COUNT>>"$LOG_FILE"
echo IMAGES = $IMAGES>>"$LOG_FILE"
#
if [ -d "$TARGET_DIR" ];
then
  if [ -d "$SOURCE_DIR" ];
  then
    echo Create link: ln -s "$SOURCE_DIR" "$TARGET_DIR/DxO">>"$LOG_FILE"
    ln -s "$SOURCE_DIR" "$TARGET_DIR/DxO" 2>"$ERROR_FILE"
  else
     echo Source directory $SOURCE_DIR not found.>"$ERROR_FILE"
     exit 2
  fi
else
  echo Export directory $TARGET_DIR not found.>"$ERROR_FILE"
  exit 1
fi
echo After export end>>"$LOG_FILE"


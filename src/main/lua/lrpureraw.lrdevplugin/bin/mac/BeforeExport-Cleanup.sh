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
# 5. Plugin Path
# 6+ Photo(s) - Name only, without path but with suffix: ANY-PHOTO.NEF
ERROR_FILE=$1
SOURCE_DIR=$2
TARGET_DIR=$3
PHOTOS_COUNT=$4
PLUGIN_PATH=$5
shift 5
PHOTOS=$*
#
LOG_FILE=$SOURCE_DIR/LRPureRaw.log
#
echo ----------------------------------------------------------------------------------------------->>"$LOG_FILE"
date>>"$LOG_FILE"
echo Before export start>>"$LOG_FILE"
echo ERROR_FILE = $ERROR_FILE>>"$LOG_FILE"
echo SOURCE_DIR = $SOURCE_DIR>>"$LOG_FILE"
echo TARGET_DIR = $TARGET_DIR>>"$LOG_FILE"
echo PHOTOS_COUNT = $PHOTOS_COUNT>>"$LOG_FILE"
echo PLUGIN_PATH= $PLUGIN_PATH>>"$LOG_FILE"
echo PHOTOS = $PHOTOS>>"$LOG_FILE"
#
if [ ! -d "$TARGET_DIR" ];
then
  md "$TARGET_DIR"
fi
if [ -d "$TARGET_DIR" ];
then
  if [ -f "$TARGET_DIR/LRPureRaw.log" ];
  then
    echo TARGET_DIR is equal to SOURCE_DIR. Cleanup is skipped.>>"$LOG_FILE"
  else
    echo Remove files from TARGET_DIR:>>"$LOG_FILE"
    ls "$TARGET_DIR/*.*">>"$LOG_FILE"
    rm -f "$TARGET_DIR/*.*" 2>$ERROR_FILE
    if [ -L "$TARGET_DIR/DxO" ];
    then
      echo unlink DxO>>"$LOG_FILE"
      unlink "$TARGET_DIR/DxO" 2>$ERROR_FILE
    fi
  fi
else
  echo Export directory $TARGET_DIR not found.>$ERROR_FILE
  exit 1
fi
echo Before export end>>"$LOG_FILE"



#!/usr/bin/env bash
cd "$(dirname "$0")"
export SCRIPT_DIR="$(pwd)"
export PACKAGE_NAME=LRPureRAW
export TARGET_DIR_MAC="$SCRIPT_DIR/target/mac/Library/Application Support/Adobe/Lightroom"
export TARGET_DIR_WIN="$SCRIPT_DIR/target/win/AppData/Roaming/Adobe/Lightroom"
export SOURCE_DIR=$SCRIPT_DIR/src/main/lua/$PACKAGE_NAME.lrdevplugin
export RESOURCE_DIR=$SCRIPT_DIR/res
export VERSION=1.5.0.0
#
# mac
#
if [ -d  "$TARGET_DIR_MAC" ]; then
   rm -d -f -r "$TARGET_DIR_MAC"
fi
if [ -f  $SCRIPT_DIR/target/$PACKAGE_NAME$VERSION"_mac.zip" ]; then
   rm $SCRIPT_DIR/target/$PACKAGE_NAME$VERSION"_mac.zip"
fi

mkdir -p "$TARGET_DIR_MAC/Modules/$PACKAGE_NAME.lrplugin"
# copy dev

cp -R $SOURCE_DIR/* "$TARGET_DIR_MAC/Modules/$PACKAGE_NAME.lrplugin"
# compile
cd "$TARGET_DIR_MAC/Modules/$PACKAGE_NAME.lrplugin"
for f in *.lua
do
 luac5.1 -o $f $f
done
cd $RESOURCE_DIR
cp -R * "$TARGET_DIR_MAC"
cd "$SCRIPT_DIR/target/mac"
zip -q -r ../$PACKAGE_NAME$VERSION"_mac.zip" Library
#
# win
#
if [ -d  "$TARGET_DIR_WIN" ]; then
   rm -d -f -r "$TARGET_DIR_WIN"
fi
if [ -f  $SCRIPT_DIR/target/$PACKAGE_NAME$VERSION"_win.zip" ]; then
   rm $SCRIPT_DIR/target/$PACKAGE_NAME$VERSION"_win.zip"
fi
mkdir -p "$TARGET_DIR_WIN/Modules/$PACKAGE_NAME.lrplugin"
# copy dev

cp -R $SOURCE_DIR/* "$TARGET_DIR_WIN/Modules/$PACKAGE_NAME.lrplugin"
# compile
cd "$TARGET_DIR_WIN/Modules/$PACKAGE_NAME.lrplugin"
for f in *.lua
do
 luac5.1 -o $f $f
done
cd $RESOURCE_DIR
cp -R * "$TARGET_DIR_WIN"
cd $SCRIPT_DIR/target/win
zip -q -r ../$PACKAGE_NAME$VERSION"_win.zip" AppData
#
cd $SCRIPT_DIR/target
mkdir $PACKAGE_NAME$VERSION
mv $PACKAGE_NAME$VERSION"_win.zip" $PACKAGE_NAME$VERSION/
mv $PACKAGE_NAME$VERSION"_mac.zip" $PACKAGE_NAME$VERSION/
cp -R ../Install-Plugin.app $PACKAGE_NAME$VERSION/
cp ../Install-Plugin.bat $PACKAGE_NAME$VERSION/
zip -q -r $PACKAGE_NAME$VERSION".zip" $PACKAGE_NAME$VERSION
rm -d -f -r $PACKAGE_NAME$VERSION
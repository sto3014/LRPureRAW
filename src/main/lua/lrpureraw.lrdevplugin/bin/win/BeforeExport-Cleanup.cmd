:: Will be executed before Lightroom starts to export the photos
:: If this script returns an error (i.e. exit 1) the photos are not exported.
:: If an error is returned Lightroom looks for a file named %ERROR_FILE% and displays it's content
:: in a dialog
:: The following parameters will be passed to this script:
:: 1. Error file - Error message which should be displayed in Lightroom
:: 2. Source directory - if more than one, only the first one is passed.
:: 3. Target directory
:: 4. Count photos which will be exported.
:: 5+ Photo(s) - Name only, without path but with suffix: ANY-PHOTO.NEF
set ERROR_FILE=%1
set SOURCE_DIR=%2
set TARGET_DIR=%3
set PHOTOS_COUNT=%4
set CMD_LINE=%*
::
set LOG_FILE=%SOURCE_DIR%\LRPureRaw.log
::
echo ----------------------------------------------------------------------------------------------->>%LOG_FILE%
date /t>>%LOG_FILE%
time /t>>%LOG_FILE%
echo Before export start>>%LOG_FILE%
echo ERROR_FILE = %ERROR_FILE%>>%LOG_FILE%
echo SOURCE_DIR = %SOURCE_DIR%>>%LOG_FILE%
echo TARGET_DIR = %TARGET_DIR%>>%LOG_FILE%
echo PHOTOS_COUNT = %PHOTOS_COUNT% >>%LOG_FILE%
echo CMD_LINE = %CMD_LINE%>>%LOG_FILE%
::
if exist %TARGET_DIR% (
  if exist %TARGET_DIR%\LRPureRaw.log (
    echo TARGET_DIR is equal to SOURCE_DIR. Cleanup is skipped.>>%LOG_FILE%
  ) else (
    echo Remove files from TARGET_DIR:>>%LOG_FILE%
    dir /b  %TARGET_DIR%\*.*>>%LOG_FILE%
    del /Q %TARGET_DIR%\*.* 2>%ERROR_FILE%
    if exist %TARGET_DIR%\DxO (
      echo unlink DxO>>%LOG_FILE%
      del %TARGET_DIR\DxO% 2>%ERROR_FILE%
    )
  )
) else (
  echo Export directory %TARGET_DIR% not found.>%ERROR_FILE%
  exit 1
)
echo Before export end>>%LOG_FILE%



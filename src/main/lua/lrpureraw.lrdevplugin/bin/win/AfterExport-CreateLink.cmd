:: Will be executed after Lightroom has successfully exported all photos.
:: If this script returns an error (i.e. exit 1) Lightroom displays an error message
:: Lightroom looks for a file named %ERROR_FILE% and displays it's content in this dialog
:: The following parameters will be passed to this script:
:: 1. Error file - Error message which should be displayed in Lightroom
:: 2. Source directory - if more than one, only the first one is passed.
:: 3. Target directory
:: 4. Count exported images
:: 5+ Image(s) - Name only, without path but with suffix: ANY-PHOTO.DNG
set ERROR_FILE=%1
set SOURCE_DIR=%2
set TARGET_DIR=%3
set IMAGES_COUNT=%4
::shift 4
set CMD_LINE=%*
::
set LOG_FILE=%SOURCE_DIR%\LRPureRaw.log
::
echo After export start>>%LOG_FILE%
echo ERROR_FILE = %ERROR_FILE%>>%LOG_FILE%
echo SOURCE_DIR = %SOURCE_DIR%>>%LOG_FILE%
echo TARGET_DIR = %TARGET_DIR%>>%LOG_FILE%
echo IMAGES_COUNT = %IMAGES_COUNT% >>%LOG_FILE%
echo CMD_LINE = %CMD_LINE%>>%LOG_FILE%
::
if exist %TARGET_DIR% (
  if exist %SOURCE_DIR% (
    echo Create link: mklink /D %TARGET_DIR%\DxO %SOURCE_DIR%>>%LOG_FILE%
    mklink /d  %TARGET_DIR%\DxO %SOURCE_DIR% 2>%ERROR_FILE%
  ) else (
     echo Source directory %SOURCE_DIR% not found. >%ERROR_FILE%
     exit 2
  )
) else (
  echo Export directory %TARGET_DIR% not found.>%ERROR_FILE%
  exit 1
)
echo After export end>>%LOG_FILE%

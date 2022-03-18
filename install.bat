@echo off
set SCRIPT_DIR=%~dp0
set VERSION=1.5.2.0
::
powershell -command "Expand-Archive -Force '%SCRIPT_DIR%target\LRPureRAW%VERSION%_win.zip' '%HOMEDRIVE%%HOMEPATH%'"
pause


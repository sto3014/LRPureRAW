@echo off
set SCRIPT_DIR=%~dp0
set VERSION=1.5.0.0
::
powershell -command "Expand-Archive -Force '%SCRIPT_DIR%LRPureRAW%VERSION%_win.zip' '%HOMEDRIVE%%HOMEPATH%'"
pause


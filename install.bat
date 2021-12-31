@echo off
set SCRIPT_DIR=%~dp0
set VERSION=1.0.2.3
::
powershell -command "Expand-Archive -Force '%SCRIPT_DIR%target\LRPureRAW%VERSION%_win.zip' '%HOMEDRIVE%%HOMEPATH%'"
pause


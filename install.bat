@echo off
set SCRIPT_DIR=%~dp0
set VERSION=1.0.2.1
::
cd /d %SCRIPT_DIR%target
powershell -command "Expand-Archive -Force 'LRPureRAW%VERSION%_win.zip' '%HOMEDRIVE%%HOMEPATH%'"


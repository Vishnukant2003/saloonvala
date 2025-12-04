@echo off
REM Wrapper script to help Flutter execute gradlew.bat
cd /d "%~dp0"
call gradlew.bat %*


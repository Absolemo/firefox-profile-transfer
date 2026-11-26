@echo off
setlocal
python -u "%~dp0transfer.py"
exit /b %errorlevel%

@echo off
title Scalora Web Server & CMS Studio
echo ====================================================
echo   Starting Scalora Web Server & CMS Studio...
echo ====================================================
echo.
echo Opening http://localhost:3000 in your browser...
start http://localhost:3000
echo.
echo Starting server on port 3000...
powershell -ExecutionPolicy Bypass -File "%~dp0server.ps1" -Port 3000
pause

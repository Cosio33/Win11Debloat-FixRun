@echo off
setlocal EnableDelayedExpansion

:: Set Windows Terminal installation paths. (Default and Scoop installation)
set "wtDefaultPath=%LOCALAPPDATA%\Microsoft\WindowsApps\wt.exe"
set "wtScoopPath=%USERPROFILE%\scoop\apps\windows-terminal\current\wt.exe"
set "logFile=%~dp0Logs\Win11Debloat-Run.log"

:: Ensure Logs folder exists
if not exist "%~dp0Logs" mkdir "%~dp0Logs"

:: Determine which terminal exists
if exist "%wtDefaultPath%" (
    set "wtPath=%wtDefaultPath%"
) else if exist "%wtScoopPath%" (
    set "wtPath=%wtScoopPath%"
) else (
    echo Windows Terminal not found. Using default PowerShell instead.
    set "wtPath="
)

:: ==================================================================
:: FIX: Resolve to short (8.3) path to avoid spaces in the directory name
:: The original code used %~dp0Win11Debloat.ps1 directly, but the path
:: contained double spaces ("Codigos Run  Colab_n8n__local") which broke
:: the nested quote parsing across Batch -> PowerShell -> Start-Process.
:: The 8.3 short path (e.g. C:\Users\WIN11D~1.PS1) has no
:: spaces, so it survives all quoting layers without splitting.
:: ==================================================================
for %%I in ("%~dp0Win11Debloat.ps1") do set "SCRIPT_PATH=%%~fsI"

if defined wtPath (
    call :Log Launching Win11Debloat.ps1 with Windows Terminal...
    :: FIX: Replaced %~dp0Win11Debloat.ps1 with %SCRIPT_PATH% (no spaces)
    PowerShell -Command "Start-Process -FilePath '%wtPath%' -ArgumentList 'PowerShell -NoProfile -ExecutionPolicy Bypass -File ""%SCRIPT_PATH%""' -Verb RunAs" >> "%logFile%" || call :Error "PowerShell command failed"
    call :Log Script execution passed successfully to Win11Debloat.ps1
) else (
    echo Windows Terminal not found. Using default PowerShell instead...
    call :Log Windows Terminal not found. Using default PowerShell to launch Win11Debloat.ps1...
    :: FIX: Replaced %~dp0Win11Debloat.ps1 with %SCRIPT_PATH% (no spaces)
    PowerShell -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%SCRIPT_PATH%""' -Verb RunAs}" >> "%logFile%" || call :Error "PowerShell command failed"
    call :Log Script execution passed successfully to Win11Debloat.ps1
)

echo.
echo If you need further assistance, please open an issue at:
echo https://github.com/Raphire/Win11Debloat/issues
goto :EOF

:: Logging Function
:Log
echo %* >> "%logFile%"
goto :EOF
:: Error Handler
:Error
echo ERROR: %*
echo Logged in %logFile%
pause
goto :EOF


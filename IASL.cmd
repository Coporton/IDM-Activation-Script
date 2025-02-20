@set iasver=1.9
@echo off
setlocal enabledelayedexpansion

::============================================================================
:: IDM Activation Script (IAS)
::============================================================================
:: Homepages: https://github.com/Coporton/IDM-Activation-Script
::            https://coporton.com/idm-activation-script
:: Email: coporton@protonmail.com
::============================================================================

:: Set console window size
mode con: cols=125 lines=40
title IDM Activation Script (IAS) %iasver%

:: Self-elevation code
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
)

:: Set script directories
set "SCRIPT_DIR=%~dp0"
set "SRC_DIR=%SCRIPT_DIR%src\"

:: Set the paths for the .bin files
set "DATA_FILE=%SRC_DIR%data.bin"
set "REGISTRY_FILE=%SRC_DIR%Registry.bin"
set "EXTENSIONS_FILE=%SRC_DIR%extensions.bin"

:: Define color codes for output
set "RESET=[0m"
set "GREEN=[32m"
set "RED=[31m"
set "YELLOW=[33m"

:: Check for administrator rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED% You need to run this script as Administrator. Please right-click the script and choose "Run as Administrator".%RESET%
    pause
    exit /b
)

:: Now running with admin privileges
echo %GREEN% Running with administrative privileges...%RESET%
echo.

:: Display ASCII art
chcp 65001 >nul

:: Define the path to your ASCII art file
set "ascii_file=%SRC_DIR%banner_art.txt"

:: Define the number of spaces for padding
set "padding=   "

:: Loop through each line in the ASCII art file and add spaces
for /f "delims=" %%i in (%ascii_file%) do (
    echo !padding!%%i
)
echo.
echo.

:: Check IDM installation directory from the registry
for /f "tokens=2*" %%A in ('reg query "HKCU\SOFTWARE\DownloadManager" /v ExePath 2^>nul') do (
    set "DEFAULT_DEST_DIR=%%B"
)

:: Remove "IDMan.exe" from the path if found
if defined DEFAULT_DEST_DIR (
    for %%A in ("%DEFAULT_DEST_DIR%") do set "DEFAULT_DEST_DIR=%%~dpA"
    timeout /t 1 >nul
    echo %GREEN% Internet Download Manager found.%RESET%
) else (
    setlocal disabledelayedexpansion
    echo %RED% Error: Unable to find Internet Download Manager installation directory.%RESET%
    echo %YELLOW% Please ensure Internet Download Manager is installed correctly. Then run this script again. Thank you!!!%RESET%
    echo.
    echo %GREEN% You can download the latest version from here: https://www.internetdownloadmanager.com/download.html%RESET%
    echo.
    echo  Press any key to close . . .
    pause >nul
    exit
)

:: Output the IDM installed directory and version
timeout /t 1 >nul
echo %GREEN% Installed Directory: %DEFAULT_DEST_DIR%%RESET%

:: Check IDM version from the registry
for /f "tokens=2*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Internet Download Manager" /v DisplayVersion 2^>nul') do (
    set "IDM_VERSION=%%B"
)

if not defined IDM_VERSION (
    for /f "tokens=2*" %%A in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Internet Download Manager" /v DisplayVersion 2^>nul') do (
        set "IDM_VERSION=%%B"
    )
)

:: If the IDM version was not found, exit with error
if not defined IDM_VERSION (
    echo %RED% Error: Unable to retrieve the installed Internet Download Manager version. Please ensure Internet Download Manager is installed correctly.%RESET%
    pause
    exit /b
)

timeout /t 1 >nul
echo %YELLOW% Installed Internet Download Manager Version: %IDM_VERSION%%RESET%
timeout /t 1 >nul

:: Prompt for user input
:menu
echo.
echo %GREEN%  =============================================
echo %GREEN%  :                                           :
echo %GREEN%  :  [1] Activate Internet Download Manager   :
echo %GREEN%  :  [2] Extra FileTypes Extensions           :
echo %GREEN%  :  [3] Exit                                 :
echo %GREEN%  :                                           :
echo %GREEN%  =============================================%RESET%
echo.
timeout /t 1 >nul

set /p choice= " Choose an option (1, 2, or 3): "

:: Handle user choice
if "%choice%"=="1" (
    call :verifyFile "%DATA_FILE%" "data.bin"
    call :verifyFile "%REGISTRY_FILE%" "Registry.bin"
    call :verifyDestinationDirectory

    :: Terminate IDMan.exe process if running
    call :terminateProcess "IDMan.exe"

    echo %GREEN% Internet Download Manager activated successfully!%RESET%
    regedit /s "%REGISTRY_FILE%"
    copy "%DATA_FILE%" "%DEFAULT_DEST_DIR%\IDMan.exe" >nul
    if %errorlevel% neq 0 (
        echo %RED% Error: Failed to copy the file to the destination directory.%RESET%
    )
    echo.
    echo  Press any key to close . . .
    pause >nul
    goto :eof
) else if "%choice%"=="2" (
    call :verifyFile "%REGISTRY_FILE%" "Registry.bin"
    echo %GREEN% Extra FileTypes Extensions updated successfully!%RESET%
    regedit /s "%EXTENSIONS_FILE%"
    echo.
    echo  Press any key to close . . .
    pause >nul
    goto :eof
) else if "%choice%"=="3" (
    setlocal disabledelayedexpansion
    echo %GREEN% Exiting the script. Thank you!!!%RESET%
    timeout /t 2 >nul
    exit
) else (
    echo %RED% Invalid choice. Please run the script again and select option 1, 2, or 3.%RESET%
    goto :menu
)

:: Wait for user to press a key before closing
echo.
echo  Press any key to close . . .
pause >nul
endlocal
exit /b

:: Subroutine to verify file existence
:verifyFile
    echo  Verifying source file "%~2"...
    if not exist "%~1" (
        echo %RED% Source file "%~2" not found. Please verify.%RESET%
        pause
        exit /b
    )
    echo  Source file "%~2" exists.
    exit /b

:: Subroutine to verify destination directory
:verifyDestinationDirectory
    echo  Verifying destination directory...
    if not exist "%DEFAULT_DEST_DIR%" (
        echo %RED% Destination directory not found. Please verify the path.%RESET%
        pause
        exit /b
    )
    echo  Destination directory exists.
    exit /b

:: Subroutine to terminate a process
:terminateProcess
    echo  Terminating %~1 if running...
    @taskkill /F /IM %~1 >nul 2>&1
    if %errorlevel% neq 0 (
        echo %RED% Failed to terminate %~1 or process not found.%RESET%
    ) else (
        echo  %GREEN%%~1 process terminated.%RESET%
    )
    exit /b
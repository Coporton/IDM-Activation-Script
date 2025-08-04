@echo off
setlocal EnableDelayedExpansion
set iasver=2.5.6

::============================================================================
:: Coporton IDM Activation Script (Activator + Registry Cleaner)
::============================================================================

mode con: cols=120 lines=40
title Coporton IDM Activation Script (Activator + Registry Cleaner) v%iasver%

:: Ensure Admin Privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
)

:: Set paths
set "SCRIPT_DIR=%~dp0"
set "SRC_DIR=%SCRIPT_DIR%src\"
set "DATA_FILE=%SRC_DIR%data.bin"
set "DATAHLP_FILE=%SRC_DIR%dataHlp.bin"
set "REGISTRY_FILE=%SRC_DIR%registry.bin"
set "EXTENSIONS_FILE=%SRC_DIR%extensions.bin"
set "ascii_file=%SRC_DIR%banner_art.txt"

:: Temp files
set "tempfile_html=%temp%\idm_news.html"

:: Output colors
set "RESET=[0m"
set "GREEN=[32m"
set "RED=[31m"
set "YELLOW=[33m"

chcp 65001 >nul

:: Define the number of spaces for padding
set "padding=   "

:: Loop through each line in the ASCII art file and add spaces
for /f "delims=" %%i in (%ascii_file%) do (
    echo !padding!%%i
)

:: Internet connection check
call :check_internet

echo Getting the latest version information...
curl -s "https://www.internetdownloadmanager.com/news.html" -o "%tempfile_html%"
set "online_version="

:: Find the first occurrence of the version
for /f "tokens=1* delims=<>" %%a in ('findstr /i "<H3>What's new in version" "%tempfile_html%" ^| findstr /r /c:"Build [0-9]*"') do (
    set "line=%%b"
    set "line=!line:What's new in version =!"
    set "line=!line:</H3>=!"
    set "online_version=!line!"
    goto :got_version
)

:got_version
if not defined online_version (
    echo %RED% Failed to retrieve online version.%RESET%
    exit /b
)

echo %GREEN%Latest version: !online_version! %RESET%

:: Scan the online version and generate the download code
for /f "tokens=1,2,4 delims=. " %%a in ("!online_version!") do (
    set "o_major=%%a"
    set "o_minor=%%b"
    set "o_build=%%c"
)

set "downloadcode=!o_major!!o_minor!build!o_build!"
set "downloadurl=https://mirror2.internetdownloadmanager.com/idman%downloadcode%.exe"

:: Check installed version
echo Checking installed version...
set "installed="
for /f "tokens=3" %%a in ('reg query "HKCU\Software\DownloadManager" /v idmvers 2^>nul') do set "installed=%%a"
if not defined installed (
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Internet Download Manager" /v Version 2^>nul') do set "installed=%%a"
)

timeout /t 1 >nul
if defined installed (
    set "installed=!installed:v=!"
    set "installed=!installed:Full=!"
    set "installed=!installed: =!"
    set "installed=!installed:b= Build !"
    echo %GREEN%Internet Download Manager found. Installed version: !installed!%RESET%
) else (
    setlocal disabledelayedexpansion
    echo %RED%Error: Unable to find Internet Download Manager installation directory.%RESET%
    echo %YELLOW%Please ensure Internet Download Manager is installed correctly. Then run this script again.%RESET%
    echo.
    echo %GREEN%You can download the latest version from here: %downloadurl%%RESET%
    echo.
    echo Loading Menu . . .
    goto :menu
)

:: Parse installed version
for /f "tokens=1,2,4 delims=. " %%a in ("!installed!") do (
    set "i_major=%%a"
    set "i_minor=%%b"
    set "i_build=%%c"
)

:: Compare versions
set /a i_total = 10000 * !i_major! + 100 * !i_minor! + !i_build!
set /a o_total = 10000 * !o_major! + 100 * !o_minor! + !o_build!

echo.
if !i_total! GEQ !o_total! (
    echo %GREEN%You already have the latest version of Internet Download Manager.%RESET%
) else (
    echo %YELLOW%A newer version of IDM is available!%RESET%
    echo %GREEN%Please update to the latest version: !online_version!%RESET%
)
echo.

:: Cleaning
del "%tempfile_html%" >nul 2>&1
del "%temp%\latest_release.json" >nul 2>&1

:: Main menu
:menu
timeout /t 1 >nul
echo.
echo %GREEN%  ======================================================
echo %GREEN%    :                                                :
echo %GREEN%    :  [1] Download Latest IDM Version               :
echo %GREEN%    :  [2] Activate Internet Download Manager        :
echo %GREEN%    :  [3] Extra FileTypes Extensions                :
echo %GREEN%    :  [4] Do Everything (2 + 3)                     :
echo %RED%    :  [5] Completely Remove IDM Registry Entries    :
echo %GREEN%    :  [6] Exit                                      :
echo %GREEN%    :                                                :
echo %GREEN%  ======================================================%RESET%
echo.
set "choice="
set /p choice=" Choose an option (1-6): "
if not defined choice goto :menu

if "%choice%"=="1" call :DownloadLatestIDM & goto :menu
if "%choice%"=="2" call :ActivateIDM & goto :menu
if "%choice%"=="3" call :AddExtensions & goto :menu
if "%choice%"=="4" call :DoEverything & goto :menu
if "%choice%"=="5" call :CleanRegistry & goto :menu
if "%choice%"=="6" call :quit

echo %RED% Invalid option. Please enter a number from 1 to 6.%RESET%
timeout /t 2 >nul
goto :menu

::----------------------
:DownloadLatestIDM
call :check_internet

if /i "!online_version!"=="Unknown" (
    echo %RED% No version info available. Try checking for updates first.%RESET%
    exit /b
)
echo %GREEN%Opening your browser to download the latest IDM...%RESET%
echo.
start "" "%downloadurl%"
echo %YELLOW%If your download does not start automatically, copy and paste this URL into your browser: %RESET%
echo %YELLOW%%downloadurl% %RESET%
echo.
exit /b

::----------------------
:: Internet check subroutine
:check_internet
echo Checking internet connectivity...
ping -n 1 google.com >nul 2>&1
if errorlevel 1 (
    echo %RED%[!] Internet not available. Please check your connection.%RESET%
    pause
    exit /b
) else (
    echo %GREEN%[✓] Internet connection is active.%RESET%
)
exit /b

::----------------------
:ActivateIDM
:: Check IDM installation directory from the registry

for /f "tokens=2*" %%A in ('reg query "HKCU\SOFTWARE\DownloadManager" /v ExePath 2^>nul') do (
    set "DEFAULT_DEST_DIR=%%B"
)

if defined DEFAULT_DEST_DIR (
    for %%A in ("%DEFAULT_DEST_DIR%") do set "DEFAULT_DEST_DIR=%%~dpA"
    timeout /t 1 >nul
) else (
    setlocal disabledelayedexpansion
    echo %RED% Error: Unable to find IDM installation directory.%RESET%
    echo %YELLOW% Please install IDM and try again.%RESET%
    echo %GREEN%Download it here: !downloadurl!%RESET%
    pause
    exit /b
)

call :verifyFile "%DATA_FILE%" "data.bin"
call :verifyFile "%DATAHLP_FILE%" "dataHlp.bin"
call :verifyFile "%REGISTRY_FILE%" "registry.bin"
call :verifyDestinationDirectory
call :terminateProcess "IDMan.exe"
regedit /s "%REGISTRY_FILE%"
copy "%DATA_FILE%" "%DEFAULT_DEST_DIR%IDMan.exe" >nul
copy "%DATAHLP_FILE%" "%DEFAULT_DEST_DIR%IDMGrHlp.exe" >nul

:: ——— PROMPT FOR USER INPUT ———
echo.
SET /P FName=Enter your First Name: 
SET /P LName=Enter your Last Name: 
echo.

:: ——— FALLBACK TO DEFAULTS IF BLANK ———
if "%FName%"=="" set "FName=Coporton"
if "%LName%"=="" set "LName=WorkStation"

:: Re-register user info using the values the user just entered
reg add "HKCU\SOFTWARE\DownloadManager" /v FName /t REG_SZ /d "%FName%" /f >nul
reg add "HKCU\SOFTWARE\DownloadManager" /v LName /t REG_SZ /d "%LName%" /f >nul

echo %GREEN%Internet Download Manager Activated.%RESET%
exit /b

:verifyFile
if not exist "%~1" echo %RED% Missing: %~2%RESET% & pause & exit /b
exit /b

:verifyDestinationDirectory
if not exist "%DEFAULT_DEST_DIR%" echo %RED% Destination not found.%RESET% & pause & exit /b
exit /b

:terminateProcess
taskkill /F /IM %~1 >nul 2>&1
exit /b

::----------------------
:AddExtensions
regedit /s "%EXTENSIONS_FILE%"
echo %GREEN%Extra FileTypes Extensions updated.%RESET%
exit /b

::----------------------
:DoEverything
call :ActivateIDM
call :AddExtensions
echo.
echo [%DATE% %TIME%] Activated IDM >> %SCRIPT_DIR%log.txt
echo %GREEN%Congratulations. All tasks completed successfully!%RESET%
echo.
exit /b

::----------------------
:askReturn
set /p back=" Return to main menu? (Y/N): "
if not defined back goto :askReturn
if /i "%back%"=="Y" set "choice=" & goto :menu
if /i "%back%"=="N" call :quit

echo %RED% Invalid input. Please type Y or N.%RESET%
goto :askReturn


::----------------------
:CleanRegistry
:: Full registry cleaning logic

call :terminateProcess "IDMan.exe"
echo %YELLOW% Cleaning IDM-related Registry Entries...%RESET%

for %%k in (
    "HKLM\Software\Classes\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKLM\Software\Classes\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKLM\Software\Classes\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKLM\Software\Classes\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKLM\Software\Classes\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKLM\Software\Classes\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKLM\Software\Classes\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKLM\Software\Classes\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKLM\Software\Classes\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKCU\Software\Classes\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKCU\Software\Classes\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKCU\Software\Classes\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKCU\Software\Classes\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKCU\Software\Classes\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKCU\Software\Classes\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKCU\Software\Classes\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKCU\Software\Classes\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKCU\Software\Classes\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKLM\Software\Internet Download Manager"
    "HKLM\Software\Wow6432Node\Internet Download Manager"
    "HKCU\Software\Download Manager"
    "HKCU\Software\Wow6432Node\Download Manager"
) do reg delete %%k /f >nul 2>&1

:: Clean license values
for %%v in ("FName" "LName" "Email" "Serial" "CheckUpdtVM" "tvfrdt" "LstCheck" "scansk" "idmvers") do (
    reg delete "HKCU\Software\DownloadManager" /v %%v /f >nul 2>&1
)

echo %GREEN%Registry cleanup completed.%RESET%
exit /b

::----------------------
:quit
echo.
echo %GREEN%Thank you for using Coporton IDM Activation Script. Have a great day... %RESET%
timeout /t 2 >nul
exit
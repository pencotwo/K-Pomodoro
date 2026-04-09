@echo off
setlocal enabledelayedexpansion

echo === K-Pomodoro SourceForge Upload Script ===
echo.

REM ============================================================
REM  Configuration -- update the variables below as needed
REM ============================================================
set SF_USER=hartman-hsieh
set SF_PROJECT=k-pomodoro
set CSPROJ_FILE=PomodoroApp2.csproj
set SF_JSON=SourceForge.json
REM ============================================================

REM ============================================================
REM  Read version from .csproj
REM ============================================================
set SF_VERSION=
for /f "tokens=3 delims=<>" %%A in ('findstr /r "<Version>" "%CSPROJ_FILE%"') do (
    set SF_VERSION=%%A
)
if "%SF_VERSION%"=="" (
    echo [Error] Could not read Version from %CSPROJ_FILE%.
    pause
    exit /b 1
)
echo Source code version: %SF_VERSION%

set INSTALLER_FILE=installer_output\K-Pomodoro_Setup_v%SF_VERSION%.exe
set SF_REMOTE_PATH=/home/frs/project/%SF_PROJECT%/v%SF_VERSION%/

REM ============================================================
REM  Compare with last uploaded version in SourceForge.json
REM ============================================================
set SF_LAST_VERSION=
if exist "%SF_JSON%" (
    for /f "tokens=2 delims=:, " %%A in ('findstr /r "\"version\"" "%SF_JSON%"') do (
        set "SF_LAST_VERSION=%%~A"
    )
)

if not "!SF_LAST_VERSION!"=="" (
    echo Last uploaded version: !SF_LAST_VERSION!

    REM Split current version into major.minor.patch
    for /f "tokens=1-3 delims=." %%a in ("%SF_VERSION%") do (
        set CUR_MAJOR=%%a
        set CUR_MINOR=%%b
        set CUR_PATCH=%%c
    )
    REM Split last uploaded version into major.minor.patch
    for /f "tokens=1-3 delims=." %%a in ("!SF_LAST_VERSION!") do (
        set LAST_MAJOR=%%a
        set LAST_MINOR=%%b
        set LAST_PATCH=%%c
    )

    REM Compare major.minor.patch
    set IS_NEWER=0
    if !CUR_MAJOR! gtr !LAST_MAJOR! (set IS_NEWER=1)
    if !CUR_MAJOR! equ !LAST_MAJOR! if !CUR_MINOR! gtr !LAST_MINOR! (set IS_NEWER=1)
    if !CUR_MAJOR! equ !LAST_MAJOR! if !CUR_MINOR! equ !LAST_MINOR! if !CUR_PATCH! gtr !LAST_PATCH! (set IS_NEWER=1)

    if !IS_NEWER! equ 0 (
        echo.
        echo [Skip] Source code version %SF_VERSION% is not newer than last uploaded version !SF_LAST_VERSION!.
        echo        Update the Version in %CSPROJ_FILE% before uploading.
        pause
        exit /b 0
    )
    echo Version %SF_VERSION% is newer than !SF_LAST_VERSION!. Proceeding with upload...
) else (
    echo No previous upload record found. Proceeding with upload...
)

echo.

REM Step 1: Build installer
echo [1/3] Building installer...
call build_installer.bat
if errorlevel 1 (
    echo [Error] Build failed. Upload aborted.
    pause
    exit /b 1
)

REM Step 2: Verify installer file exists
echo.
echo [2/3] Verifying installer file...
if not exist "%INSTALLER_FILE%" (
    echo [Error] Installer file not found: %INSTALLER_FILE%
    pause
    exit /b 1
)
echo Found: %INSTALLER_FILE%

REM Step 3: Upload to SourceForge via OpenSSH
echo.
echo [3/3] Uploading to SourceForge...
echo Target: %SF_USER%@frs.sourceforge.net:%SF_REMOTE_PATH%
echo.

set SFTP_BATCH=%TEMP%\sf_upload.txt

REM Step 3a: Create remote version directory (ignore error if already exists)
echo mkdir /home/frs/project/%SF_PROJECT%/v%SF_VERSION% > "%SFTP_BATCH%"
sftp -b "%SFTP_BATCH%" %SF_USER%@frs.sourceforge.net 2>nul

REM Step 3b: Upload installer
echo put %INSTALLER_FILE% /home/frs/project/%SF_PROJECT%/v%SF_VERSION%/ > "%SFTP_BATCH%"
sftp -b "%SFTP_BATCH%" %SF_USER%@frs.sourceforge.net
del "%SFTP_BATCH%"

if errorlevel 1 (
    echo.
    echo [Error] Upload failed!
    echo Common causes:
    echo   1. Incorrect SF_USER or SF_PROJECT
    echo   2. Wrong password or SSH key not configured
    echo   3. Network issue
    pause
    exit /b 1
)

REM ============================================================
REM  Save uploaded version to SourceForge.json
REM ============================================================
echo {> "%SF_JSON%"
echo   "version": "%SF_VERSION%">> "%SF_JSON%"
echo }>> "%SF_JSON%"
echo.
echo Saved version %SF_VERSION% to %SF_JSON%.

echo.
echo === Upload complete! ===
echo https://sourceforge.net/projects/%SF_PROJECT%/files/v%SF_VERSION%/
echo.
pause
endlocal

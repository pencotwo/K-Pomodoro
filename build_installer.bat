@echo off
setlocal
echo === PomodoroApp2 Installer Build Script ===
echo.

REM Step 1: Publish (framework-dependent, single file)
echo [1/2] Publishing application...
dotnet publish -c Release --no-self-contained -p:PublishSingleFile=true -r win-x64 -o publish
if errorlevel 1 (
    echo Error: dotnet publish failed!
    pause
    exit /b 1
)
echo Publish complete.

REM Read version from .csproj
set APP_VERSION=
for /f "tokens=3 delims=<>" %%A in ('findstr /r "<Version>" PomodoroApp2.csproj') do (
    set APP_VERSION=%%A
)
if "%APP_VERSION%"=="" (
    echo Error: Could not read Version from PomodoroApp2.csproj.
    pause
    exit /b 1
)
echo Detected version: %APP_VERSION%

REM Step 2: Compile Inno Setup installer
echo.
echo [2/2] Compiling installer...

set ISCC=
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" set ISCC=C:\Program Files (x86)\Inno Setup 6\ISCC.exe
if exist "C:\Program Files\Inno Setup 6\ISCC.exe" set ISCC=C:\Program Files\Inno Setup 6\ISCC.exe
if exist "C:\Users\penco\AppData\Local\Programs\Inno Setup 6\ISCC.exe" set ISCC=C:\Users\penco\AppData\Local\Programs\Inno Setup 6\ISCC.exe

if "%ISCC%"=="" (
    echo.
    echo Error: Inno Setup 6 not found.
    echo Please download and install it from: https://jrsoftware.org/isdl.php
    pause
    exit /b 1
)

"%ISCC%" /DMyAppVersion=%APP_VERSION% installer.iss
if errorlevel 1 (
    echo Error: Installer compilation failed!
    pause
    exit /b 1
)

set OUTPUT_EXE=installer_output\K-Pomodoro_Setup_v%APP_VERSION%.exe
set TIMESTAMP_URL=http://timestamp.digicert.com
if not "%SIGN_TIMESTAMP_URL%"=="" set TIMESTAMP_URL=%SIGN_TIMESTAMP_URL%

if "%SIGNTOOL_PATH%"=="" (
    if exist "C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\signtool.exe" set SIGNTOOL_PATH=C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\signtool.exe
    if exist "C:\Program Files\Windows Kits\10\bin\10.0.26100.0\x64\signtool.exe" set SIGNTOOL_PATH=C:\Program Files\Windows Kits\10\bin\10.0.26100.0\x64\signtool.exe
)

if not "%SIGN_CERT_FILE%"=="" (
    if "%SIGNTOOL_PATH%"=="" (
        echo Error: SIGN_CERT_FILE is set but signtool.exe was not found.
        pause
        exit /b 1
    )

    echo.
    echo Signing installer...
    if not "%SIGN_CERT_PASSWORD%"=="" (
        "%SIGNTOOL_PATH%" sign /fd SHA256 /td SHA256 /tr "%TIMESTAMP_URL%" /f "%SIGN_CERT_FILE%" /p "%SIGN_CERT_PASSWORD%" "%OUTPUT_EXE%"
    ) else (
        "%SIGNTOOL_PATH%" sign /fd SHA256 /td SHA256 /tr "%TIMESTAMP_URL%" /f "%SIGN_CERT_FILE%" "%OUTPUT_EXE%"
    )

    if errorlevel 1 (
        echo Error: Installer signing failed!
        pause
        exit /b 1
    )
    echo Installer signed: %OUTPUT_EXE%
) else (
    echo.
    echo Installer was built but not signed.
    echo To sign it, set SIGN_CERT_FILE and optionally SIGN_CERT_PASSWORD / SIGN_TIMESTAMP_URL.
)

echo.
echo === Done! Installer saved to installer_output\K-Pomodoro_Setup_v%APP_VERSION%.exe ===
pause

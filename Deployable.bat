@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM  Configuration
REM ============================================================
set "CSPROJ_FILE=PomodoroApp2.csproj"
set "SF_JSON=SourceForge.json"

REM ============================================================
REM  Read version from .csproj
REM ============================================================
set SF_VERSION=
for /f "tokens=3 delims=<>" %%A in ('findstr /r "<Version>" "%CSPROJ_FILE%"') do (
    set SF_VERSION=%%A
)
if "%SF_VERSION%"=="" (
    echo NO
    exit /b 1
)

REM ============================================================
REM  Read last uploaded version from SourceForge.json
REM ============================================================
set SF_LAST_VERSION=
if exist "%SF_JSON%" (
    for /f "tokens=2 delims=:, " %%A in ('findstr /r "\"version\"" "%SF_JSON%"') do (
        set "SF_LAST_VERSION=%%~A"
    )
)

REM If no previous upload, it is deployable
if "%SF_LAST_VERSION%"=="" (
    echo YES
    exit /b 0
)

REM ============================================================
REM  Compare Versions (Major.Minor.Patch)
REM ============================================================

REM Split current version
for /f "tokens=1-3 delims=." %%a in ("%SF_VERSION%") do (
    set CUR_MAJOR=%%a
    set CUR_MINOR=%%b
    set CUR_PATCH=%%c
)
REM Split last uploaded version
for /f "tokens=1-3 delims=." %%a in ("%SF_LAST_VERSION%") do (
    set LAST_MAJOR=%%a
    set LAST_MINOR=%%b
    set LAST_PATCH=%%c
)

set IS_NEWER=0
if !CUR_MAJOR! gtr !LAST_MAJOR! (set IS_NEWER=1)
if !CUR_MAJOR! equ !LAST_MAJOR! if !CUR_MINOR! gtr !LAST_MINOR! (set IS_NEWER=1)
if !CUR_MAJOR! equ !LAST_MAJOR! if !CUR_MINOR! equ !LAST_MINOR! if !CUR_PATCH! gtr !LAST_PATCH! (set IS_NEWER=1)

if !IS_NEWER! equ 1 (
    echo YES
) else (
    echo NO
)

endlocal

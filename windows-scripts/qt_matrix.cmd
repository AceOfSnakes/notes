@echo off

FOR /F %%a IN (env) DO (
    IF "%%a" NEQ "#" (
        set %%a
    )
)

setlocal enabledelayedexpansion

set "TARGET_VERSION="
set "TARGET_ARCH="
set "TARGET_LINK="

:: ==============================================================================
:: DYNAMIC ARGUMENT PARSING (ORDER INDEPENDENT)
:: ==============================================================================
:PARSE_ARGS
if "%~1"=="" goto END_PARSE_ARGS

set "ARG=%~1"

:: Detect Version (matches qt5, qt6, etc.)
if /i "!ARG:~0,2!"=="qt" (
    set "TARGET_VERSION=!ARG!"
    goto NEXT_ARG
)

:: Detect Link Type (matches static or shared)
if /i "!ARG!"=="static" (
    set "TARGET_LINK=static"
    goto NEXT_ARG
)
if /i "!ARG!"=="shared" (
    set "TARGET_LINK=shared"
    goto NEXT_ARG
)

:: If it's none of the above, treat it as Architecture (x86, x86_64, arm64)
set "TARGET_ARCH=!ARG!"

:NEXT_ARG
shift
goto PARSE_ARGS
:END_PARSE_ARGS

:: ==============================================================================
:: MASTER HARDENED USER PATH CONFIGURATION
:: ==============================================================================
set "DIST_ROOT=%~dp0dist_matrix"

echo ==============================================================================
echo STARTING CLEAN MSVC NATIVE MATRIX ENGINE
echo ==============================================================================
if not exist "%DIST_ROOT%" ( mkdir "%DIST_ROOT%" )

:: ==============================================================================
:: RUN COMPILATION MATRIX VIA ISOLATED PROCESS CONTEXTS
:: ==============================================================================

for %%A in (
    "qt5|x86|static|vcvars32.bat"
    "qt5|x86|shared|vcvars32.bat"
    "qt5|x86_64|static|vcvars64.bat"
    "qt5|x86_64|shared|vcvars64.bat"
    "qt5|arm64|static|vcvarsamd64_arm64.bat"
    "qt5|arm64|shared|vcvarsamd64_arm64.bat"
    "qt6|x86|static|vcvars32.bat"
    "qt6|x86|shared|vcvars32.bat"
    "qt6|x86_64|static|vcvars64.bat"
    "qt6|x86_64|shared|vcvars64.bat"
    "qt6|arm64|static|vcvarsamd64_arm64.bat"
    "qt6|arm64|shared|vcvarsamd64_arm64.bat"
) do (
    for /f "tokens=1,2,3,4 delims=|" %%I in ("%%~A") do (

        set "MATCH=1"
        rem Filter out by CLI arguments
        if not "%TARGET_VERSION%" == "" ( if /i not "%%I" == "%TARGET_VERSION%" set "MATCH=0" )
        if not "%TARGET_ARCH%" == "" ( if /i not "%%J" == "%TARGET_ARCH%" set "MATCH=0" )
        if not "%TARGET_LINK%" == "" ( if /i not "%%K" == "%TARGET_LINK%" set "MATCH=0" )
	rem echo MATCH !MATCH! %TARGET_VERSION% %%I
        if "!MATCH!" == "1" (
            echo ----------------------------------------------------------------------
            echo TARGET STAGE: %%I - %%J %%K
            echo ----------------------------------------------------------------------
            cmd /c "%~dp0qt_build_worker.bat "%%I" "%%J" "%%K" "%%L""
            if "!ERRORLEVEL!" NEQ  "0" ( exit "!ERRORLEVEL!" )
            echo.
        )
    )
)

::if exist "%~dp0build" rd /s /q "%~dp0build"

echo ==============================================================================
echo SUCCESS: All target matrix completed
echo ==============================================================================


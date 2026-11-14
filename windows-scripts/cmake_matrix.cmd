@echo off

FOR /F %%a IN (env) DO (
    IF "%%a" NEQ "#" (
        set %%a
    )
)

setlocal enabledelayedexpansion
set "TARGET_ARCH="
set "TARGET_LINK="
set "TARGET_NAME="
:: ==============================================================================
:: DYNAMIC ARGUMENT PARSING (ORDER INDEPENDENT)
:: ==============================================================================
:PARSE_ARGS
if "%~1"=="" goto END_PARSE_ARGS

set "ARG=%~1"

:: Detect Link Type (matches static or shared)
if /i "!ARG!"=="static" (
    set "TARGET_LINK=static"
    goto NEXT_ARG
)
if /i "!ARG!"=="shared" (
    set "TARGET_LINK=shared"
    goto NEXT_ARG
)
if /i "!ARG!"=="x86" (
    set "TARGET_ARCH=!ARG!"
    goto NEXT_ARG
)
if /i "!ARG!"=="x86_64" (
    set "TARGET_ARCH=!ARG!"
    goto NEXT_ARG
)
if /i "!ARG!"=="arm64" (
    set "TARGET_ARCH=!ARG!"
    goto NEXT_ARG
)
:: If it's none of the above, treat it as package name
set "TARGET_NAME=!ARG!"

:NEXT_ARG
shift
goto PARSE_ARGS
:END_PARSE_ARGS

if "%TARGET_NAME%" == "" (
   echo Error
   echo  Usage: %~0 [filters]... package
   echo         filters are: shared^|static x86^|x86_64^|arm64
   exit /b 1
)
:: ==============================================================================
:: MASTER HARDENED USER PATH CONFIGURATION
:: ==============================================================================
set "DIST_ROOT=%~dp0dist_matrix"

echo ==============================================================================
echo STARTING CLEAN MSVC NATIVE MATRIX ENGINE
echo ==============================================================================

::if not exist "%SRC_DIR%\configure" (
::    echo Error: Source directory %SRC_DIR% not found or incomplete.
::    exit /b 1
::)

:: if exist "%DIST_ROOT%" rd /s /q "%DIST_ROOT%"
if not exist "%DIST_ROOT%" ( mkdir "%DIST_ROOT%" )

:: ==============================================================================
:: RUN COMPILATION MATRIX VIA ISOLATED PROCESS CONTEXTS
:: ==============================================================================

for %%A in (
    "x86|static|vcvars32.bat"
    "x86|shared|vcvars32.bat"
    "x86_64|static|vcvars64.bat"
    "x86_64|shared|vcvars64.bat"
    "arm64|static|vcvarsamd64_arm64.bat"
    "arm64|shared|vcvarsamd64_arm64.bat"
) do (
    for /f "tokens=1,2,3 delims=|" %%I in ("%%~A") do (

        set "MATCH=1"
        rem Filter out by CLI arguments
        if not "%TARGET_ARCH%" == "" ( if /i not "%%I" == "%TARGET_ARCH%" set "MATCH=0" )
        if not "%TARGET_LINK%" == "" ( if /i not "%%J" == "%TARGET_LINK%" set "MATCH=0" )

       if "!MATCH!" == "1" (
            echo ----------------------------------------------------------------------
            echo TARGET STAGE: %TARGET_NAME% %%I - %%J 
            echo ----------------------------------------------------------------------
            cmd /c "%~dp0cmake_build_worker.bat "%%I" "%%J" "%%K" "%TARGET_NAME%""
            if "!ERRORLEVEL!" NEQ  "0" ( exit "!ERRORLEVEL!" )
            echo.
        )
    )
)

rem if exist "%~dp0build" rd /s /q "%~dp0build"

echo ==============================================================================
echo SUCCESS: All target matrix zip packages for %TARGET_NAME% 
echo          are ready in %DIST_ROOT%
echo ==============================================================================


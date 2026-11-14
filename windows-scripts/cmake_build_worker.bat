@echo off
:: Explicitly capture arguments passed from master loop
set "ARCH=%~1"
set "VCVARS_BAT=%~3"
set "LINK_TYPE=%~2"
set "PACKAGE_NAME=%~4"
set "WORKING_FOLDER=%~p0"
set "WORKING_DRIVE=%~d0"

if "%~1" == "" set "INVALID=true"
if "%~2" == "" set "INVALID=true"
if "%~3" == "" set "INVALID=true"

if "%INVALID%" == "true" (
    echo Error: arguments are missing.
    echo  Usage: %~0 x86^|x86_x64^|arm64 static^|shared package
    exit /b 1
)


:: Resolve package version and some checks for source directory
set VER=%PACKAGE_NAME%_VERSION
:: echo Version variable is %VER%
CALL SET PACKAGE_VERSION=%%%VER%%%
SET VER=%PACKAGE_VERSION%
echo Version result is %PACKAGE_VERSION%

set "ZIP_NAME=%PACKAGE_NAME%-%PACKAGE_VERSION%-%ARCH%-%LINK_TYPE%"
set "PREFIX_DIR=%~dp0build\out-%ZIP_NAME%"
set "TMP_DIR=%~dp0build\tmp-%ZIP_NAME%"

set "SRC_DIR=F:\Opt\oss\%PACKAGE_NAME%-%PACKAGE_VERSION%"

if not exist "%SRC_DIR%" (
    echo Error: Source directory %SRC_DIR% not found.
    exit /b 1
)

mkdir "%~dp0build" 2>nul
if exist "%PREFIX_DIR%" rd /s /q "%PREFIX_DIR%"
mkdir "%PREFIX_DIR%"

echo Result %ZIP_NAME%
echo Initializing Visual Studio Environment for %PACKAGE_NAME% %PACKAGE_VERSION% %ARCH%...
echo %VCVARS_BAT%
call "%MSVS_DIR%\VC\Auxiliary\Build\%VCVARS_BAT%"

echo Launching Compilation...

:: Configure
:: Find and read configure first line
setlocal enabledelayedexpansion

if exist "%SRC_DIR%\configure" (
    echo Configuration file found %SRC_DIR%\configure
    :: Call a subroutine to safely read the first line without breaking the block
    call :GetFirstLine "%SRC_DIR%\configure"
   
)

endlocal & set "CONFIG_FIRST_LINE=%CONFIG_FIRST_LINE%"
IF "%ARCH%" EQU "x86" (set COMPILER=Win32) ELSE IF "%ARCH%" EQU "x86_64" (set COMPILER=x64) else (set COMPILER=arm64)

:: CONFIG_FIRST_LINE store first line of configure
if "%CONFIG_FIRST_LINE%" == "" (
  echo configure not found
) 

if "%PACKAGE_NAME%" == "zlib" (
   echo Skipping zlib dependency
) else (
   set "INCLUDE=f:\usr\lib%ARCH%\%LINK_TYPE%\zlib\include;%INCLUDE%"
   set "LIB=f:\usr\lib%ARCH%\%LINK_TYPE%\zlib\lib;%LIB%"
)

if "%PACKAGE_NAME%" == "apr-util" (
    set "INCLUDE=f:\usr\lib%ARCH%\%LINK_TYPE%\expat\include;%INCLUDE%"
    set "LIB=f:\usr\lib%ARCH%\%LINK_TYPE%\expat\lib;%LIB%"
)

echo "INCLUDE: %INCLUDE%"
echo "LIB: %LIB%"


set "CMAKE_FLAGS=--install-prefix %PREFIX_DIR% -A %COMPILER% -B %TMP_DIR%"
set "CMAKE_FLAGS=%CMAKE_FLAGS% -S %OSS_DIR%%PACKAGE_NAME%-%PACKAGE_VERSION%"

:: package specific settings
if "%PACKAGE_NAME%" == "apr" set "CMAKE_FLAGS=%CMAKE_FLAGS% -DAPR_BUILD_TESTAPR=OFF"
if "%PACKAGE_NAME%" == "pcre2" (
   set "CMAKE_FLAGS=%CMAKE_FLAGS% -DPCRE2_BUILD_PCRE2_16=ON -DPCRE2_BUILD_PCRE2_32=ON"
)
if "%PACKAGE_NAME%" == "apr-util" (
    set "CMAKE_FLAGS=%CMAKE_FLAGS% -DAPR_INCLUDE_DIR=f:\usr\lib%ARCH%\%LINK_TYPE%\apr\include -DAPR_LIBRARIES=f:\usr\lib%ARCH%\%LINK_TYPE%\apr\lib\libapr-1.lib -DOPENSSL_ROOT_DIR=f:\usr\lib%ARCH%\%LINK_TYPE%\openssl3"
)

if "%LINK_TYPE%" == "static" (
  if "%PACKAGE_NAME%" == "zlib" set "CMAKE_FLAGS=%CMAKE_FLAGS% -DZLIB_BUILD_SHARED=OFF -DZLIB_BUILD_STATIC=ON"
  if "%PACKAGE_NAME%" == "apr" set "CMAKE_FLAGS=%CMAKE_FLAGS% -DAPR_BUILD_SHARED=OFF -DAPR_BUILD_STATIC=ON"
  if "%PACKAGE_NAME%" == "pcre2" set "CMAKE_FLAGS=%CMAKE_FLAGS% -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON"
  if "%PACKAGE_NAME%" == "expat" set "CMAKE_FLAGS=%CMAKE_FLAGS% -DBUILD_SHARED_LIBS=OFF -DEXPAT_MSVC_STATIC_CRT=ON"
) else (
  if "%PACKAGE_NAME%" == "zlib" set "CMAKE_FLAGS=%CMAKE_FLAGS% -DZLIB_BUILD_SHARED=ON -DZLIB_BUILD_STATIC=OFF"
  if "%PACKAGE_NAME%" == "apr" set "CMAKE_FLAGS=%CMAKE_FLAGS% -DAPR_BUILD_SHARED=ON -DAPR_BUILD_STATIC=OFF"
  if "%PACKAGE_NAME%" == "pcre2" set "CMAKE_FLAGS=%CMAKE_FLAGS% -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF"
  if "%PACKAGE_NAME%" == "expat" set "CMAKE_FLAGS=%CMAKE_FLAGS% -DBUILD_SHARED_LIBS=ON"
)

if "%PACKAGE_NAME%" == "apr" (
  if "%ARCH%" == "arm64" (
    set "HOST_GEN_EXE=F:\usr\libx86_64\%LINK_TYPE%\%PACKAGE_NAME%\bin\gen_test_char.exe"
  )
)

cd
echo "cmake %CMAKE_FLAGS%"
cmake %CMAKE_FLAGS%

:: patch with replace target
if "%PACKAGE_NAME%" == "apr" (
  cmake --build %TMP_DIR% --config Release >nul
  if "%ARCH%" == "arm64" (
    timeout /t 3 /nobreak > nul
    "%HOST_GEN_EXE%" > "%TMP_DIR%\apr_escape_test_char.h"
  )
)

:: Make
cmake --build %TMP_DIR% --config Release
if "%ERRORLEVEL%" NEQ "0" ( goto :error )

:: Install
cmake --install %TMP_DIR%
if "%ERRORLEVEL%" NEQ "0" ( goto :error )

:: patch for apr copy additional files
if "%PACKAGE_NAME%" == "putty" (
  echo "Manually copy %TMP_DIR%\Release\p*.exe to distribute"
  copy %TMP_DIR%\Release\p*.exe %PREFIX_DIR%\
  copy %SRC_DIR%\README %PREFIX_DIR%\
  copy %SRC_DIR%\LICENCE %PREFIX_DIR%\
)

:: patch for apr copy additional files
if "%PACKAGE_NAME%" == "apr" (
  if not exist %PREFIX_DIR%\bin\ mkdir %PREFIX_DIR%\bin\
  copy %TMP_DIR%\Release\*.exe %PREFIX_DIR%\bin\
)
:: Remove temp dir
if exist "%TMP_DIR%" rd /s /q "%TMP_DIR%"
if "%ERRORLEVEL%" NEQ "0" ( goto :error )
:: Archive package

if exist "%~dp0dist_matrix\%ZIP_NAME%.zip" (
    echo "Delete old archive %~dp0dist_matrix\%ZIP_NAME%.zip"
    DEL "%~dp0dist_matrix\%ZIP_NAME%.zip"
)

set "DESTINATION=F:\usr\lib%ARCH%\%LINK_TYPE%\%PACKAGE_NAME%"

if exist "%PREFIX_DIR%" (
    echo "Destination %DESTINATION%"
    if exist "%DESTINATION%" rd /s /q "%DESTINATION%"
    mkdir "%DESTINATION%"
    if "%ERRORLEVEL%" NEQ "0" ( goto :error )
    echo "Distribute %PREFIX_DIR% to %DESTINATION%"
    xcopy "%PREFIX_DIR%" "%DESTINATION%" /E /I /H /Y
    if "%ERRORLEVEL%" NEQ "0" ( goto :error )

    if exist "%~dp0\build\out-%ZIP_NAME%\*" (
        powershell -Command "Compress-Archive -Path '%PREFIX_DIR%\*' -DestinationPath '%~dp0\dist_matrix\%ZIP_NAME%.zip' -Force"
        if "%ERRORLEVEL%" NEQ "0" ( goto :error )
        echo Successfully generated: %ZIP_NAME%.zip
    ) else (
        echo Error: Build finished but output directories are empty for %ZIP_NAME%
    )
)

%WORKING_DRIVE%
cd %WORKING_FOLDER%

if exist "%PREFIX_DIR%" rd /s /q "%PREFIX_DIR%"
if "%ERRORLEVEL%" NEQ "0" ( goto :err )
exit /b 0

:: --- Subroutine to read the first line safely ---
:GetFirstLine
setlocal disabledelayedexpansion
for /f "usebackq delims=" %%A in (%1) do (
    set "RAW_LINE=%%A"
    goto :end_sub
)
:end_sub
endlocal & set "CONFIG_FIRST_LINE=%RAW_LINE%"
exit /b

:error
echo "Build failed" && exit /b %ERRORLEVEL%
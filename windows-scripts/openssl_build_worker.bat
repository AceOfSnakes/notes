@echo off
:: Explicitly capture arguments passed from master loop
set "ARCH=%~1"
set "VCVARS_BAT=%~3"
set "LINK_TYPE=%~2"
set "PACKAGE_NAME=openssl"
set "WORKING_FOLDER=%~p0"
set "WORKING_DRIVE=%~d0"

if "%~1" == "" set "INVALID=true"
if "%~2" == "" set "INVALID=true"
if "%~3" == "" set "INVALID=true"

if "%INVALID%" == "true" (
    echo Error: arguments are missing.
    echo  Usage: %~0 x86^|x86_x64^|arm64 static^|shared 
    exit /b 1
)
:: Resolve package version and some checks for source directory
set VER=%PACKAGE_NAME%_VERSION
:: echo Version variable is %VER%
CALL SET PACKAGE_VERSION=%%%VER%%%
SET VER=%PACKAGE_VERSION%
echo Version result is %PACKAGE_VERSION%


echo Initializing Visual Studio Environment for %PACKAGE_NAME% %PACKAGE_VERSION% %ARCH%...
echo %VCVARS_BAT%
call "%MSVS_DIR%\VC\Auxiliary\Build\%VCVARS_BAT%"

set "PATH=%PATH%;D:\Dev\Perl64\bin;D:\Dev\Perl64\site\bin;f:\usr\lib%ARCH%\nasm;"

cd %OSS_DIR%\openssl-%OPENSSL_VERSION%
echo %OSS_DIR%\openssl-%OPENSSL_VERSION%
set TARGET=f:\usr\lib%ARCH%\%LINK_TYPE%\openssl3

IF "%ARCH%" EQU "arm64" (
  set COMPILER=VC-WIN64-ARM
) ELSE IF "%ARCH%" EQU "x86" (
  set COMPILER=VC-WIN32
) ELSE (
  set COMPILER=VC-WIN64A
)
set "EXTRA_FLAGS="
if "%LINK_TYPE%" == "static" set "EXTRA_FLAGS=no-shared"
echo **********************************************************************       
echo Execute: perl Configure %COMPILER% %EXTRA_FLAGS% 
echo          no-tests no-external-tests
echo          --prefix=%TARGET% 
echo          --openssldir=%TARGET%\SSL
echo **********************************************************************
perl Configure %COMPILER% %EXTRA_FLAGS% --prefix=%TARGET% ^
     --openssldir=%TARGET%\SSL no-tests no-external-tests
echo **********************************************************************
echo Makefile: makefile
echo **********************************************************************

:: 1. Force inject the missing Windows SDK UCRT paths to both LIB and INCLUDE
set "INCLUDE=%INCLUDE%;F:\Windows Kits\10\include\10.0.26100.0\ucrt"
if "%ARCH%"=="x86" (
    set "LIB=%LIB%;F:\Windows Kits\10\lib\10.0.26100.0\ucrt\x86"
    set "PATH=f:\usr\lib%ARCH%\nasm;%PATH%"
) else if "%ARCH%"=="x86_64" (
    set "LIB=%LIB%;F:\Windows Kits\10\lib\10.0.26100.0\ucrt\x64"
    set "PATH=f:\usr\lib%ARCH%\nasm;%PATH%"
) else if "%ARCH%"=="arm64" (
    set "LIB=%LIB%;F:\Windows Kits\10\lib\10.0.26100.0\ucrt\arm64"
)

cd
echo Clean start
nmake -f makefile clean > NUL 2>&1
if "%ERRORLEVEL%" NEQ "0" ( goto :error )
echo Clean end

perl -pi.bak -e s/\/MD/\/MT/g makefile
if "%ERRORLEVEL%" NEQ "0" ( goto :error )

nmake 
if "%ERRORLEVEL%" NEQ "0" ( goto :error )

if exist "%TARGET%" rd /s /q "%TARGET%"
if "%ERRORLEVEL%" NEQ "0" ( goto :error )

mkdir %TARGET%
if "%ERRORLEVEL%" NEQ "0" ( goto :error )

nmake install
if "%ERRORLEVEL%" NEQ "0" ( goto :error )

%WORKING_DRIVE%
cd %WORKING_FOLDER%

:end
echo.
echo **********************************************************************
echo Complete openssl %OSSL3_VERSION% %LINK_TYPE% %ARCH%
echo **********************************************************************
exit /b 0

:error
echo "Build failed" && exit /b %ERRORLEVEL%
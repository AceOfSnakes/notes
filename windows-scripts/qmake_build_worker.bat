@echo off
:: Explicitly capture arguments passed from master loop
set "ARCH=%~1"
set "VCVARS_BAT=%~4"
set "LINK_TYPE=%~2"
set "QT_VERSION=%~3"
set "APPLICATION_NAME=%~5"
set "WORKING_FOLDER=%~p0"
set "WORKING_DRIVE=%~d0"

:: Re-verify environment variables passed from parent process context
set "ZIP_NAME=%APPLICATION_NAME%-%ARCH%-%LINK_TYPE%"
set "PREFIX_DIR=%~dp0build\out-%ZIP_NAME%"
set "DESTINATION=F:\usr\lib%ARCH%\%LINK_TYPE%\ffmpeg"

mkdir "%~dp0build" 2>nul
if exist "%PREFIX_DIR%" rd /s /q "%PREFIX_DIR%"
mkdir "%PREFIX_DIR%"

if "%~1" == "" set "INVALID=true"
if "%~2" == "" set "INVALID=true"
if "%~3" == "" set "INVALID=true"
if "%~4" == "" set "INVALID=true"

if "%INVALID%" == "true" (
    echo Error: arguments are missing.
    echo Usage: %~0 x86^|x86_x64^|arm64 static^|shared qt5^|qt6 application
    exit /b 1
)
echo Initializing Visual Studio Environment for %APPLICATION_NAME_NAME%...
echo %VCVARS_BAT%
call "%MSVS_DIR%\VC\Auxiliary\Build\%VCVARS_BAT%"
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

echo Launching Compilation...

set "QMAKE=qmake6"
if "%QT_VERSION%" =="qt5" set "QMAKE=qmake"

set QTDIR=F:\usr\lib%ARCH%\%LINK_TYPE%\%QT_VERSION%\
set PATH=%QTDIR%\bin;F:\Opt\perl\perl\bin;%PATH%

echo Build %APPLICATION_NAME% %QT_VERSION% %LINK_TYPE% with %QMAKE%
echo Packaging target distribution...
DEL "%~dp0dist_matrix\%ZIP_NAME%.zip"

mkdir %PREFIX_DIR%
cd %PREFIX_DIR%

call %QMAKE%  %APPS_DIR%\%APPLICATION_NAME%\%APPLICATION_NAME%.pro
if "%ERRORLEVEL%" NEQ "0" ( goto :error )

nmake -f Makefile.Release
if "%ERRORLEVEL%" NEQ "0" ( goto :error )

rmdir /Q /S %PREFIX_DIR%\wix\  > NUL 2>NUL
:package

%WORKING_DRIVE%
cd %WORKING_FOLDER%

set SHARED=

echo ************* Prepare archive files *************************************

set FILE=""

IF "%LINK_TYPE%" EQU "shared" (
  echo Find app-shared.install
  IF EXIST "%APPS_DIR%\%APPLICATION_NAME%\distr\wix\app-qt%QT_VERSION%-shared.install" (
    echo found %APPS_DIR%\%APPLICATION_NAME%\distr\wix\app-qt%QT_VERSION%-shared.install
    SET "FILE=%APPS_DIR%\%APPLICATION_NAME%\distr\wix\app-qt%QT_VERSION%-shared.install"
  ) ELSE IF EXIST "%APPS_DIR%\%APPLICATION_NAME%\distr\wix\app-shared.install" (
    echo found %APPS_DIR%\%APPLICATION_NAME%\distr\wix\app-shared.install
    SET "FILE=%APPS_DIR%\%APPLICATION_NAME%\distr\wix\app-shared.install"
  )
) ELSE (
  echo Find app-static.install
  IF EXIST "%APPS_DIR%\%APPLICATION_NAME%\distr\wix\app-qt%QT_VERSION%-static.install" (
    echo found %APPS_DIR%\%APPLICATION_NAME%\distr\wix\app-qt%QT_VERSION%-static.install
    SET "FILE=%APPS_DIR%\%APPLICATION_NAME%\distr\wix\app-qt%QT_VERSION%-static.install"
  ) ELSE IF EXIST "%APPS_DIR%\%APPLICATION_NAME%\distr\wix\app-static.install" (
    echo found %APPS_DIR%\%APPLICATION_NAME%\distr\wix\app-static.install
    SET "FILE=%APPS_DIR%\%APPLICATION_NAME%\distr\wix\app-static.install"
  )
)

IF "%FILE%" NEQ "" (
  echo ===================== FILE with shared resources ========================== 
  echo %FILE%
  echo ===========================================================================
  FOR /F "tokens=1,2 delims= " %%a IN (%FILE%) DO (

    call set "resolved_path=%%a"
    
    setlocal enabledelayedexpansion
    set "token1=!resolved_path!"
    set "firstChar=!token1:~0,1!"

    set "lastChar=!token1:~-1!"

    set "XCOPY_FLAGS=/Y"

    if "!lastChar!"=="\" set "XCOPY_FLAGS=/Y /E"

    if "!firstChar!"=="\" (
      echo Copying absolute: !token1!
      echo f | xcopy !token1! %PREFIX_DIR%\wix\build\%%b\ !XCOPY_FLAGS!

    ) ELSE (
      echo Copying relative: %QTDIR%\!token1!
      echo %QTDIR%\%%a %PREFIX_DIR%\shared\%%b
      echo f | xcopy %QTDIR%\!token1! %PREFIX_DIR%\wix\build\%%b\ !XCOPY_FLAGS!
    )

    endlocal
  )
  set SHARED=shared\*
)
xcopy %PREFIX_DIR%\release\*.exe %PREFIX_DIR%\wix\build\ /Y
set SUFFIX=

echo **********************************************************************
echo check "%WIN_APPS_DIR%%APPLICATION_NAME%\distr\wix\app-%QT_VERSION%.wxs.in"
IF EXIST "%WIN_APPS_DIR%%APPLICATION_NAME%\distr\wix\app-%QT_VERSION%.wxs.in" (
  echo "%WIN_APPS_DIR%%APPLICATION_NAME%\distr\wix\app-%QT_VERSION%.wxs.in" found suffix used -%QT_VERSION%
  echo F | xcopy %WIN_APPS_DIR%%APPLICATION_NAME%\distr\wix\app-%QT_VERSION%.wxs.in %PREFIX_DIR%\wix\app.wxs /Y
  echo F | xcopy %WIN_APPS_DIR%%APPLICATION_NAME%\distr\wix\bundle-%QT_VERSION%.wxs.in %PREFIX_DIR%\wix\bundle.wxs /Y
  set SUFFIX=-%QT_VERSION%
) ELSE (
  echo F | xcopy %WIN_APPS_DIR%%APPLICATION_NAME%\distr\wix\app.wxs.in %PREFIX_DIR%\wix\app.wxs /Y
  echo F | xcopy %WIN_APPS_DIR%%APPLICATION_NAME%\distr\wix\bundle.wxs.in %PREFIX_DIR%\wix\bundle.wxs /Y
)
echo D | xcopy %WIN_APPS_DIR%%APPLICATION_NAME%\distr\wix\assets %PREFIX_DIR%\wix\assets /Y
echo **********************************************************************

IF "%APP_VERSION_VALUE%" NEQ "" (
    set FINAL_VERSION=%APP_VERSION_VALUE%
) ELSE (
    set FINAL_VERSION=99.99
)

for %%f in ("%PREFIX_DIR%\wix\*.wxs") do (
    perl -pi.bak -e "s/%%SOURCE%%/%APPLICATION_NAME%/g; s/%%APP_VERSION%%/%FINAL_VERSION%/g; s/%%VSCMD_ARG_TGT_ARCH%%/%VSCMD_ARG_TGT_ARCH%/g" "%%f"
)

:: Enable dynamic variable updating inside loops
setlocal enabledelayedexpansion

echo Processing %WIN_APPS_DIR%%APPLICATION_NAME%\distr\wix\%VSCMD_ARG_TGT_ARCH%%SUFFIX%.vars

FOR /F "usebackq tokens=1,2 delims==" %%A IN ("%WIN_APPS_DIR%%APPLICATION_NAME%\distr\wix\%VSCMD_ARG_TGT_ARCH%%SUFFIX%.vars") DO (
    echo Replacing %%%%A%% with %%B
    perl -pi.bak -e "s/%%%%A%%/%%B/g" "%PREFIX_DIR%\wix\app.wxs"
    perl -pi.bak -e "s/%%%%A%%/%%B/g" "%PREFIX_DIR%\wix\bundle.wxs"
)

endlocal

echo **********************************************************************
tree /f %PREFIX_DIR%\wix\
echo **********************************************************************

set DST_NAME=%APPLICATION_NAME%%SUFFIX%_%FINAL_VERSION%_%VSCMD_ARG_TGT_ARCH%

del %~dp0dist_matrix\%DST_NAME%*.*
ECHO "DELETED %~dp0dist_matrix\%DST_NAME%*.*"

tar -a -cf "%~dp0dist_matrix\%DST_NAME%-windows.zip" -C "%PREFIX_DIR%\wix\build" *

echo wix build -acceptEula wix7 %PREFIX_DIR%\wix\app.wxs 
echo  -b %PREFIX_DIR%\wix\ -ext WixToolset.UI.wixext 
echo  -arch %VSCMD_ARG_TGT_ARCH% -o %PREFIX_DIR%\wix\build\%APPLICATION_NAME%%SUFFIX%_%VSCMD_ARG_TGT_ARCH%.msi

wix build -acceptEula wix7 %PREFIX_DIR%\wix\app.wxs ^
    -b %PREFIX_DIR%\wix\ -ext WixToolset.UI.wixext ^
    -arch %VSCMD_ARG_TGT_ARCH% -o %PREFIX_DIR%\wix\build\%APPLICATION_NAME%%SUFFIX%_%VSCMD_ARG_TGT_ARCH%.msi

echo Done

if "%ERRORLEVEL%" NEQ  "0" ( goto :error )

copy %PREFIX_DIR%\wix\build\%APPLICATION_NAME%%SUFFIX%_%VSCMD_ARG_TGT_ARCH%.msi^
     %~dp0dist_matrix\%DST_NAME%-windows-installer.msi

if "%ERRORLEVEL%" NEQ  "0" ( goto :error )

echo wix build -acceptEula wix7 %PREFIX_DIR%\wix\bundle.wxs 
echo    -b %PREFIX_DIR%\wix\ -ext WixToolset.BootstrapperApplications.wixext 
echo    -arch %VSCMD_ARG_TGT_ARCH% -o %~dp0dist_matrix\%DST_NAME%-windows-installer.exe

wix build -acceptEula wix7 %PREFIX_DIR%\wix\bundle.wxs ^
    -b %PREFIX_DIR%\wix\ -ext WixToolset.BootstrapperApplications.wixext ^
    -arch %VSCMD_ARG_TGT_ARCH% -o %~dp0dist_matrix\%DST_NAME%-windows-installer.exe

del %~dp0dist_matrix\%DST_NAME%*.wixpdb

if "%ERRORLEVEL%" NEQ  "0" ( goto :error )

:: rename to lower case
cd %~dp0dist_matrix

for /f "Tokens=*" %%f in ('dir /l/b/a-d %DST_NAME%*.msi %DST_NAME%*.zip %DST_NAME%*.exe') do rename "%%f" "%%f"

%WORKING_DRIVE%
cd %WORKING_FOLDER%

if exist "%PREFIX_DIR%" rd /s /q "%PREFIX_DIR%"

exit /b 0

:error
%WORKING_DRIVE%
cd %WORKING_FOLDER%
echo "Build failed" && exit /b %ERRORLEVEL%
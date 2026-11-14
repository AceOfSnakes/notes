@echo off
:: Explicitly capture arguments passed from master loop
set "QT_MATRIX_VERSION=%~1"
set "ARCH=%~2"
set "LINK_TYPE=%~3"
set "VCVARS_BAT=%~4"
set "WORKING_FOLDER=%~p0"
set "WORKING_DRIVE=%~d0"

if "%~1" == "" set "INVALID=true"
if "%~2" == "" set "INVALID=true"
if "%~3" == "" set "INVALID=true"
if "%INVALID%" == "true" (
    echo Error: arguments are missing.
    echo Usage: %~0 qt5^|qt6 x86^|x86_x64^|arm64 static^|shared
    exit /b 1
)

set "HOST_QT_PATH="
set "SOURCE_QT_PATH="
set "FFMEG_DIR="

IF "%QT_MATRIX_VERSION%" == "qt5" (
    set "SOURCE_QT_PATH=f:\Opt\Qt\%QT_VERSION%"
    IF "%ARCH%" == "arm64" ( set "VCVARS_BAT=vcvars64.bat")
) ELSE (
    set "SOURCE_QT_PATH=f:\Opt\Qt\%QT6_VERSION%"
)

echo Initializing Visual Studio Environment...
call "%MSVS_DIR%\VC\Auxiliary\Build\%VCVARS_BAT%"

set "LIB_TARGET=F:\usr\lib%ARCH%\%LINK_TYPE%"
set "FFMEG_DIR=%LIB_TARGET%\ffmpeg"
::set "QT_TARGET=E:\usr\lib%ARCH%\%LINK_TYPE%\%QT_MATRIX_VERSION%"
set "QT_TARGET=%LIB_TARGET%\%QT_MATRIX_VERSION%"

set "INCLUDE=%INCLUDE%;F:\Windows Kits\10\include\10.0.26100.0\ucrt"

if "%ARCH%"=="x86" (
    set "LIB=%LIB%;F:\Windows Kits\10\lib\10.0.26100.0\ucrt\x86"
    set "PATH=f:\usr\lib%ARCH%\nasm;%PATH%"
) else if "%ARCH%"=="x86_64" (
    set "LIB=%LIB%;F:\Windows Kits\10\lib\10.0.26100.0\ucrt\x64"
    set "PATH=f:\usr\lib%ARCH%\nasm;%PATH%"
) else if "%ARCH%"=="arm64" (
    set "HOST_QT_PATH=f:\usr\libx86_64\%LINK_TYPE%\%QT_MATRIX_VERSION%"
    IF "%QT_MATRIX_VERSION%" == "qt5" (
      set "LIB=%LIB%;F:\Windows Kits\10\lib\10.0.26100.0\ucrt\x64"
    ) ELSE (
      set "LIB=%LIB%;F:\Windows Kits\10\lib\10.0.26100.0\ucrt\arm64"
    )
)

:: Re-verify environment variables passed from parent process context
set "QT_NAME=%QT_MATRIX_VERSION%-%ARCH%-%LINK_TYPE%"
set "PREFIX_DIR=%~dp0\build\out-%QT_NAME%"

mkdir "%~dp0\build" 2>nul
if exist "%PREFIX_DIR%" rd /s /q "%PREFIX_DIR%"
mkdir "%PREFIX_DIR%"

cd "%PREFIX_DIR%"

setlocal enabledelayedexpansion

SET "EXTRA_FLAGS="
SET "EXTRA_DEFINE_FLAGS="
set "QT_BUILD_FLAGS="

echo Prepare QT configuration...

IF "%QT_MATRIX_VERSION%"=="qt5" (
:: 1. Force Qt configuration to bypass compiling an ARM64 bootstrap qmake
  IF "%ARCH%"=="arm64" (
    SET "EXTRA_FLAGS=-external-hostbindir %HOST_QT_PATH%\bin -xplatform win32-arm64-msvc2017"
    SET "QT_QMAKE_EXECUTABLE=f:\usr\libx86_64\%LINK_TYPE%\qt5\bin\qmake.exe"
    SET "CFG_HOST_QT_TOOLS_PATH=f:\usr\libx86_64\%LINK_TYPE%\qt5\bin"
  )

  if "%LINK_TYPE%"=="static" (
    set "QT_BUILD_FLAGS=%QT_BUILD_FLAGS% -static -static-runtime"
  )
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! -skip qttools -skip qtcoap -skip qtdoc -skip qtmqtt -skip qtopcua -skip qttranslations "
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! -skip qt3d -skip qtcharts -skip qtdatavis3d"
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! -skip qtquickcontrols2 -skip qtlottie -skip qtquick3d -skip qtquicktimeline"
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! -skip qtscxml -skip qtvirtualkeyboard -skip qtwayland -skip qtactiveqt"
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! -skip qtwebengine -skip qtwebview -skip qtdeclarative"
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! -nomake examples -debug-and-release -confirm-license -opensource"
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! -prefix %QT_TARGET% -nomake tests"
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! -platform win32-msvc"
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! !EXTRA_FLAGS!"

) ELSE (
  IF "%ARCH%"=="arm64" (
    SET "EXTRA_FLAGS=-xplatform win32-arm64-msvc -qt-host-path %HOST_QT_PATH%"
  ) else   IF "%ARCH%"=="x86" (
    SET "EXTRA_DEFINE_FLAGS=-DFEATURE_windows_ioring=OFF"
  )
  if "%LINK_TYPE%"=="static" (
    set "QT_BUILD_FLAGS=%QT_BUILD_FLAGS% -static -static-runtime"
  ) else (
    set "QT_BUILD_FLAGS=%QT_BUILD_FLAGS% -ffmpeg-deploy"
  )

  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! -skip qttools -skip qtcoap -skip qtdoc -skip qtmqtt -skip qtopcua -skip qttranslations"
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! -skip qt3d -skip qt5compat -skip qtcharts -skip qtdatavis3d"
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! -skip qtquickcontrols2 -skip qtlottie -skip qtquicktimeline"
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! -skip qtscxml -skip qtvirtualkeyboard -skip qtwayland -skip qtopengl -skip qtactiveqt"
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! -skip qtwebengine -skip qtwebview"
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! -nomake examples -debug-and-release -confirm-license -opensource"
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! -prefix %QT_TARGET% -nomake tests"
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! -ffmpeg-dir %FFMEG_DIR%"
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! !EXTRA_FLAGS!"
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! -- -DCMAKE_CXX_FLAGS="/D_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS""
  set "QT_BUILD_FLAGS=!QT_BUILD_FLAGS! !EXTRA_DEFINE_FLAGS!"

)

echo Launching QT Compilation...
echo "QT_BUILD_FLAGS !QT_BUILD_FLAGS!"

cmd /c "%SOURCE_QT_PATH%\src\configure.bat !QT_BUILD_FLAGS!"
if "%ERRORLEVEL%" NEQ "0" ( echo "Failed..." && exit /b %ERRORLEVEL% )

IF "%QT_MATRIX_VERSION%" == "qt5" (
  call nmake -f Makefile
  if "%ERRORLEVEL%" NEQ "0" ( echo "Failed..." && exit /b %ERRORLEVEL% )
  
  rmdir /Q /S %QT_TARGET%
  mkdir %QT_TARGET% >NUL 2>NUL

  call nmake -f Makefile install
  if "%ERRORLEVEL%" NEQ "0" ( echo "Failed..." && exit /b %ERRORLEVEL% )

) ELSE (
  call cmake --build . --parallel
  if "%ERRORLEVEL%" NEQ "0" ( echo "Failed..." && exit /b %ERRORLEVEL% )

  rmdir /Q /S %QT_TARGET%
  mkdir %QT_TARGET% >NUL 2>NUL

  call cmake --install .
  if "%ERRORLEVEL%" NEQ "0" ( echo "Failed..." && exit /b %ERRORLEVEL% )

)

%WORKING_DRIVE%
cd %WORKING_FOLDER%

if exist "%PREFIX_DIR%" rd /s /q "%PREFIX_DIR%"
if "%ERRORLEVEL%" NEQ "0" ( echo "Fail" && exit /b %ERRORLEVEL% )

exit /b 0

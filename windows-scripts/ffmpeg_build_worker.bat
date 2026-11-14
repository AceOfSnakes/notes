@echo off
:: Explicitly capture arguments passed from master loop
set "ARCH=%~1"
set "VCVARS_BAT=%~3"
set "LINK_TYPE=%~2"
set "WORKING_FOLDER=%~p0"
set "WORKING_DRIVE=%~d0"
:: Re-verify environment variables passed from parent process context
set "ZIP_NAME=ffmpeg-%FFMPEG_VERSION%-msvc-%ARCH%-%LINK_TYPE%"
set "PREFIX_DIR=%~dp0build\out-%ZIP_NAME%"
set "DESTINATION=F:\usr\lib%ARCH%\%LINK_TYPE%\ffmpeg"

mkdir "%~dp0build" 2>nul
if exist "%PREFIX_DIR%" rd /s /q "%PREFIX_DIR%"
mkdir "%PREFIX_DIR%"

if "%~1" == "" set "INVALID=true"
if "%~2" == "" set "INVALID=true"

if "%INVALID%" == "true" (
    echo Error: arguments are missing.
    echo  Usage: %~0 x86^|x86_x64^|arm64 static^|shared
    exit /b 1
)

if "%LINK_TYPE%"=="shared" (
    set "LINK_FLAGS=--enable-shared --disable-static"
) else (
    set "LINK_FLAGS=--disable-shared --enable-static"
)

:: Translate paths into safe absolute POSIX tracking locations using absolute paths
for /f "delims=" %%B in ('%MSYS2_PATH%\usr\bin\cygpath.exe -u "F:\Opt\ffmpeg\FFmpeg-n%FFMPEG_VERSION%"') do set "MSYS_SRC=%%B"
for /f "delims=" %%B in ('%MSYS2_PATH%\usr\bin\cygpath.exe -u "%PREFIX_DIR%"') do set "MSYS_PREFIX=%%B"

echo Initializing Visual Studio Environment...
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

echo Launching MSYS2 Compilation...

cd "\Opt\ffmpeg\FFmpeg-n%FFMPEG_VERSION%"

:: Declare path inheritance so cl.exe preserves VS Includes & Libs
set "MSYS2_PATH_TYPE=inherit"

"%MSYS2_PATH%\usr\bin\bash.exe" --noprofile --norc -c "export PATH=\"$PATH:/usr/local/bin:/usr/bin:/bin\" && cd '%MSYS_SRC%' && make distclean 2>/dev/null || true && ./configure --target-os=win32 --arch=%ARCH% --toolchain=msvc --enable-cross-compile --disable-debug --disable-network %LINK_FLAGS% --prefix='%MSYS_PREFIX%' && make -j%NUMBER_OF_PROCESSORS% && make install"
if "%ERRORLEVEL%" NEQ "0" ( exit /b %ERRORLEVEL% )

echo Packaging target distribution...
DEL "%~dp0dist_matrix\%ZIP_NAME%.zip"
ECHO "DELETED %~dp0dist_matrix\%ZIP_NAME%.zip"
if exist "%PREFIX_DIR%" (
    
    echo "Destination %DESTINATION%"
    if exist "%DESTINATION%" rd /s /q "%DESTINATION%"
    mkdir "%DESTINATION%"
    if "%ERRORLEVEL%" NEQ "0" ( exit /b %ERRORLEVEL% )
    echo "Distribute %PREFIX_DIR% to %DESTINATION%"
    xcopy "%PREFIX_DIR%" "%DESTINATION%" /E /I /H /Y
    if "%ERRORLEVEL%" NEQ "0" ( exit /b %ERRORLEVEL% )

    if exist "%~dp0\build\out-%ZIP_NAME%\*" (
        powershell -Command "Compress-Archive -Path '%PREFIX_DIR%\*' -DestinationPath '%~dp0\dist_matrix\%ZIP_NAME%.zip' -Force"
        if "%ERRORLEVEL%" NEQ "0" ( exit /b %ERRORLEVEL% )
        echo Successfully generated: %ZIP_NAME%.zip
    ) else (
        echo Error: Build finished but output directories are empty for %ZIP_NAME%
    )
    
    %WORKING_DRIVE%
    cd %WORKING_FOLDER%

    rd /s /q "%PREFIX_DIR%"
)
exit /b 0

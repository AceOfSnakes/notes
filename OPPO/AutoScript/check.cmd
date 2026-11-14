@echo off
curl -fsSL https://aceofsnakes.github.io/aceofsnakes.gpg | gpg --dearmor > "%TEMP%\ace.gpg"
for %%F in (*.zip.asc) do gpgv --keyring "%TEMP%\ace.gpg" "%%F" "%%~nF"
del /f /q "%TEMP%\ace.gpg"
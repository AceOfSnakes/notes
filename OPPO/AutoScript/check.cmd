@echo off
curl -fsSL https://github.io | gpg --dearmor > "%TEMP%\ace.gpg"
for %%F in (*.zip.asc) do gpgv --keyring "%TEMP%\ace.gpg" "%%F" "%%~nF"
del /f /q "%TEMP%\ace.gpg"
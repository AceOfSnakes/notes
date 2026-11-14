## OPPO UDP-203

## Links

[Hidden codes](https://aceofsnakes.github.io/notes/OPPO/codes.html)

[Factory menu](https://aceofsnakes.github.io/notes/OPPO/factory.html)

### github
|  Original | Fetch | Releases
| :--- | :--- | :--- | 
| [**autoABC**](https://github.com/DamnFine815/autoABC/) | [autoABC fetch](https://github.com/AceOfSnakes/autoABC) | [autoABC releases](https://github.com/DamnFine815/autoABC/releases)
| [**oppo-dv-mkv**](https://github.com/fandangos/oppo-dv-mkv/) |[oppo-dv-mkv fetch](https://github.com/AceOfSnakes/oppo-dv-mkv) | [oppo-dv-mkv releases](https://github.com/fandangos/oppo-dv-mkv/releases)
|[**NetRC**](https://github.com/AceOfSnakes/NetRC)||[NetRC releases](https://github.com/AceOfSnakes/NetRC/releases)

## Autoscript

 - [Dump](AutoScript/dump.zip) | [ASC](AutoScript/dump.zip.asc)
 - [Telnet](AutoScript/telnet.zip) | [ASC](AutoScript/telnet.zip.asc)  

### Verify archives
Download zip and asc in one folder and run

On linux

check.sh [Download / view](AutoScript/check.sh)
```sh
curl -fsSL https://aceofsnakes.github.io/aceofsnakes.gpg | gpg --dearmor > /tmp/ace.gpg
for sig in *.zip.asc; do gpgv --keyring /tmp/ace.gpg "$sig" "${sig%.asc}"; done
rm -f /tmp/ace.gpg
```

On Windows 

check.ps1 [Download / view](AutoScript/check.ps1)

Execute ps1 file
```
powershell -ExecutionPolicy Bypass -File check.ps1
```
```powershell
$KeyPath = "$env:TEMP\ace.gpg"

curl.exe -fsSL https://aceofsnakes.github.io/aceofsnakes.gpg | gpg --dearmor --yes -o $KeyPath

Get-ChildItem *.zip.asc | ForEach-Object {
    gpgv --keyring $KeyPath $_.Name $_.BaseName
}

Remove-Item $KeyPath -Force
```

one line command
```
curl -fsSL https://aceofsnakes.github.io/aceofsnakes.gpg | gpg --dearmor > "%TEMP%\ace.gpg" && (for %F in (*.zip.asc) do gpgv --keyring "%TEMP%\ace.gpg" "%F" "%~nF") && del /f /q "%TEMP%\ace.gpg"
```

check.cmd [Download / view](AutoScript/check.cmd)
```cmd
@echo off
curl -fsSL https://aceofsnakes.github.io/aceofsnakes.gpg | gpg --dearmor > "%TEMP%\ace.gpg"
for %%F in (*.zip.asc) do gpgv --keyring "%TEMP%\ace.gpg" "%%F" "%%~nF"
del /f /q "%TEMP%\ace.gpg"
```
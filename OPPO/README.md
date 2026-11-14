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
Linux
```sh
curl -fsSL https://aceofsnakes.github.io/aceofsnakes.gpg | gpg --dearmor > /tmp/ace.gpg
for sig in *.zip.asc; do gpgv --keyring /tmp/ace.gpg "$sig" "${sig%.asc}"; done
rm -f /tmp/ace.gpg
```
Windows
```powershell
curl.exe -fsSL https://aceofsnakes.github.io/aceofsnakes.gpg | gpg --dearmor > "$env:TEMP\ace.gpg"
Get-ChildItem *.zip.asc | ForEach-Object { gpgv --keyring "$env:TEMP\ace.gpg" $_.Name $_.BaseName }
Remove-Item "$env:TEMP\ace.gpg" -Force
```

```
curl -fsSL https://aceofsnakes.github.io/aceofsnakes.gpg | gpg --dearmor > "%TEMP%\ace.gpg" && (for %F in (*.zip.asc) do gpgv --keyring "%TEMP%\ace.gpg" "%F" "%~nF") && del /f /q "%TEMP%\ace.gpg"
```

```cmd
@echo off
curl -fsSL https://aceofsnakes.github.io/aceofsnakes.gpg | gpg --dearmor > "%TEMP%\ace.gpg"
for %%F in (*.zip.asc) do gpgv --keyring "%TEMP%\ace.gpg" "%%F" "%%~nF"
del /f /q "%TEMP%\ace.gpg"
```
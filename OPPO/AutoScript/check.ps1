$KeyPath = "$env:TEMP\ace.gpg"

curl.exe -fsSL https://aceofsnakes.github.io/aceofsnakes.gpg | gpg --dearmor --yes -o $KeyPath

Get-ChildItem *.zip.asc | ForEach-Object {
    gpgv --keyring $KeyPath $_.Name $_.BaseName
}

Remove-Item $KeyPath -Force

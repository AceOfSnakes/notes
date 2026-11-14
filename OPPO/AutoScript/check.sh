curl -fsSL https://aceofsnakes.github.io/aceofsnakes.gpg | gpg --dearmor > /tmp/ace.gpg
for sig in *.zip.asc; do gpgv --keyring /tmp/ace.gpg "$sig" "${sig%.asc}"; done
rm -f /tmp/ace.gpg
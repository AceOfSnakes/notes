curl -fsSL https://aceofsnakes.github.io/aceofsnakes.gpg | gpg --dearmor > /tmp/ace.gpg
for sig in *.zip.asc; do echo -e "Verify ${sig%.asc}\n" \
  && gpgv --keyring /tmp/ace.gpg "$sig" "${sig%.asc}" \
  && echo -e "\n"; done
rm -f /tmp/ace.gpg
#exec >/dev/tty 2>&1
echo "Starting install Telnet" >> /mnt/sda1/ace-telnet-install.log
mkdir -p /mnt/ubi_boot/oppo-dv-mkv-extras/telnet/ >> /mnt/sda1/ace-telnet-install.log
sync
cp /mnt/sda1/AutoScript/services /mnt/ubi_boot/oppo-dv-mkv-extras/telnet/ >> /mnt/sda1/ace-telnet-install.log
sync
cp /mnt/sda1/AutoScript/start.sh /mnt/ubi_boot/oppo-dv-mkv-extras/telnet/ >> /mnt/sda1/ace-telnet-install.log
sync
chmod +x /mnt/ubi_boot/oppo-dv-mkv-extras/telnet/start.sh
chmod 666 /mnt/ubi_boot/oppo-dv-mkv-extras/telnet/services
sync
ls -al /mnt/ubi_boot/oppo-dv-mkv-extras/telnet/ >> /mnt/sda1/ace-telnet-install.log
echo "Install Telnet finished" >> /mnt/sda1/ace-telnet-install.log



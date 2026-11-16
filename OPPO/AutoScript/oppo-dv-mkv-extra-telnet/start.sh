echo -e "======= telnet extension starts...\n" > /mnt/ubi_boot/oppo-dv-mkv-extras/telnet/out.log
echo root::0:0:root,,,:/root:/bin/sh >/etc/passwd
echo system::100:100:user,,,::/bin/sh >>/etc/passwd
echo -e "password file content /etc/passwd\n" >> /mnt/ubi_boot/oppo-dv-mkv-extras/telnet/out.log
cat /etc/passwd >> /mnt/ubi_boot/oppo-dv-mkv-extras/telnet/out.log
echo -e "services copied...\n" >> /mnt/ubi_boot/oppo-dv-mkv-extras/telnet/out.log
cp /mnt/ubi_boot/oppo-dv-mkv-extras/telnet/services etc/services >> /mnt/ubi_boot/oppo-dv-mkv-extras/telnet/out.log
echo -e "services file content /etc/services\n" >> /mnt/ubi_boot/oppo-dv-mkv-extras/telnet/out.log
cat etc/services >> /mnt/ubi_boot/oppo-dv-mkv-extras/telnet/out.log
sync
/usr/sbin/inetd &
echo -e "======= telnet extension finished...\n" >> /mnt/ubi_boot/oppo-dv-mkv-extras/telnet/out.log
sync
[ -f /mnt/sda1/ace-telnet-install.log ] && cat /mnt/ubi_boot/oppo-dv-mkv-extras/telnet/out.log >> /mnt/sda1/ace-telnet-install.log
sync
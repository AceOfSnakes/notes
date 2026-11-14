#!/bin/sh

#pwd >> /acfg/out

#sync 
#sync

#TARGET_FOLDER=`mount -t vfat | cut -d " " -f 3`/var/blu-ray/`uname -n`/`cat /sys/class/net/eth0/address`
TARGET_FOLDER=`find /mnt/sd* -maxdepth 0`/var/blu-ray/`uname -n`/`cat /sys/class/net/eth0/address`
mkdir -p ${TARGET_FOLDER//:/_}
#cp -rL /acfg/ ${TARGET_FOLDER//:/_}/
#sync

#TARGET_FOLDER=/mnt/sda1/
cat /proc/mtd | while read line; do
    part_name=`echo "$line" | awk 'BEGIN {FS="\"" ; } { print $2 ; }'`
    mtd_name=`echo "$line" | awk 'BEGIN {FS=":" ; } { print $1 ; }'`
    echo "got line: $line"
    echo $part_name
    echo $mtd_name
    if [ empty"$part_name"  = "empty" -o "$mtd_name" = "mtd0" ]; then
      echo "skip $mtd_name"
    else
      cat /dev/$mtd_name > ${TARGET_FOLDER//:/_}/$mtd_name-$part_name.img
      sync
    fi
done
cp  /tmp/dump ${TARGET_FOLDER//:/_}/
sync
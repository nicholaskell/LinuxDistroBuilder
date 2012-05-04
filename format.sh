#!/bin/sh

USB_DEV=$1
USB_MS_DEV=$USB_DEV'1'
USB_EX_DEV=$USB_DEV'2'


echo '---------'
echo DEV: $USB_DEV
echo MS: $USB_MS_DEV
echo EX: $USB_EX_DEV
echo '---------'


sudo umount $USB_DEV
sudo umount $USB_MS_DEV
sudo umount $USB_EX_DEV
sudo parted $USB_DEV --script rm 1
sudo parted $USB_DEV --script rm 2
sudo parted $USB_DEV --script rm 3
sudo parted $USB_DEV --script rm 4  

sudo parted $USB_DEV --script print

sudo parted $USB_DEV --script -- mkpart primary fat32 1 1024
sudo parted $USB_DEV --script -- mkpart primary ext4 1025 -1
sudo parted $USB_DEV --script set 1 boot on

sudo parted $USB_DEV --script -- mkfs 1 fat32

sudo mkfs.ext4 $USB_EX_DEV
sudo tune2fs -c 180 $USB_EX_DEV

sudo parted $USB_DEV --script print

exit


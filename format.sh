#!/bin/sh

USB_DEV=/dev/sdc

sudo parted $USB_DEV --script rm 1
sudo parted $USB_DEV --script rm 2
sudo parted $USB_DEV --script rm 3
sudo parted $USB_DEV --script rm 4  

sudo parted $USB_DEV --script print

sudo parted $USB_DEV --script -- mkpart primary fat32 1 1024
sudo parted $USB_DEV --script -- mkpart primary ext4 1025 -1
sudo parted $USB_DEV --script set 1 boot on

sudo parted $USB_DEV --script -- mkfs 1 fat32

sudo mkfs.ext4 /dev/sdc2
sudo tune2fs -c 180 /dev/sdc2

sudo parted $USB_DEV --script print

exit


sudo /etc/init.d/hal stop                            # Stop GNOME from automounting the drive
sudo fdisk -l /dev/sdc
sudo umount /dev/sdc1    
sudo parted /dev/sdc --script print
sudo parted /dev/sdc --script rm 1                   # Removes the first partition, /dev/sdb1
sudo parted /dev/sdc --script print
sudo parted /dev/sdc --script -- mkpart primary 0 -1 # Makes the partition fill the whole disk
sudo parted /dev/sdc --script print
sudo umount /dev/sdc1
sudo mke2fs /dev/sdc1
sudo tune2fs -j /dev/sdc1
sudo fdisk -l /dev/sdc
sudo /etc/init.d/hal start

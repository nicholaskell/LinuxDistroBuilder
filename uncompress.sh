#!/bin/bash

ISO=/home/nick/Desktop/lupu-528.iso
UNCOMPRESSED_DIR=uncompressed
ISO_MOUNT_DIR=iso_mount
INIT_GZ=initrd.gz
INIT_TREE=initrd-tree

sudo rm -rf $UNCOMPRESSED_DIR
sudo mkdir $UNCOMPRESSED_DIR

sudo mkdir $ISO_MOUNT_DIR
sudo mount -o loop $ISO $ISO_MOUNT_DIR
cd $ISO_MOUNT_DIR

sudo cp * ../$UNCOMPRESSED_DIR/
cd ..
sudo umount $ISO_MOUNT_DIR
sudo rm -rf $ISO_MOUNT_DIR
cd $UNCOMPRESSED_DIR
sudo unsquashfs lupu_528.sfs

sudo mkdir $INIT_TREE
cd $INIT_TREE
sudo zcat ../$INIT_GZ | sudo cpio -d -i
cd ../..

ls $UNCOMPRESSED_DIR
ls $UNCOMPRESSED_DIR/initrd-tree/
ls $UNCOMPRESSED_DIR/squashfs-root/

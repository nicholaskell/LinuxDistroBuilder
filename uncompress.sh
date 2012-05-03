#!/bin/bash

ISO=old.iso
UNCOMPRESSED_DIR=uncompressed
ISO_MOUNT_DIR=iso_mount
INIT_GZ=initrd.gz
INIT_TREE=initrd-tree

rm -rf $UNCOMPRESSED_DIR
mkdir $UNCOMPRESSED_DIR

mkdir $ISO_MOUNT_DIR
mount -o loop $ISO $ISO_MOUNT_DIR
cd $ISO_MOUNT_DIR

cp * ../$UNCOMPRESSED_DIR/
cd ..
umount $ISO_MOUNT_DIR
rm -rf $ISO_MOUNT_DIR
cd $UNCOMPRESSED_DIR
unsquashfs lupu_528.sfs

mkdir $INIT_TREE
cd $INIT_TREE
zcat ../$INIT_GZ | sudo cpio -d -i
cd ../..

ls $UNCOMPRESSED_DIR
ls $UNCOMPRESSED_DIR/initrd-tree/
ls $UNCOMPRESSED_DIR/squashfs-root/

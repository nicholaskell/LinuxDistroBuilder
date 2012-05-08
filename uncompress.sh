#!/bin/bash



ISO=isosBase/bt_528_103.iso
UNCOMPRESSED_DIR=uncom_103
ISO_MOUNT_DIR=iso_mount
INIT_GZ=initrd.gz
INIT_TREE=initrd-tree



function uncompress {
	if [ -e $ISO ]; then
	
		sudo rm -rf $UNCOMPRESSED_DIR
		mkdir $UNCOMPRESSED_DIR

		mkdir $ISO_MOUNT_DIR
		sudo mount -o loop $ISO $ISO_MOUNT_DIR
		cd $ISO_MOUNT_DIR

		cp * ../$UNCOMPRESSED_DIR/
		cd ..
		sudo umount $ISO_MOUNT_DIR
		sudo rm -rf $ISO_MOUNT_DIR
		cd $UNCOMPRESSED_DIR
		sudo unsquashfs lupu_528.sfs

		mkdir $INIT_TREE
		cd $INIT_TREE
		sudo zcat ../$INIT_GZ | sudo cpio -d -i
		cd ../..
		echo "Contents of:$UNCOMPRESSED_DIR:"
		ls $UNCOMPRESSED_DIR
		echo "Contents of:$UNCOMPRESSED_DIR/initrd-tree/:"
		ls $UNCOMPRESSED_DIR/initrd-tree/
		echo "Contents of:$UNCOMPRESSED_DIR/squashfs-root/:"
		ls $UNCOMPRESSED_DIR/squashfs-root/
	else
		echo "$ISO dosent exist"
	fi
}

uncompress

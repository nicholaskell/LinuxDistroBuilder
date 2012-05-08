#!/bin/bash

STARTING_DIR=$PWD
WORKING_DIR=$PWD/working/
BASE_ISO=isosBase/bt_528_103.iso
UNCOMPRESSED_DIR=uncompressed
ISO_MOUNT_DIR=iso_mount
INIT_GZ=initrd.gz
INIT_TREE=initrd-tree

STAGING_DIR=staging

SFS_DIR=squashfs-root
SFS=lupu_528.sfs


NEW_ISO=$WORKING_DIR/new_pup.iso


USB_DEV=$1
USB_MS_DEV=$USB_DEV'1'
USB_EX_DEV=$USB_DEV'2'


CURRENT_VERSION_ISO=bt_528_101.iso

NEW_ISO=$PWD/$CURRENT_VERSION_ISO
USB_MOUNT=usb_mount


function uncompress {
	echo "Starting the uncompress.."
	if [ -e $BASE_ISO ]; then
		cd $WORKING_DIR
		sudo rm -rf $UNCOMPRESSED_DIR
		mkdir $UNCOMPRESSED_DIR
		
echo "Cleaning the mount"
		sudo umount $ISO_MOUNT_DIR
		sudo rm -rf $ISO_MOUNT_DIR
echo "All cleaned up"
		mkdir $ISO_MOUNT_DIR
		sudo mount -o loop ../$BASE_ISO $ISO_MOUNT_DIR
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
		echo "$BASE_ISO dosent exist"
	fi
	echo "Uncompress finished"
}



function compress {
	echo "Starting the comperess.."
	cd $WORKING_DIR
	sudo rm -rf $STAGING_DIR
	mkdir $STAGING_DIR

	cd $UNCOMPRESSED_DIR
	sudo rm $SFS
	sudo mksquashfs $SFS_DIR $SFS

	sudo mv $INIT_GZ pre.$INIT_GZ
	cd $INIT_TREE
	sudo find . | cpio -o -H newc | gzip -9 > ../$INIT_GZ



	cd ../../$STAGING_DIR
	cp -r $STARTING_DIR/base/* .
	rm -rf $INIT_TREE $SFS_DIR
#	cp ../lupusave-fresh.3fs .


	echo "End of the compress.."
}


function buildIso {
	echo "Building ISO..."
	cd $WORKING_DIR
	sudo mkisofs -o $NEW_ISO $STAGING_DIR/
	
	echo "End of building ISO"
}




function format {
	echo "Starting the format..."
	DEV_BASE=/dev/
	if [ ! "$1" ];then
		echo "What dev to format? [$DEV_BASE]"
		read DEVICE;
		USB_DEV=$DEV_BASE$DEVICE
		USB_MS_DEV=$USB_DEV'1'
		USB_EX_DEV=$USB_DEV'2'
		if [ $DEVICE = sda ]; then
			echo "Will not format $USB_DEV"
			exit
		elif [ $DEVICE = sdb ]; then
			echo "Will not format $USB_DEV"
			exit
		fi
		if [ -e $USB_DEV ]; then
			echo "$USB_DEV exists..."
		else
			echo "$USB_DEV does not exist."
			exit
		fi
	else
		USB_DEV=$DEV_BASE$1
		USB_MS_DEV=$USB_DEV'1'
		USB_EX_DEV=$USB_DEV'2'
	fi
	
	echo "Startting the formatting..."


	echo '---------'
	echo DEV: $USB_DEV
	echo MS: $USB_MS_DEV
	echo EX: $USB_EX_DEV
	echo '---------'

	#exit
	#eject $USB_DEV
	#mkdir $USB_MOUNT
	#mount $USB_DEV 
	rm -rf $USB_MOUNT
	#umount $USB_MOUNT
	echo Burn:$NEW_ISO

	echo "Unmounting the partitions..."
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

	sudo mlabel -i $USB_MS_DEV -s ::bayteklinux
	sudo e2label /dev/sdd2 baytekgame

	echo "End fo thte format..."
}




function burn {
	echo "Starting the burn..."


DEV_BASE=/dev/
	if [ ! "$1" ];then
		echo "What dev to burn to? [$DEV_BASE]"
		read DEVICE;
		USB_DEV=$DEV_BASE$DEVICE
		USB_MS_DEV=$USB_DEV'1'
		USB_EX_DEV=$USB_DEV'2'
		if [ $DEVICE = sda ]; then
			echo "Will not format $USB_DEV"
			exit
		elif [ $DEVICE = sdb ]; then
			echo "Will not format $USB_DEV"
			exit
		fi
		if [ -e $USB_DEV ]; then
			echo "$USB_DEV exists..."
		else
			echo "$USB_DEV does not exist."
			exit
		fi
	else
		USB_DEV=$DEV_BASE$1
		USB_MS_DEV=$USB_DEV'1'
		USB_EX_DEV=$USB_DEV'2'
	fi
	


	cd $WORKING_DIR

	echo '---------'
	echo DEV: $USB_DEV
	echo MS: $USB_MS_DEV
	echo EX: $USB_EX_DEV
	echo '---------'

	sudo mkdir $USB_MOUNT
	sudo mount $USB_MS_DEV $USB_MOUNT

	unetbootin installtype=usb method=diskimage isofile=$NEW_ISO targetdevice=$USB_MS_DEV autoinstall=yes

	#sudo umount $USB_MS_DEV
	#rm -rf $USB_MOUNT



	echo "Ended burning"
}


function postProcess {
	echo "Starting the post processing..."
	sudo cp $PWD/misc/syslinux.cfg $WORKING_DIR/usb_mount/syslinux.cfg
	sudo echo "funalley" > $WORKING_DIR/usb_mount/game

ls
	
	
}


bashtrap()
{
    echo "Murdered..."
}



#####################################################################################





echo "What to do"
echo "1) Uncompress"
echo "2) Compress"
echo "3) Build ISO"
echo "4) Format"
echo "5) Burn USB"
echo "6) Post process"
echo "0) Exit"
read case;
#simple case bash structure
# note in this case $case is variable and does not have to
# be named case this is just an example
case $case in
	1) uncompress ;;
	2) compress ;;
	3) buildIso ;;
	4) format ;;
	5) burn ;;
	6) postProcess ;;
	23) compress
		buildIso ;;
	12345) uncompress
		compress
		buildIso
		format
		burn ;;
	45) format
		burn ;;
	0) exit
esac 














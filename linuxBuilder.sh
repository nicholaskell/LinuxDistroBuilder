#!/bin/bash

STARTING_DIR=$PWD
WORKING_DIR=$PWD/working/

UNCOMPRESSED_DIR=uncompressed
OUTPUT_DIR=output
INPUT_DIR=input


INIT_GZ=initrd.gz
INIT_TREE=initrd-tree


KERNEL_FILE=$WORKING_DIR/output/vmlinuz
INITRD_FILE=$WORKING_DIR/output/$INIT_GZ

SFS_DIR=puppy-root
SFS=lupu_528.sfs

USB_DEV=$1


CURRENT_VERSION_ISO=bt_528_104.iso

NEW_ISO=$PWD/$CURRENT_VERSION_ISO
USB_MOUNT=usb_mount
DEVICE=''

AVR_DEV='1'
OS_DEV='1'
GAME_DEV='2'

function uncompressSFS {
	if [ ! "$1" ];then
		SOURCE_SFS=$SFS
	else	
		SOURCE_SFS=$1
	fi
	if [ ! "$2" ];then
		DEST_DIR=$SFS_DIR
	else	
		DEST_DIR=$2
	fi
	COMMAND="sudo unsquashfs -d $DEST_DIR $SOURCE_SFS"
	echo "PWD:$PWD  Calling:$COMMAND"
	sudo $COMMAND
}

function uncompressPuppySFS {
	cd $WORKING_DIR
	cd input
	sudo rm -rf ../uncompressed/$SFS_DIR
	uncompressSFS $SFS ../uncompressed/$SFS_DIR
	cd ../..
}

function uncompressInit {
	NEW_DIR=$1
	mkdir $NEW_DIR
	cd $NEW_DIR
	sudo zcat ../$INIT_GZ | sudo cpio -d -i
	cd ..
}

function uncompressPuppyInit {
	cd $WORKING_DIR
	cd input
	uncompressInit init-tree
	cd ..
	mv input/init-tree uncompressed/init-tree
}

function uncompress {
	cd $WORKING_DIR
	if [ ! "$1" ]; then
		echo "What are we uncompressing?"
		echo "1) Init"
		echo "2) SFS"
		echo "9) ALL"
		echo "0) None"
		read task;
		case $task in
			1) uncompressPuppyInit ;;
			2) uncompressPuppySFS ;;
			9) uncompress ;;
			0) uncompress ;;
		esac
	fi
	echo "Uncompress finished"
}

function compressInit {
	sudo mv $INIT_GZ pre.$INIT_GZ
	cd $INIT_TREE
	sudo find . | cpio -o -H newc | gzip -9 > ../$INIT_GZ
	cd ..

}

function compressSFS {
	dc $WORKING_DIR
	echo "Should we copy in the added files? [y/n]"
	read copyFiles
	if [ $copyFiles = "y" ]; then
		echo "Copying..."
		addFiles
	else
		echo "Not copying the files..."
	fi
	sudo rm $SFS
	mksquashfs $SFS_DIR $SFS
}

function compressPuppySFS {
	cd $WORKING_DIR
	sudo rm -rf $OUTPUT_DIR/$SFS
	sudo mksquashfs $UNCOMPRESSED_DIR/$SFS_DIR $OUTPUT_DIR/$SFS
}

function compress {
	if [ ! "$1" ]; then
		echo "What are we compressing?"
		echo "1) Init"
		echo "2) SFS"
		echo "9) ALL"
		echo "0) None"
		read task;
		case $task in
			1) compressPuppyInit ;;
			2) compressPuppySFS ;;
			9) compress ;;
			0) compress ;;
		esac
	fi
	echo "Uncompress finished"
}


function buildIso {
	cd $WORKING_DIR
	
	
	cp -r ../base/* isoStage/
	cp -r output/* isoStage/
	
	echo "Building ISO: $NEW_ISO "
	
	sudo mv $NEW_ISO $NEW_ISO.prev
	mkisofs -o $NEW_ISO $OUTPUT_DIR/
	
	echo "End of building ISO"
}




function format {
	echo "Starting the format..."
	DEV_BASE=/dev/
	if [ ! "$1" ];then
		echo "What dev to format? [$DEV_BASE]"
		read DEVICE;
		USB_DEV=$DEV_BASE$DEVICE
		USB_MS_DEV=$USB_DEV$OS_DEV
		USB_EX_DEV=$USB_DEV$GAME_DEV
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
		USB_MS_DEV=$USB_DEV$OS_DEV
		USB_EX_DEV=$USB_DEV$GAME_DEV
	fi
	
	echo "Starting the formatting..."


	echo '---------'
	echo DEV: $USB_DEV
	echo MS: $USB_MS_DEV
	echo EX: $USB_EX_DEV
	echo '---------'

	#exit
	#eject $USB_DEV
	#mkdir $USB_MOUNT
	#mount $USB_DEV 
	#sudo rm -rf $USB_MOUNT
	#umount $USB_MOUNT
	echo Burn:$NEW_ISO

	echo "Unmounting the partitions..."
	sudo umount -f $USB_DEV
	sudo umount -f $USB_DEV'1'
	sudo umount -f $USB_DEV'2'
	sudo umount -f $USB_DEV'3'
	sudo umount -f $USB_DEV'4'
	sudo parted $USB_DEV --script rm 1
	sudo parted $USB_DEV --script rm 2
	sudo parted $USB_DEV --script rm 3
	sudo parted $USB_DEV --script rm 4  

	sudo parted $USB_DEV --script print

	#sudo parted $USB_DEV --script -- mkpart primary fat32 1 64
	sudo parted $USB_DEV --script -- mkpart primary fat32 65 1024
	sudo parted $USB_DEV --script -- mkpart primary ext4 1025 -1
	sudo parted $USB_DEV --script set 1 boot on

	#sudo parted $USB_DEV --script -- mkfs $AVR_DEV fat32
	sudo parted $USB_DEV --script -- mkfs $OS_DEV fat32

	sudo mkfs.ext4 $USB_EX_DEV
	sudo tune2fs -c 180 $USB_EX_DEV

	sudo parted $USB_DEV --script print
	
	#sudo mlabel -i $USB_DEV$AVR_DEV -s ::avr
	sudo mlabel -i $USB_DEV$OS_DEV -s ::bayteklinux
	sudo e2label $USB_DEV$GAME_DEV baytekgame

	echo "End fo thte format..."
}




function burn {
	cd $WORKING_DIR
	echo "Starting the burn..."


	DEV_BASE=/dev/
	if [ ! "$1" ];then
		echo "What dev to burn to? [$DEV_BASE]"
		read DEVICE;
		USB_DEV=$DEV_BASE$DEVICE
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
	fi
	
	echo '---------'
	echo DEV: $USB_DEV
	echo "Installing OS to:$USB_DEV$OS_DEV"
	echo ISO: $NEW_ISO
	echo '---------'
	

	if [ -e $NEW_ISO ] ;then
		echo "$NEW_ISO Exists."
	else	
		echo "$NEW_ISO dosent exist."
	fi
	sudo umount -f $USB_MOUNT
	sudo rm -rf $USB_MOUNT
	sudo mkdir $USB_MOUNT
	sudo mount $USB_DEV$OS_DEV $USB_MOUNT
	
	CUSTOM_UNET=false
	
	UNET_COMMAND="sudo unetbootin installtype=usb method=diskimage isofile=$NEW_ISO targetdevice=$USB_DEV$OS_DEV autoinstall=yes"	

	if [ $CUSTOM_UNET = true ]; then
		UNET_COMMAND="sudo unetbootin installtype=usb method=custom kernelfile=$KERNEL_FILE initrdfile=$INITRD_FILE targetdevice=$USB_DEV$OS_DEV autoinstall=yes"	
	fi

	if [ `$UNET_COMMAND` ]; then
		echo "Burn good."
		postProcess
	fi

	#sudo umount $USB_MS_DEV
	#rm -rf $USB_MOUNT



	echo "Ended burning"
}

function addFiles {
	cd $WORKING_DIR
	sudo cp ../resources/adjtime uncompressed/puppy-root/etc/adjtime
	sudo cp ../resources/game uncompressed/puppy-root/usr/local/bin/game
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
read task;
case $task in
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
		burn  $DEVICE;;
	45) format
		burn $DEVICE;;
	0) exit
esac 














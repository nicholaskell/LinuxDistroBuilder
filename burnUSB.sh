CURRENT_VERSION_ISO=bt_528_102.iso

NEW_ISO=$PWD/$CURRENT_VERSION_ISO
USB_MOUNT=usb_mount


if [ ! "$1" ];then
	echo "Must say what to format!"
	exit
fi

USB_DEV=$1
USB_MS_DEV=$USB_DEV'1'
USB_EX_DEV=$USB_DEV'2'

#eject $USB_DEV
#mkdir $USB_MOUNT
#mount $USB_DEV 
rm -rf $USB_MOUNT
#umount $USB_MOUNT
echo Burn:$NEW_ISO


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

sudo mkdir $USB_MOUNT
sudo mount $USB_MS_DEV $USB_MOUNT

unetbootin installtype=usb method=diskimage isofile=$NEW_ISO targetdevice=$USB_MS_DEV autoinstall=yes

sudo umount $USB_MS_DEV
rm -rf $USB_MOUNT

NEW_ISO=$PWD/new_pup.iso
USB_DEV=/dev/sdb1
USB_MOUNT=usb_mount

#eject $USB_DEV
#mkdir $USB_MOUNT
#mount $USB_DEV 
#rm -rf $USB_MOUNT/*
#umount $USB_MOUNT
echo Burn:$NEW_ISO

unetbootin installtype=usb method=diskimage isofile=$NEW_ISO targetdevice=$USB_DEV autoinstall=yes

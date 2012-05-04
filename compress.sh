#!/bin/bash


echo "Run as root!"

UNCOMPRESSED_DIR=uncompressed
STAGING_DIR=staging
INIT_GZ=initrd.gz
INIT_TREE=initrd-tree
SFS_DIR=squashfs-root
SFS=lupu_528.sfs

rm -rf $STAGING_DIR
mkdir $STAGING_DIR

cd $UNCOMPRESSED_DIR
rm $SFS
mksquashfs $SFS_DIR $SFS

mv $INIT_GZ pre.$INIT_GZ
cd $INIT_TREE
find . | cpio -o -H newc | gzip -9 > ../$INIT_GZ



cd ../../$STAGING_DIR
cp ../$UNCOMPRESSED_DIR/boot.cat .
cp ../$UNCOMPRESSED_DIR/boot.msg .
cp ../$UNCOMPRESSED_DIR/help2.msg .
cp ../$UNCOMPRESSED_DIR/help.msg .
cp ../$UNCOMPRESSED_DIR/$INIT_GZ .
cp ../$UNCOMPRESSED_DIR/isolinux.bin .
cp ../$UNCOMPRESSED_DIR/isolinux.cfg .
cp ../$UNCOMPRESSED_DIR/logo.16 .
cp ../$UNCOMPRESSED_DIR/$SFS .
cp ../$UNCOMPRESSED_DIR/vmlinuz .
#cp ../lupusave-fresh.3fs .





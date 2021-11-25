# This script is for the CrepeOS Installer, version 10.0
#!/bin/sh

if test "`whoami`" != "root" ; then
	echo -e "You must be logged in as \e[1;31mroot\e[0m to build CrepeOS."
	echo -e "Enter 'su' or 'sudo bash' to switch to \e[1;31mroot.\e[0m"
	exit
fi

echo "Welcome to the CrepeOS Alpha 0.3.1 builder."

cd OS

echo -e "\e[1;34m[building]\e[0m Backing up any existing image files"
mv image/crepeos.flp image/imgbak/crepeos.flp.bak -f
mv image/crepeos.iso image/imgbak/crepeos.iso.bak -f
sleep 0.5
if [ ! -e image/crepeos.flp ]
then
	echo "Creating floppy image"
	mkdosfs -C image/crepeos.flp 1440 || exit
fi


echo -e "\e[1;34m[building]\e[0mAssembling bootloader"

nasm -O0 -w+orphan-labels -f bin -o system/osldr/osldr.bin system/osldr/osldr.asm || exit
nasm -O0 -w+orphan-labels -f bin -o system/osldr/osclose.bin system/osldr/osclose.asm || exit

echo -e "\e[1;34m[building]\e[0m Assembling kernel"

cd system
nasm -O0 -w+orphan-labels -f bin -o oskrnl.bin oskrnl.asm || exit
cd ..

echo -e "\e[1;34m[building]\e[0m Assembling programs"

cd program

for i in *.asm
do
	nasm -O0 -w+orphan-labels -f bin $i -o `basename $i .asm`.bin || exit
done
cd ..

echo -e "\e[1;34m[building]\e[0m Adding bootloader to floppy image"

dd status=noxfer conv=notrunc if=system/osldr/osldr.bin of=image/crepeos.flp || exit

echo -e "\e[1;34m[building]\e[0m Copying files to image"

rm -rf tmp-loop

mkdir tmp-loop && mount -o loop -t vfat image/crepeos.flp tmp-loop && cp system/oskrnl.bin tmp-loop/

cp program/*.bin program/*.bas tmp-loop


sleep 0.5

echo -e "\e[1;34m[building]\e[0m Unmounting loopback floppy"

umount tmp-loop || exit

echo "\e[1;34m[building]\e[0m Removing any temporary files used"

rm -rf tmp-loop

sleep 0.25

echo -e "\e[1;34m[building]\e[0m Creating CD-ROM ISO image"

rm  image/crepeos.iso
mkisofs -quiet -V 'CrepeOSISO' -input-charset iso8859-1 -o image/crepeos.iso -b crepeos.flp image/ || exit
sleep 0.25

echo -e '\e[1;32m [done] Starting CrepeOS now via QEMU...'
cd image
qemu-system-x86_64 -cdrom crepeos.iso

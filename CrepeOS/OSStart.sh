# This script is for the CrepeOS Installer, version 10.0

if test "`whoami`" != "root" ; then
	echo "You must be logged in as root to build CrepeOS."
	echo "Enter 'su' or 'sudo bash' to switch to root."
	exit
fi

echo "Welcome to the CrepeOS Alpha 0.3 builder."

cd OS

echo "Backing up any existing image files"
mv image/crepeos.flp image/imgbak/crepeos.flp.bak -f
mv image/crepeos.iso image/imgbak/crepeos.iso.bak -f
sleep 0.5
if [ ! -e image/crepeos.flp ]
then
	echo "Creating floppy image"
	mkdosfs -C image/crepeos.flp 1440 || exit
fi


echo "Assembling bootloader"

nasm -O0 -w+orphan-labels -f bin -o system/osldr/osldr.bin system/osldr/osldr.asm || exit


echo "Assembling kernel"

cd system
nasm -O0 -w+orphan-labels -f bin -o oskrnl.bin oskrnl.asm || exit
cd ..

echo "Assembling programs"

cd program

for i in *.asm
do
	nasm -O0 -w+orphan-labels -f bin $i -o `basename $i .asm`.bin || exit
done
cd ..

echo "Adding bootloader to floppy image"

dd status=noxfer conv=notrunc if=system/osldr/osldr.bin of=image/crepeos.flp || exit

echo "Copying files to image"

rm -rf tmp-loop

mkdir tmp-loop && mount -o loop -t vfat image/crepeos.flp tmp-loop && cp system/oskrnl.bin tmp-loop/

cp program/*.bin program/*.bas tmp-loop


sleep 0.5

echo "Unmounting loopback floppy"

umount tmp-loop || exit

echo "Removing any temporary files used"

rm -rf tmp-loop

sleep 0.25

echo "Creating CD-ROM ISO image"

rm  image/crepeos.iso
mkisofs -quiet -V 'CrepeOSISO' -input-charset iso8859-1 -o image/crepeos.iso -b crepeos.flp image/ || exit
sleep 0.25

echo 'Starting CrepeOS now via QEMU...'
cd image
qemu-system-x86_64 -cdrom crepeos.iso

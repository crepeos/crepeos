# This is the script to revert CrepeOS to its last image stored.
cd ..
cd ..
sleep 1
echo "This will ERASE all data created on the current image."
echo "Press any key to continue, or the Close button to stop. The process will continue in 10 seconds."
read -t 10 -n 1

cd OS
sudo mv image/imgbak/crepeos.flp.bak image/crepeos.flp -f
sudo mv image/imgbak/crepeos.iso.bak image/crepeos.iso -f

echo "Done, proceeding to start CrepeOS."
cd image
sudo qemu-system-i386 -fda crepeos.flp

# rootDrop

get root on embd

* test bench
	qemu with uboot to stop on;

* kernel params
	run level 
		how to know which even supported
	boot params from dtb override
	recovary root password or not
* uboot:
	debug run show full command of boot seq
	read file (sahdow)
	write files ( overwrite string in shadow)

/dev/shadow struct
tools to brute

## playground
make run SHARE=./container  

mmc info
mmc list
mmc dev
=> mmc part  
=> ext4ls mmc 0:1 /


=> fatls mmc 0:0


setenv loadaddr 0x60100000              
=> fatload mmc 0:0 $loadaddr testFile
md.b $loadaddr
md.l $loadaddr
!!!!!!!!!!!!!!!!!  mm.b 0x60100020 ///  to change data
!!!!!!!!!!!!!!!!!  fatwrite mmc 0:0 $loadaddr testFile $filesize  /// write back

# rootDrop

tasks:
* get root on embd

##  test bench
* build docker for playground ( make build / make run SHARE=./container )
* Build Buildroot using qemu_arm_vexpress_defconfig, including:

```
        U-Boot			|	( use buildroot.config)
        Kernel (zImage)		|  ===> make build
        DTB			|
        RootFS			|

	run qemu with uboot to stop on;		=> make run
```

## playground
* [uboot write mmc](./play1_uboot_write.md)
* [uboot printenv](./play1_uboot_printenv.md)
* [uboot boot.scr](

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



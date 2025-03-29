# playground

* Build Buildroot using qemu_arm_vexpress_defconfig, including:
        U-Boot
        Kernel (zImage)
        DTB
        RootFS

* Prepare an SD card image:
        Copies zImage and dtb onto it using FAT32

* boot.scr is a binary file with a small U-Boot header + your commands. U-Boot will:
	Automatically scan the SD card for boot.scr
	Load and execute it (if present)


* Run QEMU:
        Drops into U-Boot with SD card and rootfs
        U-Boot loads a boot.scr (compiled script) to:
            Load kernel + DTB
            Set bootargs
            Run bootz


## RND?

uboot boot pxe env;
```
[*]   Bootdev support for extlinux boot over network 
```
# extlinux

extlinux.conf is a configuration file used by the EXTLINUX bootloader (part of the Syslinux family). You’ll often find EXTLINUX in lightweight or embedded Linux setups that use Syslinux-style bootloaders, particularly when booting from filesystems like ext2/ext3/ext4. In these scenarios, EXTLINUX reads its settings from the extlinux.conf file in the root or a boot directory to figure out which kernel to load, where to find the initrd (if used), and what kernel command-line parameters to pass at boot.

* example

```

TIMEOUT 50
DEFAULT linux
MENU TITLE My System Boot Menu

LABEL linux
  MENU LABEL Linux
  LINUX /boot/vmlinuz
  INITRD /boot/initrd.img
  APPEND root=/dev/sda1 ro console=tty1

```

used for:
* Kernel and Initrd Selection
* Boot Menus* 
* Kernel Parameters
* Fallback Options


## using by uboot

U-Boot gained the ability to parse extlinux.conf files so that it can boot a Linux system in a way similar to what Syslinux/EXTLINUX does on PCs. Rather than relying on a custom boot script or a boot.scr file, U-Boot can directly load and interpret extlinux.conf from a partition (often an ext4 partition), then use the information in that file (kernel path, initrd path, device tree path, kernel arguments, etc.) to boot the system.

Advantages of using extlinux.conf with U-Boot

* Single-File Boot Configuration: Instead of scattering boot logic in environment variables or multiple script files, you have a single, easy-to-edit extlinux.conf
* Multi-Kernel, Multi-Entry Support: As with Syslinux, you can define multiple entries in extlinux.conf (e.g., different kernel versions or different device trees).

###  is build it?

* U-Boot must be built with the extlinux (sometimes called “Syslinux” or “EXTLINUX”) configuration feature enabled.

```
  │ Symbol: BOOTMETH_EXTLINUX [=y]                                                                   │  
  │ Type  : bool                                                                                     │  
  │ Prompt: Bootdev support for extlinux boot                                                        │  
  │   Location:                                                                                      │  
  │     -> Boot options                                                                              │  
  │       -> Boot images                                                                             │  
  │ (1)     -> Standard boot (BOOTSTD [=y])   
```


```
=> sysboot
sysboot - command to get and boot from syslinux files

Usage:
sysboot [-p] <interface> <dev[:part]> <ext2|fat|any> [addr] [filename]
    - load and parse syslinux menu file 'filename' from ext2, fat
      or any filesystem on 'dev' on 'interface' to address 'addr'
=> 

```

### auto load ?

By default, many modern U-Boot configurations include logic (in their environment variables and bootscripts) that looks for a file named extlinux.conf on specific storage devices and partitions.

for example:

```
# Simplified example of how U-Boot might look for extlinux.conf
if test -e mmc 0:1 /boot/extlinux.conf; then
  sysboot mmc 0:1 any $fdt_addr /boot/extlinux.conf
else
  echo "extlinux.conf not found, fallback to another boot method"
fi
```


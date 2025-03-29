

## directly from u-boot command line

```
setenv devtype mmc
setenv devnum 0
load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} zImage
load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} vexpress-v2p-ca9.dtb

setenv bootargs "root=/dev/mmcblk0p2 rw console=ttyAMA0,38400n8"

bootz ${kernel_addr_r} - ${fdt_addr_r}

```

## using boot.scr

## using extlinux.conf

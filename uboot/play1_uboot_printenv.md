# uboot printenv 


```
buildroot config -> Bootloaders :

      (vexpress_ca9x4) Board defconfig

so uboot config will be:
	./buildroot/output/build/uboot-2024.01/configs/vexpress_ca9x4_defconfig

```


```

./buildroot/output/build/uboot-2024.01/include/configs/vexpress_ca9x4.h 
that include #include "vexpress_common.h"

./buildroot/output/build/uboot-2024.01/include/configs/vexpress_common.h

#define CFG_EXTRA_ENV_SETTINGS \
                "loadaddr=0x60100000\0" \
                "kernel_addr_r=0x60100000\0" \
                "fdt_addr_r=0x60000000\0" \
                "bootargs=console=tty0 console=ttyAMA0,38400n8\0" \
                BOOTENV \
                "console=ttyAMA0,38400n8\0" \
                "dram=1024M\0" \
                "root=/dev/sda1 rw\0" \
                "mtd=armflash:1M@0x800000(uboot),7M@0x1000000(kernel)," \
                        "24M@0x2000000(initrd)\0" \
                "flashargs=setenv bootargs root=${root} console=${console} " \
                        "mem=${dram} mtdparts=${mtd} mmci.fmax=190000 " \
                        "devtmpfs.mount=0  vmalloc=256M\0" \
                "bootflash=run flashargs; " \
                        "cp ${ramdisk_addr} ${ramdisk_addr_r} ${maxramdisk}; " \
                        "bootm ${kernel_addr} ${ramdisk_addr_r}\0" \
                "fdtfile=" CONFIG_DEFAULT_FDT_FILE "\0" \
                "myCustomString= AAAAAAAAAAAAAAAAAAAAAAAA \0"






=> printenv  myCustomString
myCustomString= AAAAAAAAAAAAAAAAAAAAAAAA


```

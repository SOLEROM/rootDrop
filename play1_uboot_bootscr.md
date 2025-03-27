# uboot boot scr

make sure the > make sdcard_fat will create  mbr+partition !!!

so that :

```
fdisk -l sdcard.img 
Disk sdcard.img: 64 MiB, 67108864 bytes, 131072 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x8f559973

Device      Boot Start    End Sectors Size Id Type
sdcard.img1       2048 131071  129024  63M  c W95 FAT32 (LBA)
```

then uboot will see partition tables:

```
=> mmc part

Partition Map for MMC device 0  --   Partition Type: DOS

Part	Start Sector	Num Sectors	UUID		Type
  1	2048      	129024    	30654bbb-01	0c


```

then uboot:

```
Scanning mmc 0:1...
Found U-Boot script /boot.scr

```

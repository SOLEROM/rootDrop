# uboot write

```
mmc info
mmc list
mmc dev
=> mmc part  
=> ext4ls mmc 0:1 /
=> fatls mmc 0:0
```

## test play

```
=> fatls mmc 0:0
      281   boot.scr
       43   testFile
    14081   vexpress-v2p-ca9.dtb
  5330048   zImage

4 file(s), 0 dir(s)

=> setenv loadaddr 0x60100000              
=> fatload mmc 0:0 $loadaddr testFile
43 bytes read in 5 ms (7.8 KiB/s)
=> md.b $loadaddr
60100000: 74 68 69 73 20 69 73 20 74 65 73 74 20 66 69 6c  this is test fil
60100010: 65 0a 6c 69 6e 65 32 0a 6c 69 6e 65 33 0a 6c 69  e.line2.line3.li
60100020: 6e 65 34 0a 73 65 63 72 65 74 0a 00 00 00 00 00  ne4.secret......


// change and write back


=> mm.b 0x60100020
60100020: 6e ? 00
60100021: 65 ? 00
60100022: 34 ? => <INTERRUPT>
=> fatwrite mmc 0:0 $loadaddr testFile $filesize
43 bytes written in 12 ms (2.9 KiB/s)

//exit uboot

```

```
sudo mount -o loop sdcard.img /mnt/

cat /mnt/testFile 
this is test file
line2
line3
li4
secret


```

# device options

options:

```
mmc list
blk list

```


## enable virtio

```
│ Symbol: VIRTIO_MMIO [=n]                                                                         │  
  │ Type  : bool                                                                                     │  
  │ Prompt: Platform bus driver for memory mapped virtio devices                                     │  
  │   Location:                                                                                      │  
  │     -> Device Drivers                                                                            │  
  │ (1)   -> VirtIO Drivers 

```

```
  │ Symbol: VIRTIO_BLK [=n]                                                                          │  
  │ Type  : bool                                                                                     │  
  │ Prompt: virtio block driver                                                                      │  
  │   Location:                                                                                      │  
  │     -> Device Drivers                                                                            │  
  │ (1)   -> VirtIO Drivers   
```

```
  │ │            [*] Composable virtual block devices (blkmap)                                     │ │  
```
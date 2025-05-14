# kexec

sudo apt install kexec-tools

```
sudo kexec -l /boot/vmlinuz  --initrd=/boot/initrd.img  --command-line="$(cat /proc/cmdline) 1"
sudo kexec -e
```

### ubu24

```
sudo kexec -l /boot/vmlinuz  --initrd=/boot/initrd.img  --command-line="$(cat /proc/cmdline) systemd.unit=rescue.target  && sudo kexec -e
```

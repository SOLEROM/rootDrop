BUILDROOT_TAG = 2024.02
BUILDROOT_REPO = https://github.com/buildroot/buildroot.git
BUILDROOT_DIR   = buildroot
OUTPUT_DIR = $(BUILDROOT_DIR)/output/images
SD_IMAGE = sdcard.img
UBOOT_SCRIPT = boot.scr

.PHONY: all build boot1 boot2 run sdcard
all: run

clone:
	@if [ ! -d "$(BUILDROOT_DIR)/.git" ]; then \
		echo "Cloning Buildroot..."; \
		git clone --depth 1 --branch $(BUILDROOT_TAG) $(BUILDROOT_REPO) $(BUILDROOT_DIR); \
	else \
		echo "Buildroot already cloned, skipping."; \
	fi


buildroot: clone
	cd $(BUILDROOT_DIR) && make qemu_arm_vexpress_defconfig
	cp buildroot.config $(BUILDROOT_DIR)/.config
	cd $(BUILDROOT_DIR) && make
	tree $(OUTPUT_DIR)
build: buildroot


$(UBOOT_SCRIPT): uboot_script.txt
	mkimage -A arm -T script -C none -n "Boot Script" -d uboot_script.txt $(UBOOT_SCRIPT)

sdcard_fat: $(UBOOT_SCRIPT)
	rm -f $(SD_IMAGE)
	mkdir -p sdcard
	cp $(OUTPUT_DIR)/zImage sdcard/
	cp $(OUTPUT_DIR)/vexpress-v2p-ca9.dtb sdcard/
	cp $(UBOOT_SCRIPT) sdcard/
	dd if=/dev/zero of=$(SD_IMAGE) bs=1M count=64
	mkfs.vfat $(SD_IMAGE)
	# Copy using mtools (no mount!)
	mcopy -i $(SD_IMAGE) -s sdcard/* ::

sdcard_ext: $(UBOOT_SCRIPT)
	@echo "Removing any existing image..."
	rm -f $(SD_IMAGE)
	@echo "Creating a 64MB sparse file..."
	dd if=/dev/zero of=$(SD_IMAGE) bs=1M count=64
	@echo "Creating an MBR partition table and one ext4 partition..."
	parted --script $(SD_IMAGE) mklabel msdos
	parted --script $(SD_IMAGE) mkpart primary ext4 1MiB 100%
	@echo "Formatting the partition inside the image with ext4 (1MiB offset)..."
	mkfs.ext4 -F -v -E offset=1048576 $(SD_IMAGE)
	@echo "Mounting the partition from the image at ./mnt_sdcard..."
	mkdir -p mnt_sdcard
	sudo mount -o loop,offset=1048576 $(SD_IMAGE) mnt_sdcard
	@echo "Copying files to the image..."
	sudo cp $(OUTPUT_DIR)/zImage                mnt_sdcard
	sudo cp $(OUTPUT_DIR)/vexpress-v2p-ca9.dtb  mnt_sdcard
	sudo cp $(UBOOT_SCRIPT)                     mnt_sdcard
	@echo "Unmounting..."
	sudo umount mnt_sdcard
	rmdir mnt_sdcard
	@echo "Done. Created and populated sdcard_ext.img with an ext4 partition."



boot_only_uboot:
	qemu-system-arm \
	-M vexpress-a9 -m 256M \
	-nographic \
	-kernel $(OUTPUT_DIR)/u-boot \
	-serial mon:stdio
boot1: boot_only_uboot

boot_no_uboot:
	qemu-system-arm \
	-M vexpress-a9 -m 256M \
	-nographic \
	-kernel $(OUTPUT_DIR)/zImage \
	-dtb $(OUTPUT_DIR)/vexpress-v2p-ca9.dtb \
	-append "console=ttyAMA0 root=/dev/mmcblk0 rw" \
	-sd $(OUTPUT_DIR)/rootfs.ext2 
boot2: boot_no_uboot


run:
	qemu-system-arm \
		-M vexpress-a9 \
		-m 256M \
		-nographic \
		-kernel $(OUTPUT_DIR)/u-boot \
		-sd $(SD_IMAGE) \
		-drive file=$(OUTPUT_DIR)/rootfs.ext2,if=none,format=raw,id=hd0 -device virtio-blk-device,drive=hd0 \
		-audiodev none,id=noaudio



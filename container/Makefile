BUILDROOT_TAG = 2024.02
BUILDROOT_REPO = https://github.com/buildroot/buildroot.git
BUILDROOT_DIR   = buildroot
OUTPUT_DIR = $(BUILDROOT_DIR)/output/images
SD_IMAGE = sdcard.img
UBOOT_SCRIPT = boot.scr

.PHONY: all buildroot build run
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

sdcard: $(UBOOT_SCRIPT)
	mkdir -p sdcard
	cp $(OUTPUT_DIR)/zImage sdcard/
	cp $(OUTPUT_DIR)/vexpress-v2p-ca9.dtb sdcard/
	cp $(UBOOT_SCRIPT) sdcard/
	dd if=/dev/zero of=$(SD_IMAGE) bs=1M count=64
	mkfs.vfat $(SD_IMAGE)
	mkdir -p /mnt/tmp_sd && sudo mount -o loop $(SD_IMAGE) /mnt/tmp_sd
	sudo cp sdcard/* /mnt/tmp_sd/
	sudo umount /mnt/tmp_sd


run: all
	qemu-system-arm \
		-M vexpress-a9 \
		-m 256M \
		-nographic \
		-kernel $(OUTPUT_DIR)/u-boot.bin \
		-sd $(SD_IMAGE) \
		-drive file=$(OUTPUT_DIR)/rootfs.ext2,if=sd,format=raw,index=1



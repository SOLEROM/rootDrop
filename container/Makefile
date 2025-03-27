.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo ""
	@echo "Makefile targets:"
	@echo "  help                Show this help message"
	@echo "  clone               Clone buildroot if not already cloned"
	@echo "  build_config        Run Buildroot menuconfig"
	@echo "  uboot_config        Run U-Boot menuconfig"
	@echo "  buildroot           Build Buildroot using qemu_arm_vexpress_defconfig"
	@echo "  build               Alias for buildroot"
	@echo "  sdcard_fat          Create FAT-formatted SD card image with boot files"
	@echo "  sdcard_ext          Create EXT4-formatted SD card image with boot files"
	@echo "  boot_only_uboot     Boot U-Boot only in QEMU"
	@echo "  boot1               Alias for boot_only_uboot"
	@echo "  boot_no_uboot       Boot directly into Linux kernel without U-Boot"
	@echo "  boot2               Alias for boot_no_uboot"
	@echo "  run                 Boot full system via QEMU using U-Boot and SD image"
	@echo ""



# Buildroot related
.PHONY: clone
clone: ## Clone buildroot if not already cloned
	@if [ ! -d "$(BUILDROOT_DIR)/.git" ]; then \
		echo "Cloning Buildroot..."; \
		git clone --depth 1 --branch $(BUILDROOT_TAG) $(BUILDROOT_REPO) $(BUILDROOT_DIR); \
	else \
		echo "Buildroot already cloned, skipping."; \
	fi

.PHONY: build_config
build_config: ## Run buildroot menuconfig
	make -C $(BUILDROOT_DIR) menuconfig

.PHONY: uboot_config
uboot_config: ## Run U-Boot menuconfig
	make -C $(BUILDROOT_DIR) uboot-menuconfig

.PHONY: buildroot
buildroot: clone ## Build buildroot using qemu_arm_vexpress_defconfig
	cd $(BUILDROOT_DIR) && make qemu_arm_vexpress_defconfig
	cp buildroot.config $(BUILDROOT_DIR)/.config
	cd $(BUILDROOT_DIR) && make
	tree $(OUTPUT_DIR)

.PHONY: build
build: buildroot ## Alias for buildroot

# U-Boot script
$(UBOOT_SCRIPT): uboot_script.txt ## Build U-Boot boot.scr script
	mkimage -A arm -T script -C none -n "Boot Script" -d uboot_script.txt $(UBOOT_SCRIPT)

# SD card FAT
.PHONY: sdcard_fat
sdcard_fat: $(UBOOT_SCRIPT) ## Create FAT-formatted SD card image
	rm -f $(SD_IMAGE)
	mkdir -p sdcard
	cp $(OUTPUT_DIR)/zImage sdcard/
	cp $(OUTPUT_DIR)/vexpress-v2p-ca9.dtb sdcard/
	cp $(UBOOT_SCRIPT) sdcard/
	cp testFile sdcard/
	dd if=/dev/zero of=$(SD_IMAGE) bs=1M count=64
	mkfs.vfat $(SD_IMAGE)
	mcopy -i $(SD_IMAGE) -s sdcard/* ::

# SD card ext4
.PHONY: sdcard_ext
sdcard_ext: $(UBOOT_SCRIPT) ## Create ext4-formatted SD card image
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
	sudo cp testFile                            mnt_sdcard
	@echo "Unmounting..."
	sudo umount mnt_sdcard
	rmdir mnt_sdcard
	@echo "Done. Created and populated sdcard_ext.img with an ext4 partition."

# Boot options
.PHONY: boot_only_uboot
boot_only_uboot: ## Boot only U-Boot in QEMU
	qemu-system-arm \
		-M vexpress-a9 -m 256M \
		-nographic \
		-kernel $(OUTPUT_DIR)/u-boot \
		-serial mon:stdio

.PHONY: boot1
boot1: boot_only_uboot ## Alias for boot_only_uboot

.PHONY: boot_no_uboot
boot_no_uboot: ## Boot directly without U-Boot
	qemu-system-arm \
		-M vexpress-a9 -m 256M \
		-nographic \
		-kernel $(OUTPUT_DIR)/zImage \
		-dtb $(OUTPUT_DIR)/vexpress-v2p-ca9.dtb \
		-append "console=ttyAMA0 root=/dev/mmcblk0 rw" \
		-sd $(OUTPUT_DIR)/rootfs.ext2

.PHONY: boot2
boot2: boot_no_uboot ## Alias for boot_no_uboot

.PHONY: run
run: ## Full boot via QEMU using U-Boot and SD image
	qemu-system-arm \
		-M vexpress-a9 \
		-m 256M \
		-nographic \
		-kernel $(OUTPUT_DIR)/u-boot \
		-sd $(SD_IMAGE) \
		-drive file=$(OUTPUT_DIR)/rootfs.ext2,if=none,format=raw,id=hd0 -device virtio-blk-device,drive=hd0 \
		-audiodev none,id=noaudio

.PHONY: all
all: help


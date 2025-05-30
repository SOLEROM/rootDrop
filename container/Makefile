# Variables
BUILDROOT_TAG = 2024.02
BUILDROOT_REPO = https://github.com/buildroot/buildroot.git
BUILDROOT_DIR = buildroot
OUTPUT_DIR = $(BUILDROOT_DIR)/output/images
SD_IMAGE = sdcard.img
UBOOT_SCRIPT = boot.scr

.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo ""
	@echo "Makefile targets:"
	@echo "  help                		Show this help message"
	@echo "  clone               		Clone buildroot if not already cloned"
	@echo "  build_config        		Run Buildroot menuconfig"
	@echo "  build | buildroot   		Build Buildroot using qemu_arm_vexpress_defconfig"
	@echo " >>> uboot 					"
	@echo "  	uboot_config        	"
	@echo "  	uboot_clean 			"
	@echo " 	uboot_rebuild 			"
	@echo " >>> sdcard 					"
	@echo "  sdcard_fat          		Create FAT-formatted SD card image with boot files"
	@echo "  sdcard_ext          		Create EXT4 SD card 1 partition for boot"
	@echo "  sdcard_ext2          		Create EXT4 SD 2 partitions (fat/ext4)"
	@echo " >>> emulation runers	"
	@echo "  boot1| boot_only_uboot     Boot U-Boot only in QEMU"
	@echo "  boot2| boot_no_uboot       Boot directly into Linux kernel without U-Boot"
	@echo "  run                 		Boot full system via QEMU using U-Boot and SD image"
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

.PHONY: uboot_clean
uboot_clean:
	make -C buildroot uboot-dirclean

.PHONY: uboot_rebuild
uboot_rebuild:
	make -C buildroot uboot-reconfigure

.PHONY: kernel_config
kernel_config:
	make -C buildroot linux-menuconfig


.PHONY: buildroot
buildroot: clone ## Build buildroot using qemu_arm_vexpress_defconfig
	cd $(BUILDROOT_DIR) && make qemu_arm_vexpress_defconfig
	cp buildroot.config $(BUILDROOT_DIR)/.config
	cp uboot.config $(BUILDROOT_DIR)/output/build/uboot-2024.01/.config
	cd $(BUILDROOT_DIR) && make
	tree $(OUTPUT_DIR)

.PHONY: build
build: buildroot ## Alias for buildroot

# U-Boot script
.PHONY: uboot_script
uboot_script: $(UBOOT_SCRIPT)
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
	# Create partition table and single FAT partition
	parted --script $(SD_IMAGE) mklabel msdos
	parted --script $(SD_IMAGE) mkpart primary fat32 1MiB 100%
	# Format the partition (at 1MiB offset)
	mkfs.vfat -n BOOT -F 32 -v $(SD_IMAGE) --offset=2048	
	# Copy files into partition using mtools (1MiB offset)
	mcopy -i $(SD_IMAGE)@@1048576 -s sdcard/* ::

# SD card ext4
.PHONY: sdcard_ext
sdcard_ext: 
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
	sudo cp $(UBOOT_SCRIPT)						mnt_sdcard
	sudo mkdir -p mnt_sdcard/extlinux
	sudo cp extlinux.conf                       mnt_sdcard/extlinux/
	sudo cp testFile                            mnt_sdcard
	@echo "Unmounting..."
	sudo umount mnt_sdcard
	rmdir mnt_sdcard
	@echo "Done. Created and populated $(SD_IMAGE) with an ext4 partition."

.PHONY: sdcard_ext2
sdcard_ext2: ## Create p1:FAT/p2:ext4 formatted SD card image with two partitions
	@echo "Removing any existing image..."
	rm -f $(SD_IMAGE)

	@echo "Creating a 128MB sparse file..."
	dd if=/dev/zero of=$(SD_IMAGE) bs=1M count=128

	@echo "Creating an MBR partition table with two partitions..."
	parted --script $(SD_IMAGE) mklabel msdos
	parted --script $(SD_IMAGE) mkpart primary fat32 1MiB 65MiB
	parted --script $(SD_IMAGE) mkpart primary ext4 65MiB 100%

	# Format the partition (at 1MiB offset)
	mkfs.vfat -n BOOT -F 32 -v $(SD_IMAGE) --offset=2048

	@echo "Formatting partition 2 with ext4 at offset 65MiB..."
	mkfs.ext4 -F -v -E offset=68157440 $(SD_IMAGE)

	@echo "Mounting partition 1 from image at ./mnt_sdcard1..."
	mkdir -p mnt_sdcard1
	sudo cp $(OUTPUT_DIR)/zImage               mnt_sdcard1
	sudo cp $(OUTPUT_DIR)/vexpress-v2p-ca9.dtb mnt_sdcard1
	sudo cp $(UBOOT_SCRIPT)					   mnt_sdcard1
	sudo mkdir -p mnt_sdcard1/extlinux
	sudo cp extlinux.conf                      mnt_sdcard1/extlinux/
	sudo cp testFile                           mnt_sdcard1
	# Copy files into partition using mtools (1MiB offset)
	mcopy -i $(SD_IMAGE)@@1048576 -s mnt_sdcard1/* ::

	@echo "Mounting partition 2 from image at ./mnt_sdcard2..."
	mkdir -p mnt_sdcard2
	sudo mount -o loop,offset=68157440 $(SD_IMAGE) mnt_sdcard2
	@echo "Copying contents of rootfs.ext2 to partition 2..."
	sudo tar xf $(OUTPUT_DIR)/rootfs.tar -C mnt_sdcard2
	sudo umount mnt_sdcard2
	rmdir mnt_sdcard2

	@echo "Done. Created and populated $(SD_IMAGE) with two ext4 partitions."

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

#  TODO: had some issues with  virtio-blk-device
# .PHONY: run
# run: 
# 	qemu-system-arm \
# 		-M vexpress-a9 \
# 		-m 256M \
# 		-nographic \
# 		-kernel $(OUTPUT_DIR)/u-boot \
# 		-sd $(SD_IMAGE) \
# 		-drive file=$(OUTPUT_DIR)/rootfs.ext2,if=none,format=raw,id=hd0 -device virtio-blk-device,drive=hd0 \
# 		-audiodev none,id=noaudio

.PHONY: run
run: 
	qemu-system-arm \
		-M vexpress-a9 \
		-m 256M \
		-nographic \
		-kernel $(OUTPUT_DIR)/u-boot \
		-sd $(SD_IMAGE) \
		-audiodev none,id=noaudio


.PHONY: all
all: help


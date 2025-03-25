BUILDROOT_TAG = 2024.02
BUILDROOT_REPO = https://github.com/buildroot/buildroot.git
BUILDROOT_DIR   = buildroot
IMAGES_DIR = $(BUILDROOT_DIR)/output/images

.PHONY: all buildroot build run

clone:
	@if [ ! -d "$(BUILDROOT_DIR)/.git" ]; then \
		echo "Cloning Buildroot..."; \
		git clone --depth 1 --branch $(BUILDROOT_TAG) $(BUILDROOT_REPO) $(BUILDROOT_DIR); \
	else \
		echo "Buildroot already cloned, skipping."; \
	fi


buildroot: clone
	cd $(BUILDROOT_DIR) && make qemu_arm_vexpress_defconfig
	cd $(BUILDROOT_DIR) && make

build: buildroot

run:
	@echo "Running QEMU..."
	qemu-system-arm \
		-M virt \
		-cpu cortex-a15 \
		-nographic \
		-m 512M \
		-kernel $(IMAGES_DIR)/Image \
		-dtb $(IMAGES_DIR)/virt.dtb \
		-drive file=$(IMAGES_DIR)/rootfs.ext2,format=raw,if=virtio \
		-bios $(IMAGES_DIR)/u-boot.bin \
		-append "console=ttyAMA0 root=/dev/vda rw"


define Build/an7583-preloader
	dd if=$(STAGING_DIR_IMAGE)/an7583_$1-bl2.fip >> $@
endef

define Build/an7583-bl31-uboot
	dd if=$(STAGING_DIR_IMAGE)/an7583_$1-bl31-u-boot.fip >> $@
endef

define Build/an7583-fip-ubi
	$(TOPDIR)/scripts/ubinize-image.sh --part fip=:$(STAGING_DIR_IMAGE)/an7583_$1-bl31-u-boot.fip "$@" -p 128KiB -m 2048
endef

define Build/an7583-tcboot
	dd if=/dev/zero bs=524288 count=1 | tr '\000' '\377' > "$@"
	dd if=/dev/zero of=$@ bs=2048 count=1 conv=notrunc
	dd if=$(STAGING_DIR_IMAGE)/an7583_$1-bl2.fip of=$@ bs=1 seek=2048 conv=notrunc
	dd if=$(STAGING_DIR_IMAGE)/an7583_$1-bl31-u-boot.fip of=$@ bs=1 seek=131072 conv=notrunc
	head -c 507900 "$@" | gzip -n -c | tail -c 8 | head -c 4 > "$@.crc"
	$(STAGING_DIR_HOST)/bin/xorimage -i "$@.crc" -o "$@.crc.inv" -p ff -x
	dd if=$@.crc.inv of=$@ bs=1 seek=507900 conv=notrunc
	rm -f "$@.crc" "$@.crc.inv"
endef

define Device/FitImageLzma
  KERNEL_SUFFIX := -uImage.itb
  KERNEL = kernel-bin | lzma | \
	fit lzma $$(KDIR)/image-$$(DEVICE_DTS).dtb
  KERNEL_NAME := Image
endef

define Device/airoha_an7583-evb
  $(call Device/FitImageLzma)
  DEVICE_VENDOR := Airoha
  DEVICE_MODEL := AN7583 Evaluation Board (SNAND)
  DEVICE_PACKAGES := kmod-phy-aeonsemi-as21xxx kmod-leds-pwm \
	kmod-pwm-airoha kmod-input-gpio-keys-polled
  DEVICE_DTS := an7583-evb
  DEVICE_DTS_CONFIG := config@1
  IMAGE/sysupgrade.bin := append-kernel | pad-to 128k | append-rootfs | \
	pad-rootfs | append-metadata
endef
TARGET_DEVICES += airoha_an7583-evb

define Device/airoha_an7583-evb-emmc
  DEVICE_VENDOR := Airoha
  DEVICE_MODEL := AN7583 Evaluation Board (EMMC)
  DEVICE_DTS := an7583-evb-emmc
  DEVICE_PACKAGES := kmod-phy-airoha-en8811h kmod-i2c-an7581
endef
TARGET_DEVICES += airoha_an7583-evb-emmc

define Device/nokia_xg-040g-mf
  $(call Device/FitImageLzma)
  DEVICE_VENDOR := Nokia
  DEVICE_MODEL := XG-040G-MF
  DEVICE_DTS := an7583-nokia_xg-040g-mf
  DEVICE_DTS_CONFIG := config@1
  BLOCKSIZE := 128k
  PAGESIZE := 2048
  UBINIZE_OPTS := -E 5
  IMAGE_SIZE := 131968k
  KERNEL_SIZE := 8192k
  IMAGES += factory-kernel.bin factory-rootfs.bin
  IMAGE/factory-kernel.bin := append-kernel
  IMAGE/factory-rootfs.bin := append-ubi | check-size
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
  DEVICE_PACKAGES := kmod-phy-airoha-en8811h
endef
TARGET_DEVICES += nokia_xg-040g-mf

define Device/vsol_v2901q-a
  $(call Device/FitImageLzma)
  DEVICE_VENDOR := VSOL
  DEVICE_MODEL := VSOL V2901Q-A
  DEVICE_PACKAGES := kmod-i2c-an7581 kmod-phy-airoha-en8811h
  DEVICE_DTS := an7583-vsol-v2901q-a
  DEVICE_DTS_CONFIG := config@1
  IMAGE/sysupgrade.bin := an7583-fip-ubi vsol | pad-to 640k | append-kernel | pad-to 128k | append-rootfs | pad-rootfs | append-metadata
  ARTIFACT/preloader.bin := an7583-preloader vsol
  ARTIFACT/bl31-uboot.fip := an7583-bl31-uboot vsol
  ARTIFACT/bl31-uboot-fip.ubi := an7583-fip-ubi vsol
  ARTIFACT/tcboot.bin := an7583-tcboot vsol
  ARTIFACTS := preloader.bin bl31-uboot.fip bl31-uboot-fip.ubi tcboot.bin
endef
TARGET_DEVICES += vsol_v2901q-a

define Device/vsol_v2902a-s
  $(call Device/FitImageLzma)
  DEVICE_VENDOR := VSOL
  DEVICE_MODEL := VSOL V2902A-S
  DEVICE_PACKAGES := kmod-i2c-an7581 kmod-sfp
  DEVICE_DTS := an7583-vsol-v2902a-s
  DEVICE_DTS_CONFIG := config@1
  IMAGE/sysupgrade.bin := an7583-fip-ubi vsol | pad-to 640k | append-kernel | pad-to 128k | append-rootfs | pad-rootfs | append-metadata
  ARTIFACT/preloader.bin := an7583-preloader vsol
  ARTIFACT/bl31-uboot.fip := an7583-bl31-uboot vsol
  ARTIFACT/bl31-uboot-fip.ubi := an7583-fip-ubi vsol
  ARTIFACT/tcboot.bin := an7583-tcboot vsol
  ARTIFACTS := preloader.bin bl31-uboot.fip bl31-uboot-fip.ubi tcboot.bin
endef
TARGET_DEVICES += vsol_v2902a-s

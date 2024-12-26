QEMU := sudo qemu-system-aarch64

# DEV_DIR, IMG_DIR, PLAT_DIR are defined in hvisor Makefile

UBOOT := $(IMG_DIR)/uboot.bin

FSIMG1 := $(IMG_DIR)/rootfs1.ext4
FSIMG2 := $(IMG_DIR)/rootfs2.ext4

zone0_kernel := $(IMG_DIR)/Image
zone0_dtb    := $(PLAT_DIR)/dts/zone0.dtb
zone1_kernel := $(IMG_DIR)/Image
zone1_dtb    := $(PLAT_DIR)/dts/zone1-linux.dtb

zone1_config := $(PLAT_DIR)/configs/zone1-linux.json

hvisor_bin   := $(IMG_DIR)/hvisor.bin

QEMU_ARGS := -machine virt,secure=on,gic-version=3,virtualization=on,iommu=smmuv3
QEMU_ARGS += -global arm-smmuv3.stage=2

# QEMU_ARGS += -d int

QEMU_ARGS += -cpu cortex-a57
QEMU_ARGS += -smp 4
QEMU_ARGS += -m 3G
QEMU_ARGS += -nographic
QEMU_ARGS += -bios $(UBOOT)

QEMU_ARGS += -device loader,file="$(hvisor_bin)",addr=0x40400000,force-raw=on
QEMU_ARGS += -device loader,file="$(zone0_kernel)",addr=0xa0400000,force-raw=on
QEMU_ARGS += -device loader,file="$(zone0_dtb)",addr=0xa0000000,force-raw=on
# QEMU_ARGS += -device loader,file="$(zone1_kernel)",addr=0x70000000,force-raw=on
# QEMU_ARGS += -device loader,file="$(zone1_dtb)",addr=0x91000000,force-raw=on

QEMU_ARGS += -drive if=none,file=$(FSIMG1),id=Xa003e000,format=raw
QEMU_ARGS += -device virtio-blk-device,drive=Xa003e000,bus=virtio-mmio-bus.31

QEMU_ARGS += -drive if=none,file=$(FSIMG2),id=Xa003c000,format=raw
QEMU_ARGS += -device virtio-blk-device,drive=Xa003c000

# QEMU_ARGS += -netdev tap,id=Xa003a000,ifname=tap0,script=no,downscript=no
# QEMU_ARGS += -device virtio-net-device,netdev=Xa003a000,mac=52:55:00:d1:55:01
# QEMU_ARGS += -netdev user,id=n0,hostfwd=tcp::5555-:22 -device virtio-net-device,bus=virtio-mmio-bus.31,netdev=n0 

QEMU_ARGS += -chardev pty,id=Xa003a000
QEMU_ARGS += -device virtio-serial-device,bus=virtio-mmio-bus.28 -device virtconsole,chardev=Xa003a000

# QEMU_ARGS += --fsdev local,id=Xa0036000,path=./9p/,security_model=none
# QEMU_ARGS += -device virtio-9p-pci,fsdev=Xa0036000,mount_tag=kmod_mount

# trace-event gicv3_icc_generate_sgi on
# trace-event gicv3_redist_send_sgi on

QEMU_ARGS += -netdev type=user,id=net1
QEMU_ARGS += -device virtio-net-pci,netdev=net1,disable-legacy=on,disable-modern=off,iommu_platform=on

# QEMU_ARGS += -device pci-testdev

QEMU_ARGS += -netdev type=user,id=net2
QEMU_ARGS += -device virtio-net-pci,netdev=net2,disable-legacy=on,disable-modern=off,iommu_platform=on

QEMU_ARGS += -netdev type=user,id=net3
QEMU_ARGS += -device virtio-net-pci,netdev=net3,disable-legacy=on,disable-modern=off,iommu_platform=on

HVISOR_RUNCMD := $(QEMU) $(QEMU_ARGS)
HVISOR_GDBCMD := $(HVISOR_RUNCMD) -s -S

FS_FILE_LIST  := $(zone1_kernel) $(zone1_dtb) $(zone1_config)
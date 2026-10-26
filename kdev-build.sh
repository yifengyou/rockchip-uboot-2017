#!/bin/bash

set -ex

TIMESTAMP=$(date +%Y%m%d)

# clean
rm -rf release
mkdir -p release


# only spi
rm -f uboot.img arch/arm/dts/rk3588-evb.dtb
sed -i "s#BYD G98 Compiled By yifengyou.*#BYD G98 Compiled By yifengyou v$(date +%Y.%m.%d-%H:%M:%S)\";#" only-spi/rk3588-evb.dts
cp -a only-spi/rk3588-evb.dts arch/arm/dts/rk3588-evb.dts
cp -a only-spi/rk3588_defconfig configs/rk3588_defconfig
cp -a only-spi/spl.c common/spl/spl.c

./make.sh rk3588

dtc -I dtb -O dts arch/arm/dts/rk3588-evb.dtb -o only-spi/bdy-g98-uboot.dts
fdtdump u-boot.dtb > only-spi/u-boot.dts
ls -alh only-spi/bdy-g98-uboot.dts only-spi/u-boot.dts

./make.sh loader
ls -alh rk3588_spl*.bin
mv rk3588_spl_loader_v1.21.114.bin release/rk3588_spl_loader_v1.21.114_only-spi.bin

dd if=uboot.img of=release/uboot-bdy-g98_only-spi.img bs=2M count=1
dumpimage -l release/uboot-bdy-g98_only-spi.img
ls -alh release/uboot-bdy-g98_only-spi.img
cp release/uboot-bdy-g98_only-spi.img release/uboot-bdy-g98_only-spi-${TIMESTAMP}.img

# show release
ls -alh release/*
sha256sum release/*

echo "All ok! All done!"

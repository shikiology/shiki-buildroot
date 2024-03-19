#!/usr/bin/env bash
#
# Copyright (C) 2022 Ing <https://github.com/wjz304>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

BR_VERSION=${1:-"2023.08.x"}
if [ ! -d ".shiki-buildroot" ]; then
  git clone --depth=1 --single-branch -b ${BR_VERSION} https://github.com/buildroot/buildroot.git .shiki-buildroot
fi

cd .shiki-buildroot/
git reset --hard
git checkout ${BR_VERSION}
git pull

if [ ! -d "linux-firmware" ]; then
  git clone --depth=1 https://github.com/shikiology/linux-firmware linux-firmware
else
  pushd linux-firmware
  git pull
  popd
fi

cp -Ru ../* ./
echo "Generating default config"
make BR2_EXTERNAL=./external -j$(nproc) shiki_defconfig

echo "Download sources if not cached"
make BR2_EXTERNAL=./external -j$(nproc) source

echo "Prepare buildroot for first make"
make BR2_EXTERNAL=./external -j$(nproc)

[ ! -f "output/images/bzImage" ] && exit 1
[ ! -f "output/images/rootfs.cpio.xz" ] && exit 1

BUILDROOT_VERSION="$(grep ' BR2_VERSION :=' Makefile | cut -d '=' -f2 | tr -d ' ')"
KERNEL_VERSION="$(grep BR2_LINUX_KERNEL_VERSION .config | cut -d'=' -f2 | tr -d '"')"
echo "BUILDROOT_VERSION=${BUILDROOT_VERSION}"
echo "KERNEL_VERSION=${KERNEL_VERSION}"

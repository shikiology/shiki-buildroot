#!/usr/bin/env bash
# $1 = ./output/target  # Target path
# CONFIG_DIR = .
# BR2_DL_DIR = ./.buildroot-dl
# BASE_DIR = ./output
# BUILD_DIR = ./output/build
# BINARIES_DIR = ./output/images

set -e

# Fix DHCPCD client id
sed -i 's|#clientid|clientid|' "${1}/etc/dhcpcd.conf"
sed -i 's|duid|#duid|' "${1}/etc/dhcpcd.conf"

# Fix firmware
SOURCE="${CONFIG_DIR}/linux-firmware"
mkdir -p "${1}/lib/firmware"
for I in $(find "${1}/lib/modules" -name '*.ko'); do
  while read line; do
    F=$(echo $line | sed 's|firmware=||')
    if [[ -f "${1}/lib/firmware/${F}" ]]; then
      echo "${1}/lib/firmware/${F} already exists, skipping"
    else
      if [[ -f "${SOURCE}/${F}" ]]; then
        mkdir -p "$(dirname ${1}/lib/firmware/${F})"
        cp -vf "${SOURCE}/${F}" "${1}/lib/firmware/${F}"
      else
        echo "Warning: ${SOURCE}/${F} not found, skipping"
      fi
    fi
  done < <(modinfo -F firmware "${I}")
done

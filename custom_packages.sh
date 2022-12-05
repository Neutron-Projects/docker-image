#!/usr/bin/env bash
# Installation of all other custom packages go here.
set -e

# Custom ZSTD package
wget https://github.com/dakkshesh07/zstd-pkgbuild/releases/download/1.5.2-8/zstd-1.5.2-8-x86_64.pkg.tar.zst
pacman -U --noconfirm zstd-1.5.2-8-x86_64.pkg.tar.zst
rm -rf zstd-1.5.2-8-x86_64.pkg.tar.zst

echo 'Custom packages installtion completed'

#!/usr/bin/env bash
# Installation of all packages from AetherLinux repos
set -e


# AetherLinux keyring
wget https://github.com/AetherLinux/aether-keyring/releases/download/1.0-1/aether-keyring-1.0-1-x86_64.pkg.tar.zst
pacman -U --noconfirm aether-keyring-1.0-1-x86_64.pkg.tar.zst
rm -rf aether-keyring-1.0-1-x86_64.pkg.tar.zst

# Enable AetherLinux repos
sed -i "/\[aether\]/,/Server/"'s/^#//' /etc/pacman.conf

# Update
pacman -Syyu --noconfirm 2>&1 | grep -v "warning: could not get file information"

echo 'AetherLinux packages installtion completed'

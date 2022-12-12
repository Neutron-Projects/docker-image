#!/usr/bin/env bash
# Installation of all packages from ALHP repos
set -e

# Create a non-root user for yay to install packages from AUR
useradd -m -G wheel -s /bin/bash auruser
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

# Update yay
sudo -u auruser yay -S --noconfirm yay

# AUR Packages
sudo -u auruser yay -S --noconfirm \
    alhp-keyring alhp-mirrorlist

# Enable ALHP repos
sed -i "/\[core-x86-64-v3\]/,/Include/"'s/^#//' /etc/pacman.conf
sed -i "/\[extra-x86-64-v3\]/,/Include/"'s/^#//' /etc/pacman.conf
sed -i "/\[community-x86-64-v3\]/,/Include/"'s/^#//' /etc/pacman.conf

# Update
pacman -Syyu --noconfirm 2>&1 | grep -v "warning: could not get file information"

echo 'ALHP packages installtion completed'

#!/usr/bin/env bash
# Installation of all packages from ALHP repos
set -e

# Create a non-root user for yay to install packages from AUR
useradd -m -G wheel -s /bin/bash auruser
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

# Install paru
sudo -u auruser yay -S --noconfirm paru
sudo -u auruser paru -R --noconfirm yay

# AUR Packages
sudo -u auruser paru -S --noconfirm \
    alhp-keyring alhp-mirrorlist pthreadpool-git

# Enable ALHP repos
sed -i "/\[core-x86-64-v3\]/,/Include/"'s/^#//' /etc/pacman.conf
sed -i "/\[extra-x86-64-v3\]/,/Include/"'s/^#//' /etc/pacman.conf
sed -i "/\[multilib-x86-64-v3]\]/,/Include/"'s/^#//' /etc/pacman.conf

# Update
pacman -Syyu --noconfirm 2>&1 | grep -v "warning: could not get file information"

echo 'ALHP packages installtion completed'

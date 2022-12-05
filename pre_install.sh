#!/usr/bin/env bash
# Pre-Install configurations
set -e

# TimeZone Configuration
export TZ="Asia/Kolkata"
ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime

# Uncomment community [multilib] repository
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

# Refresh mirror list
pacman-key --init
pacman -Syu --noconfirm reflector rsync curl git base-devel 2>&1 | grep -v "warning: could not get file information"
reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Download fresh package databases from the servers
pacman -Syy

echo 'pre-installtion configuration completed'

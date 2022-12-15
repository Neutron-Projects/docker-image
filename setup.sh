#!/usr/bin/env bash
# Fedora Package installtion & setup
set -e

# dnf configuration
{
    echo "max_parallel_downloads=20"
    echo "fastestmirror=True"
    echo "defaultyes=True"
} >>/etc/dnf/dnf.conf

# Enable RPM Fusion Repos
dnf install -y \
    "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# Update packages
dnf update -y
dnf upgrade -y

# Install required packages
dnf install -y \
    bc \
    binutils-devel \
    bison \
    ccache \
    clang \
    cmake \
    curl \
    elfutils-libelf-devel \
    flex \
    gcc \
    gcc-c++ \
    git \
    git \
    lld \
    make \
    nano \
    neofetch \
    ninja-build \
    openssl-devel \
    patchelf \
    python3 \
    python3-pip \
    sudo \
    texinfo-tex \
    tmate \
    uboot-tools \
    wget \
    xz \
    zlib-devel
    
# gh cli
dnf install 'dnf-command(config-manager)'
dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
dnf install gh

# pip packages
pip3 install \
    telegram-send

# git configuration
git config --global user.name "Dakkshesh"
git config --global user.email "dakkshesh5gmail.com"
git config --global color.ui auto

# Timezone configuration
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

echo 'Fedora packages installtion completed'

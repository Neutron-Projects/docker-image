#!/usr/bin/env bash
# Installation of packages from ArchLinux repos.
set -e

# Install Development Packages
pacman -Sy --noconfirm \
    aarch64-linux-gnu-binutils \
    base-devel \
    bc \
    bear \
    bison \
    ccache \
    clang \
    cmake \
    cpio \
    curl \
    flex \
    gcc \
    gcc-libs \
    git \
    github-cli \
    gperf \
    htop \
    hyperfine \
    jdk-openjdk \
    jemalloc \
    libelf \
    lld \
    llvm \
    lz4 \
    multilib-devel \
    nano \
    ninja \
    openmp \
    openssl \
    patchelf \
    perf \
    perl \
    python-pip \
    python3 \
    rsync \
    sudo \
    tensorflow \
    tmate \
    tmux \
    uboot-tools \
    wget \
    zip \
    zstd 2>&1 | grep -v "warning: could not get file information"

echo 'Archlinux packages installtion completed'

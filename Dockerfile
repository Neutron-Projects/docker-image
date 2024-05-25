FROM alpine:edge AS bootstrap

# Set up the bootstrap tree
COPY /bootstrap /

# Set up the initial rootfs tree
COPY /rootfs /rootfs

# Set up pacman
RUN apk add arch-install-scripts pacman-makepkg curl zstd && \
    cp -r /rootfs/etc/pacman.d /etc/ && \
    cp /rootfs/etc/pacman.conf /etc/pacman.conf && \
    mkdir /tmp/archlinux-keyring && \
    curl -L https://archlinux.org/packages/core/any/archlinux-keyring/download | unzstd | tar -C /tmp/archlinux-keyring -xv && \
	mv /tmp/archlinux-keyring/usr/share/pacman/keyrings /usr/share/pacman/

# Install the base packages
RUN pacman-key --init && pacman-key --populate
RUN chmod +x /usr/local/bin/pacstrap-docker && pacstrap-docker /rootfs base base-devel git sudo

# Full image
FROM scratch as full

# Copy the bootstrapped rootfs
COPY --from=bootstrap /rootfs /

# Set up locale and timezone
ENV LANG=en_US.UTF-8
RUN locale-gen
ENV TZ="Asia/Kolkata"
RUN ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

# Pacman
RUN pacman-key --init && \
    pacman-key --populate

# Packages for our use (Update mirrorlist to get new packages before ALHP)
RUN cat /etc/minimal_packages.txt | xargs pacman -S --noconfirm
RUN reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
RUN pacman -Syyu --noconfirm

# Setup auruser
RUN useradd -m auruser && \
    echo 'auruser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
WORKDIR /home/auruser
USER auruser

# Build and install paru
RUN export MAKEFLAGS="-j$(nproc --all)"
WORKDIR /tmp
RUN git clone https://aur.archlinux.org/paru.git
WORKDIR /tmp/paru
RUN makepkg -si --noconfirm

# AUR
RUN paru -S --noconfirm alhp-keyring alhp-mirrorlist pthreadpool-git antman
RUN paru -Sccd

# ALHP
USER root
WORKDIR /
RUN sed -i "/\[core-x86-64-v3\]/,/Include/"'s/^#//' /etc/pacman.conf
RUN sed -i "/\[extra-x86-64-v3\]/,/Include/"'s/^#//' /etc/pacman.conf
RUN pacman -Syyu --noconfirm
RUN cat /etc/extra_packages.txt | xargs pacman -S --noconfirm
RUN rm -rf /var/lib/pacman/sync/* && rm -rf /etc/minimal_packages.txt && rm -rf /etc/extra_packages.txt && rm -rf /tmp/*

# Perl path
ENV PATH="/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:$PATH"

# Symlinks for python and pip
RUN ln -sf /usr/bin/pip3.11 /usr/bin/pip3
RUN ln -sf /usr/bin/pip3.11 /usr/bin/pip
RUN ln -sf /usr/bin/python3.11 /usr/bin/python3
RUN ln -sf /usr/bin/python3.11 /usr/bin/python

# Set up pacman-key without distributing the lsign key
# See https://gitlab.archlinux.org/archlinux/archlinux-docker/-/blob/301942f9e5995770cb5e4dedb4fe9166afa4806d/README.md#principles
# Source: https://gitlab.archlinux.org/archlinux/archlinux-docker/-/blob/301942f9e5995770cb5e4dedb4fe9166afa4806d/Makefile#L22
RUN bash -c "rm -rf etc/pacman.d/gnupg/{openpgp-revocs.d/,private-keys-v1.d/,pubring.gpg~,gnupg.S.}*"

CMD ["/usr/bin/bash"]

# Minimal image
FROM scratch as minimal

# Copy the bootstrapped rootfs
COPY --from=bootstrap /rootfs /

# Set up locale and timezone
ENV LANG=en_US.UTF-8
RUN locale-gen
ENV TZ="Asia/Kolkata"
RUN ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

# Pacman
RUN pacman-key --init && \
    pacman-key --populate

# Packages for our use (Update mirrorlist to get new packages before ALHP)
RUN cat /etc/minimal_packages.txt | xargs pacman -S --noconfirm
RUN reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
RUN pacman -Syyu --noconfirm

# Setup auruser
RUN useradd -m auruser && \
    echo 'auruser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
WORKDIR /home/auruser
USER auruser

# Build and install paru
RUN export MAKEFLAGS="-j$(nproc --all)"
WORKDIR /tmp
RUN git clone https://aur.archlinux.org/paru.git
WORKDIR /tmp/paru
RUN makepkg -si --noconfirm

# AUR
RUN paru -S --noconfirm alhp-keyring alhp-mirrorlist antman
RUN paru -Sccd

# ALHP
USER root
WORKDIR /
RUN sed -i "/\[core-x86-64-v3\]/,/Include/"'s/^#//' /etc/pacman.conf
RUN sed -i "/\[extra-x86-64-v3\]/,/Include/"'s/^#//' /etc/pacman.conf
RUN pacman -Syyu --noconfirm
RUN rm -rf /var/lib/pacman/sync/* && rm -rf /etc/minimal_packages.txt && rm -rf /tmp/*

# Perl path
ENV PATH="/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:$PATH"

# Symlinks for python and pip
RUN ln -sf /usr/bin/pip3.11 /usr/bin/pip3
RUN ln -sf /usr/bin/pip3.11 /usr/bin/pip
RUN ln -sf /usr/bin/python3.11 /usr/bin/python3
RUN ln -sf /usr/bin/python3.11 /usr/bin/python

# Set up pacman-key without distributing the lsign key
# See https://gitlab.archlinux.org/archlinux/archlinux-docker/-/blob/301942f9e5995770cb5e4dedb4fe9166afa4806d/README.md#principles
# Source: https://gitlab.archlinux.org/archlinux/archlinux-docker/-/blob/301942f9e5995770cb5e4dedb4fe9166afa4806d/Makefile#L22
RUN bash -c "rm -rf etc/pacman.d/gnupg/{openpgp-revocs.d/,private-keys-v1.d/,pubring.gpg~,gnupg.S.}*"

CMD ["/usr/bin/bash"]

# Minimal image with neutron tc shipped.
# Use the arch-minimal image as the base
FROM ghcr.io/neutron-projects/docker-image:arch-minimal as wtc

RUN mkdir -p "/toolchains/neutron-clang"
WORKDIR /toolchains/neutron-clang
RUN antman -S --noprogress
WORKDIR /

CMD ["/usr/bin/bash"]

# Retain support for old tags for a brief time.
# Use the arch-minimal image as the base
FROM ghcr.io/neutron-projects/docker-image:arch-minimal as deprecated

# Add a deprecation label
LABEL deprecation="This tag is deprecated. If you are using this image for compiling Linux kernels, please use the arch-minimal tag instead. The arch-neutron tag will no longer receive updates."

# Add a deprecation notice script
RUN echo 'echo "WARNING: The arch-neutron tag is deprecated. If you are using this image for compiling Linux kernels, please use the arch-minimal tag instead. The arch-neutron tag will no longer receive updates."' >> /etc/profile.d/deprecation_notice.sh

# Ensure the deprecation notice is displayed at login
RUN echo 'source /etc/profile.d/deprecation_notice.sh' >> /etc/bash.bashrc

CMD ["/usr/bin/bash"]

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

FROM scratch

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
RUN cat /etc/my-packages.txt | xargs pacman -S --noconfirm
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

# ALHP
RUN paru -S --noconfirm alhp-keyring alhp-mirrorlist pthreadpool-git
RUN paru -Sccd

USER root
WORKDIR /
RUN sed -i "/\[core-x86-64-v3\]/,/Include/"'s/^#//' /etc/pacman.conf
RUN sed -i "/\[extra-x86-64-v3\]/,/Include/"'s/^#//' /etc/pacman.conf
RUN pacman -Syyu --noconfirm 2>&1
RUN rm -rf /var/lib/pacman/sync/* && rm -rf /etc/my-packages.txt && rm -rf /tmp/*

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

# Base Image
FROM archlinux:base-devel

# User
USER root

# Working Directory
WORKDIR /root

ENV LANG=en_US.UTF-8
CMD ["/usr/bin/bash"]

# Remove Files before copying the Rootfs
COPY remove /tmp/
RUN rm -rf $(< /tmp/remove)

# Copy Rootfs and Scripts
COPY rootfs /

# Install Packages
COPY pre_install.sh /tmp/
RUN bash /tmp/pre_install.sh

COPY archlinux_packages.sh /tmp/
RUN bash /tmp/archlinux_packages.sh

COPY cos_packages.sh /tmp/
RUN bash /tmp/cos_packages.sh

COPY alhp_packages.sh /tmp/
RUN bash /tmp/alhp_packages.sh

COPY custom_packages.sh /tmp/
RUN bash /tmp/custom_packages.sh

COPY post_install.sh /tmp/
RUN bash /tmp/post_install.sh

# Remove the Scripts we used
RUN rm -rf /tmp/{{pre_install.sh,archlinux_packages,cos_packages,alhp_packages,custom_packages,post_install}.sh,remove}

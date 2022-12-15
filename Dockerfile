# Base Image
FROM fedora:latest

# User
USER root

# Working Directory
WORKDIR /root

CMD ["/usr/bin/bash"]

# Install Packages
COPY setup.sh /tmp/
RUN bash /tmp/setup.sh
RUN rm -rf /tmp/setup.sh

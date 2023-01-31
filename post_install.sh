#!/usr/bin/env bash
# Post-Install configurations
set -e

# Git Configuration
export GIT_USERNAME="Dakkshesh"
export GIT_EMAIL="dakkshesh5@gmail.com"

git config --global user.name "${GIT_USERNAME}"
git config --global user.email "${GIT_EMAIL}"

# Modify $PATH to include perl binaries
export PATH="/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:$PATH"

# Symlinks for python and pip
ln -sf /usr/bin/pip3.10 /usr/bin/pip3
ln -sf /usr/bin/pip3.10 /usr/bin/pip
ln -sf /usr/bin/python3.10 /usr/bin/python3
ln -sf /usr/bin/python3.10 /usr/bin/python

# python and pip version
python3 --version
pip3 --version

# Setup locale
echo "LC_ALL=en_US.UTF-8" | sudo tee -a /etc/environment
echo "en_US.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen
echo "LANG=en_US.UTF-8" | sudo tee -a /etc/locale.conf
sudo locale-gen en_US.UTF-8

echo 'post-installtion configuration completed'

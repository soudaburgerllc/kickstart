#!/bin/bash

HOMEDIR="/home/{{ initial_system_user }}"

echo "#####################################"
echo "###      START OF BOOTSTRAP       ###"
echo "#####################################"

set -x

# Sudoers for {{ initial_system_user }}
echo "{{ initial_system_user }} ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/{{ initial_system_user }}

# SSH keys for rack
mkdir -p "${HOMEDIR}/.ssh"
chmod 0700 "${HOMEDIR}"
chmod 0700 "${HOMEDIR}/.ssh"
chown -R 1000:1000 "${HOMEDIR}"

# Fetch authorized_keys
wget -q http://{{ kickstart_host }}/keys/authorized_keys -O "${HOMEDIR}/.ssh/authorized_keys"

chmod 0644 "${HOMEDIR}/.ssh/authorized_keys"

wget -q http://{{ kickstart_host }}/kickstart/issue -O /etc/issue

# Clean up
apt-get -qq -y autoremove
apt-get clean
rm -f /var/cache/apt/*cache.bin
rm -rf /var/lib/apt/lists/*

set +x

echo "#####################################"
echo "###       END OF BOOTSTRAP        ###"
echo "#####################################"
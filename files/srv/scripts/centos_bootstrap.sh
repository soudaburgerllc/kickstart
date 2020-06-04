#!/bin/bash

HOMEDIR="/home/{{ initial_system_user }}"

echo "#####################################"
echo "###      START OF BOOTSTRAP       ###"
echo "#####################################"

set -x

yum install -y -q epel-release
yum install -y -q ansible
yum install -y -q wget

# Sudoers for {{ initial_system_user }}
echo "{{ initial_system_user }} ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/{{ initial_system_user }}

# SSH keys for rack
mkdir -p "${HOMEDIR}/.ssh"
chmod 0700 "${HOMEDIR}"
chmod 0700 "${HOMEDIR}/.ssh"

# Fetch authorized_keys
wget -q http://{{ kickstart_host }}/keys/authorized_keys -O "${HOMEDIR}/.ssh/authorized_keys"

chmod 0644 "${HOMEDIR}/.ssh/authorized_keys"
chown -R "{{ initial_system_user }}:{{ initial_system_user }}" "${HOMEDIR}"

wget -q http://{{ kickstart_host }}/kickstart/issue -O /etc/issue

# Clean up

set +x

echo "#####################################"
echo "###       END OF BOOTSTRAP        ###"
echo "#####################################"
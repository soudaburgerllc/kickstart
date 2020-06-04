#version=Centos7/RHEL7
# System authorization information
auth --enableshadow --passalgo=sha512

# Use network installation
url --url="nfs://{{ kickstart_host }}/centos7/"

# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System language
lang en_US.UTF-8

#Log to remote host
logging --host={{ syslog_host }} --port {{ syslog_port }}

# Network information
network  --bootproto=dhcp --onboot=on --noipv6 --activate

# Root password
rootpw --lock --plaintext password

# System services
services --enabled="chronyd"

# System timezone
timezone "{{ timezone }}" --isUtc

# System bootloader configuration
bootloader --location=mbr --boot-drive=sda
zerombr

# Partition clearing information
clearpart --all --initlabel

# Disk partitioning information
autopart --type=plain --fstype=ext4

# Create default user
user --name={{ initial_system_user }} --password={{ initial_system_password }} --iscrypted

skipx
reboot

%packages
@core
openssh-server
%end

%post

# Fetch and run bootstrap script

curl -s http://{{ kickstart_host }}/kickstart/centos_bootstrap.sh > /opt/centos_bootstrap.sh
chmod +x /opt/centos_bootstrap.sh
/bin/bash /opt/centos_bootstrap.sh

# \$BOOTSTRAP comes from kernel command line parameters for PXE
if [[ "${BOOTSTRAP}" != "" ]]
  then
  curl -s http://{{ kickstart_host }}/kickstart/${BOOTSTRAP}.sh > /opt/${BOOTSTRAP}.sh
  chmod +x /opt/${BOOTSTRAP}.sh
  /bin/bash /opt/${BOOTSTRAP}.sh
fi

%end
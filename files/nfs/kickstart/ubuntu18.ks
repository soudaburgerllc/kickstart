# Kickstart template for Ubuntu
# Platform: x86-64
#
# Customized for Server 18.04 minimal physical sever install
#

# I noticed a difference between 'ubuntu-server-minimal' and
# 'ubuntu-server-minimalvm' is the non-vm one omits the following lines.
# Well the 'standard' task installs silly things like a full 'bind9' server
# for caching dns.  Recommended to use a server that is designed just as a
# caching dns server like 'unbound' or 'pdns-recursor'
preseed --owner tasksel tasksel/skip-tasks string standard

# OPTIONAL: Change hostname from default 'preseed'
# If your DHCP hands out a hostname that will take precedence over this
# see: https://bugs.launchpad.net/ubuntu/+source/preseed/+bug/1452202
#preseed netcfg/hostname string minimal-vm

#System language
lang en_US

#Language modules to install
langsupport en_US

#System keyboard
keyboard us

#Log to remote host
logging --host={{ syslog_host }} --port {{ syslog_port }}

#System mouse
mouse

#System timezone
timezone America/Chicago

# Root password
rootpw --disabled

#Initial user (user with sudo capabilities)
# Allow weak password
preseed user-setup/allow-password-weak boolean true

# Create default user
user {{ initial_system_user }} --fullname "{{ initial_system_user }}" --password={{ initial_system_password }} --iscrypted

#Reboot after installation
reboot

#Use text mode install
text

#Install OS instead of upgrade
install

#Installation media
# url --url "nfs://{{ kickstart_host }}/ubuntu18"
nfs --server={{ kickstart_host }} --dir=/ubuntu18

# Use local proxy
# Setup a server with apt-cacher-ng and enter that hostname here
; preseed mirror/http/proxy string http://172.23.209.10:3142

#Change console size to 1024x768x24
preseed debian-installer/add-kernel-opts string "vga=792"

#System bootloader configuration
bootloader --location=mbr

#Clear the Master Boot Record
zerombr yes

#Partition clearing information
# '--all' will give message in install log about only clearing first drive but
# this is still needed
clearpart --all --initlabel

#Advanced partition
# The last lv specified will take up the remaining space of the vg. To get
# around that add up all your disk sizes and set this value. It appears to
# factor in the size of non lvm partitions as well
preseed partman-auto-lvm/guided_size string max

part /boot --fstype=ext4 --size=512 --asprimary
part pv.1 --grow --size=1 --asprimary

volgroup vg0 pv.1

{{ ubuntu_disk_partitioning }}


# Don't install recommended items by default
# This will also be set for built system at
# /etc/apt/apt.conf.d/00InstallRecommends
preseed base-installer/install-recommends boolean false

#System authorization infomation
auth --useshadow

#Network information
# If the system has a single interface the '--device' option isn't needed. If
# you do use it remember that in 18.04 the device names are different. For
# example I was seeing enp0s3 as the interface name.  I haven't tested this
# but you should be able to specify 'interface=enp0s3' as a boot paramater and
# it will be passed through to installer.  I have tested setting the device to
# 'auto' will have it automatically pick the first active interface
network --bootproto=dhcp --device=auto

# This needs to be specified as boot parameters so it knows how to download
# this kickstart file but left here in case you use one network for initial
# load or something.
# Uncomment all these to use static ip
#d-i netcfg/disable_autoconfig boolean true
#d-i netcfg/get_ipaddress string 192.168.1.42
#d-i netcfg/get_netmask string 255.255.255.0
#d-i netcfg/get_gateway string 192.168.1.1
#d-i netcfg/get_nameservers string 192.168.1.1
#d-i netcfg/confirm_static boolean true

# Policy for applying updates. May be "none" (no automatic updates),
# "unattended-upgrades" (install security updates automatically), or
# "landscape" (manage system with Landscape).
preseed pkgsel/update-policy select unattended-upgrades

#Do not configure the X Window System
skipx

# Additional packages to install
# - Starting in 16.04 Ubuntu no longer installs python v2.7 by default.
#   Instead the default version of python is v3.x.  If you still need v2.7
#   then add the 'python' package to this list
%packages
ansible
bash-completion
chrony
coreutils
curl
gpg-agent
git
ifenslave
ifenslave-2.6
ifupdown
man
nano
net-tools
openssh-server
screen
software-properties-common
tmux
unzip
vim
wget
zip

%post

# -- begin security hardening --

# Add noatime to /
#sed -i -e 's/\(errors=remount-ro\)/noatime,\1/' /etc/fstab

# Add noatime and nodev to everything else
#sed -i -e 's/\(boot.*defaults\)/\1,noatime,nodev/' /etc/fstab
#sed -i -e 's/\(home.*defaults\)/\1,noatime,nodev/' /etc/fstab
#sed -i -e 's/\(usr.*defaults\)/\1,noatime,nodev/' /etc/fstab
#sed -i -e 's/\(opt.*defaults\)/\1,noatime,nodev/' /etc/fstab
#sed -i -e 's/\(srv.*defaults\)/\1,noatime,nodev/' /etc/fstab

# Remove nodev from this one if it causes issues for you
#sed -i -e 's/\(var .*defaults\)/\1,noatime,nodev/' /etc/fstab

# Add noatime, nodev, and noexec to /var/log
#sed -i -e 's/\(var\/log .*defaults\)/\1,noatime,nodev,noexec/' /etc/fstab

# Add line to enable noexec on /dev/shm
#echo "none /dev/shm tmpfs defaults,noexec,nosuid,nodev 0 0" >>/etc/fstab

# -- end security hardening --

# Fetch and run bootstrap script

curl -s http://{{ kickstart_host }}/kickstart/ubuntu_bootstrap.sh > /opt/ubuntu_bootstrap.sh
chmod +x /opt/ubuntu_bootstrap.sh
/bin/bash /opt/ubuntu_bootstrap.sh

# \$BOOTSTRAP comes from kernel command line parameters for PXE
if [ "${BOOTSTRAP}" != "" ]
  then
  curl -s http://{{ kickstart_host }}/kickstart/${BOOTSTRAP}.sh > /opt/${BOOTSTRAP}.sh
  chmod +x /opt/${BOOTSTRAP}.sh
  /bin/bash /opt/${BOOTSTRAP}.sh
fi

# 'nuke' script to ease testing
#(
#cat <<'EOP'
#dd if=/dev/zero of=/dev/vda bs=1024k count=20
#reboot -f
#EOP
#) > /root/nuke.sh

###
### END
###

%end
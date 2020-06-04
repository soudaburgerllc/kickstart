# Overview

This repository is designed to be a quick way to build a multi-purpose kickstart environment. Using a single CentOS host, you can kickstart CentOS and Ubuntu hosts with the flexibility to add future operating systems.

> **NOTE:** The only supported OS for the PXE server is CentOS 7.

# Quickstart

> **NOTE:** You will need to edit the hosts.ini and variables files as necessary after initial copy.

```bash
# Copy hosts file
cp hosts.example.ini hosts.ini

# Copy variables files
cp variables/common.example.yaml variables/common.yaml
cp variables/pxe.example.yaml variables/pxe.yaml

# Run ansible-playbook command
ansible-playbook -i hosts.ini -l pxe playbooks/pxe.yaml
```

# Folder structure

| Folder    | Description                                |
| --------- | ------------------------------------------ |
| files     | Flat files and templates for provisioning. |
| playbooks | Keep playbooks here.                       |
| roles     | Keep roles here                            |
| variables | Variables files                            |


# Variables

> **NOTE:** `ansible_remote_user` can be set in `variables/pxe.yaml` to set target user provisioned on systems.

### Common Variable Defaults
| Variable                  | Type    | Default                 | Description                                          |
| ------------------------- | ------- | ----------------------- | ---------------------------------------------------- |
| allowed_subnets           | Array   | See common.example.yaml | Firewalls are open to these subnets                  |
| ansible_remote_user       | String  | ansible                 | User to be                                           |
| common_installed_packages | Array   | See common.example.yaml | List of default packages to be installed             |
| domain_name               | String  | example.com             | Domain name to be used for different configurations. |
| nginx_stream_enabled      | String  | no                      | Whether to enable nginx streaming configurations     |
| nginx_user                | Hash    | See common.example.yaml | OS-based user defaults for nginx                     |
| syslog_host               | String  | localhost               | Kickstart syslog configuration host                  |
| syslog_port               | Integer | 514                     | Kickstart syslog configuration port                  |
| timezone                  | String  | America/New_York        | Default timezone for systems                         |
| ubuntu_disk_partitioning  | Blob    | See common.example.yaml | Partitioning structure                               |

### PXE Variable Defaults
| Variable                | Type   | Default                              | Description                                             |
| ----------------------- | ------ | ------------------------------------ | ------------------------------------------------------- |
| http_root               | String | /var/www/html                        | HTML Doc root for nginx.                                |
| initial_system_password | String | "$1$AKC/xDRy$5kKw2ikDw51bpMSdntx9w/" | Hashed password for initial users.                      |
| initial_system_user     | String | ansible                              | Default username for bootstrap user.                    |
| isos                    | Hash   | See pxe.example.yaml                 | ISO URLs and hashes for download validation.            |
| kickstart_host          | String | pxeserver.example.com                | Default kickstart host to be used by kickstart clients. |
| nfs_root                | String | /nfs                                 | NFS Root directory where NFS artifacts are served from. |
| supported_os_versions   | Array  | See pxe.example.yaml                 | Iterate through this array for specific configurations. |
| tftp_root               | String | /srv/tftp                            | TFTP Root for serving artifacts.                        |
| ubuntu_netboot_checksum | String | See pxe.example.yaml                 | Checksum for Ubuntu Netboot tarball.                    |
| ubuntu_netboot_url      | String | See pxe.example.yaml                 | URL to fetch Ubuntu Netboot tarball.                    |


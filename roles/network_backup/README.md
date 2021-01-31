Network Backups and Restores
=========

This role creates a backup directory and saves the running config to /tmp/backup/.

This role will pass through the `ansible_network_os` inventory variable to a series of playbooks based on that device OS. Currently, this role will gather facts and perform backups from the following platforms:

```
eos
ios
iosxr
nxos
aruba
aireos
f5-os
fortimgr
junos
paloalto
vyos
```

Role Variables
--------------

The `ansible_network_os` variable defines our inventory hosts' OS. We use this to decide which tasks and templates to run, since each OS can have OS specific commands. This should ideally be coming from an inventory or group variable.

At a minimum, Ansible needs these inventory details to perform a backup:
```
ansible_hostname:     hostname_fqdn
ansible_network_os:   ios/nxos/etc
ansible_username:     username
ansible_password:     password
```

And define your backup location:
```
network_backup_path:   /tmp/backup
```

Requirements
------------

Ansible 2.9+
Tower 3.7+

Dependencies
------------

N.A

Example Playbook
----------------

To use this role, you need only to run against your inventory, and it will create an individual backup file per host: `/tmp/backup/ios-hostname.cfg`

```
- name: backup device config
  ios_config:
    backup: yes
    backup_options:
      filename: "{{ ansible_network_os }}-{{ inventory_hostname }}.cfg"
      dir_path: "{{ network_backup_path }}"
```

And to perform a restore, Ansible can push the config file right back to a device:

```
- name: restore config backup
  ios_config:
    src: "{{ network_backup_path}}/{{ ansible_network_os }}-{{ inventory_hostname }}.cfg"
```

License
-------

GPLv3

Author Information
------------------

Landon Holley - landon@redhat.com

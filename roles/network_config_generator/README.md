

Network Config Management
=========

This role generates config files from templates and saves them in /tmp/config/.

Requirements
------------

Ansible 2.9+
Tower 3.7+

Role Variables
--------------

```
seq_bgp_to_eigrp
vlan_id
aws_acct_name
aws_acct_shortname
aws_acct_num
ip_address_bgp
bgp_ip
bgp_netmask
ip_address_bgp_to_eigrp
bgp_to_eigrp_ip
bgp_to_eigrp_netmask
community
neighbor
remote_as
remote_as_password
```

Dependencies
------------

N.A

Example Playbook
----------------

To use this role, you need only to place your Ansible-ized template into the `templates` directory, and put your template variables in to `vars/main.yml`.

```
- name: generate network config file
  template:
    src: templates/{{ ansible_network_os }}.j2
    dest: /tmp/config/{{ ansible_network_os }}.j2
```

License
-------

GPLv3

Author Information
------------------

Landon Holley - landon@redhat.com

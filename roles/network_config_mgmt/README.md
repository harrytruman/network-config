Network Config Management
=========

This role uses command templates to orchestrate device changes. Individual NXOS templates have been created to configure an interface, BGP routing, add route maps, and insert prefix lists. After NXOS changes have been applied, prefix lists will be updated on IOS devices.

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

To use this role, place your Anbsible-ized configs in the templates directory. In `tasks/main.yml`, ensure your inventory OS' are correct (currently nxos and ios). The NXOS changes are setup to be pushed directly from their corresponding templates. IOS changes are setup to demonstrate line-by-line changes when their hostname logic matches Ansible's task definition.

Single Template:
```
- name: push new device config
  nxos_config:
    src: "/var/tmp/config/nxos-int.j2"
```

Multi Templates:
```
- name: push new device config
  nxos_config:
    #src: "/var/tmp/config/nxos-int.j2"
    src: "{{ item }}"
  with_items:
    - "../templates/nxos-int.j2"
    - "../templates/nxos-bgp.j2"
    - "../templates/nxos-routemap.j2"
    - "../templates/nxos-prefix.j2"
```

License
-------

GPLv3

Author Information
------------------

Landon Holley - landon@redhat.com

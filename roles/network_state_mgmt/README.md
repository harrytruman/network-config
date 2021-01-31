Network State Management
=========

This role will configure VLAN and interfaces states on network devices. 

Ansible's Network Resource Modules are the solution to managing device states across different devices and different device types. NRMs already have the logic built in to know how config properties need to be orchestrated in which specific ways, and these modules know how to run the behind-the-scenes commands that get you the desired configuration state.

Requirements
------------

Ansible 2.9+
Tower 3.7+

Role Variables
--------------

This role mainly uses a pre-defined state definition, as if it were being retrieved from a CMDB. Currently, these are the two variables being used:

`aws_acct_name`
`aws_acct_num`

Dependencies
------------

N.A

Example Playbook
----------------

For a practical example, here’s an interface template:
```
interface_config:
- interface: Ethernet1/1
  description: ansible_managed-Te0/1/2
  enabled: True
  mode: trunk
  portchannel_id: 100

- interface: Ethernet1/2
  enabled: False

- interface: port-channel100
  description: vPC PeerLink
  mode: trunk
  enabled: True
  vpc_peerlink: True
  members:
    - member: Ethernet1/1
      mode: active
    - member: Ethernet1/36
      mode: active
```

Using the new network resource modules, we simply define our interface properties, and Ansible will figure out the rest.

```
- name: Configure Interface Settings
  nxos_interfaces:
    config:
      name: "{{ item['interface'] }}"
      description: "{{ item['description'] }}"
      enabled: "{{ item['enabled'] }}"
      mode: "{% if 'ip_address' in item %}layer3{% else %}layer2{% endif %}"
    state: replaced
  loop: "{{ interface_config }}"
  when: (interface_config is defined and (item['enabled'] == True))
```

License
-------

GPLv3

Author Information
------------------

Landon Holley - landon@redhat.com

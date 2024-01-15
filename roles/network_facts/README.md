# Network Facts and Configs

This role gathers native Ansible Facts or sets custom facts to parse command output and convert device configurations into code. Once gathered, facts can be used as backups/restores, called later as variables in other roles or playbooks, and used to define the state of a device.

## Compatibility

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

--------------

## Role Variables

Ansible uses the `ansible_network_os` inventory variable to define the device OS. This should ideally be coming from an inventory or group variable.

### Ansible Network Fact Collection

Ansible's native fact gathering can be invoked by setting `gather_facts: true` in your top level playbook.

Additionally, every major networking vendor has fact modules that you can use in a playbook task: `ios_facts`, `eos_facts`, `nxos_facts`, `junos_facts`, etc...

#### Examples

Ansible fact collection:
```
- name: collect device facts and running configs
  hosts: all
  gather_facts: yes
  connection: network_cli
```

Fact Module:
```
  tasks:
  - name: gather ios facts
    ios_facts:
      gather_subset: all
```

# Network Configuration with Ansible 
-------------

This repo is an introduction to building a network automation framework:

  * [Fact Collection and Configuration Parsing](https://github.com/harrytruman/network-config/tree/main/roles/network_facts)
  * [Backups and Restores](https://github.com/harrytruman/network-config/tree/main/roles/network_backup)
  * [Generating Configuration Templates](https://github.com/harrytruman/network-config/tree/main/roles/network_config_generator)
  * [Configuration Management via Commands and Jinja Templates](https://github.com/harrytruman/network-config/tree/main/roles/network_config_mgmt)
  * [State Management via Data Model; Config to Code](https://github.com/harrytruman/network-config/tree/main/roles/network_state_mgmt)

--------------

## Getting Started

### Network Inventory

At a minimum, Ansible needs an [inventory file](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html) with these details to run against network hosts:
```
ansible_hostname     hostname_fqdn
ansible_network_os   ios/nxos/etc
ansible_username     username
ansible_password     password
```

I *highly* recommend [vaulting your passwords/keys/creds](https://docs.ansible.com/ansible/latest/user_guide/vault.html#creating-encrypted-variables) instead of storing them plaintext! My inventories usually start like this:

```
[all]
ios-dc1-rtr
ios-dc2-rtr
ios-dc1-swt
ios-dc2-swt
nxos-dc1-rtr
nxos-dc2-rtr

[all:vars]
ansible_connection=network_cli
ansible_user=admin
ansible_password: !vault |
       $ANSIBLE_VAULT;1.2;AES256;ansible_user
       66386134653765386232383236303063623663343437643766386435663632343266393064373933
       3661666132363339303639353538316662616638356631650a316338316663666439383138353032
       63393934343937373637306162366265383461316334383132626462656463363630613832313562
       3837646266663835640a313164343535316666653031353763613037656362613535633538386539
       65656439626166666363323435613131643066353762333232326232323565376635

[ios]
ios-dc1-rtr
ios-dc2-rtr
ios-dc1-swt
ios-dc2-swt

[ios:vars]
ansible_become=yes
ansible_become_method=enable
ansible_network_os=ios

[nxos]
nxos-dc1-rtr
nxos-dc2-rtr

[nxos:vars]
ansible_become=yes
ansible_become_method=enable
ansible_network_os=nxos
```

--------------

### Fact Collection and Config Parsing

Ansible's native fact gathering can be invoked by setting `gather_facts: true` in your top level playbook. And every major networking vendor has fact modules that you can use in a playbook task: `ios_facts`, `eos_facts`, `nxos_facts`, `junos_facts`, etc...

Just enable `gather_facts`, and you're on your way! Here's an example of gathering facts on a Cisco IOS device to create a backup of the full running config, and parse config subsets into a platform-agnostic data model:

```
- name: collect device facts and running configs
  hosts: all
  gather_facts: yes
  connection: network_cli
```

Or at the task level:

```
  tasks:
  - name: gather ios facts
    ios_facts:
      gather_subset: all
```

Either way, this is how you start down the path to true Config-to-Code!

```
ansible_facts:
  ansible_net_fqdn: ios-dc2-rtr.lab.vault112
  ansible_net_gather_subset:
  - interfaces
  ansible_net_hostname: ios-dc2-rtr
  ansible_net_serialnum: X11G14CLASSIFIED...
  ansible_net_system: nxos
  ansible_net_model: 93180yc-ex
  ansible_net_version: 14.22.0F
  ansible_network_resources:
    interfaces:
    - name: Ethernet1/1
      enabled: true
      mode: trunk
    - name: Ethernet1/2
      enabled: false
    ...
```

### Caching Facts

You can also run custom commands, save the output, and parse the configuration later. Any command output can be parsed and set as an Ansible Fact! Setting custom facts and using text parsers works particularly well for building out infrastructure checks/verifications. Or perhaps if you simply want to find something that facts don't already identify:

```
- name: run command
  ios_command:
  commands: 
    show version
  register: output

- name: set version fact
  set_fact:
    cacheable: true
    ansible_net_version: "{{ output.stdout[0] | regex_search('Version (\S+)', '\1') | first }}"
```

Ansible Facts can be cached too! Options include local file, memcached, Redis, and a plethora of others, via Ansible's [Cache Plugins](https://docs.ansible.com/ansible/latest/plugins/cache.html). And caching can be enabled with just the click button [in AWX and Tower](https://docs.ansible.com/ansible-tower/latest/html/userguide/job_templates.html#benefits-of-fact-caching), where you can then view facts via UI and API both.

![fact cache](https://docs.ansible.com/ansible-tower/latest/html/userguide/_images/job-templates-options-use-factcache.png)

The combination of using network facts and fact caching can allow you to poll existing, in-memory data rather than parsing numerous additional commands to constantly check/refresh the device's running config.

### Backups and Restores

I personally consider device backups part of the fact collection process. If you're already connecting to a device and parsing its config, you might as well make a backup too. In the same time that Ansible is parsing config lines, you can easily have it dump the full running-config to a backup location of any kind -- local file, external share, git repo, etc...
```
- ios_config:
  backup: yes
  backup_options:
    filename: "{{ ansible_network_os }}-{{ inventory_hostname }}.cfg"
    dir_path: /var/tmp/backup/
```

And if you want to restore these configs, just grab the most recent backup file:
```
- name: restore config
   ios_config:
    src: /var/tmp/backup/{{ ansible_network_os }}-{{inventory_hostname}}.cfg
```

Another option to restore a config is to pull the last cached fact for the device. This is a great use case for rolling out some changes, validating and having a rollback if the validation fails.

This variable is stored as "ansible_net_config" and contains the entire running config:

```
- name: restore config
   ios_config:
    src: "{{ ansible_net_config }}"
```

### Configs, Commands, and Templates

The bread and butter of Ansible's simplicity is being able to quickly and easily generate configs, perform diffs, and send commands. If you already have full/partial config templates, it's nearly effortless to extract the things that can be easily converted to variables, and run the bulk of your commands through Jinja templates.

```
vlan {{ vlan_id }}
  name {{ vlan_description }}
interface port-channel66.{{ vlan_id }}
  description {{ interface_description }}
  encapsulation dot1q {{ vlan_id }}

```

Once your vars and templates are setup, you can determine where you want the config output staged. At that point, you're ready to generate a template and push commands!

### Config versus State Management - Config to Code

Although templates are quick and easy to create or convert, at the end of the day, you'll ultimately be responsible for determining how/when/where certain changes are being made. If you're managing devices like cattle, this may well be the easiest approach to get started with.

However, you may eventually run into a situation where you need to add/remove AAA/ACL lines in specific orders, orchestrate numerous interface changes, or any number of other situations where simple config templates won't quite be enough. Perhaps your configuration variations span Cisco, Arista, Juniper, or any of the other dozens of network vendors that you may be managing?

Ansible's [Network Resource Modules](https://docs.ansible.com/ansible/latest/network/user_guide/network_resource_modules.html) are the solution to managing device states across different devices and different device types. NRMs already have the logic built in to know how config properties need to be orchestrated in which specific ways, and these modules know how to run the behind-the-scenes commands that get you the desired configuration state.

For a deep dive into Resource Modules, my colleague [Trishna did a wonderful talk at Ansiblefest 2019](https://www.ansible.com/deep-dive-into-ansible-network-resource-module).


### Error Handling

There comes a time in a playbook where you want to have Ansible multiple tasks conditionally. 

Below is an example how many people do this starting out:

```
- name: Configure Interface Settings
  cisco.nxos.nxos_interfaces:
    config: "{{ port_config }}"
    state: replaced
  when: interface_config is defined

- name: Configure Port Channels
  cisco.nxos.nxos_lag_interfaces:
    config: "{{ portchannel_config }}"
    state: replaced
  when: interface_config is defined

- name: Configure VLANs on Trunk Interfaces
  cisco.nxos.nxos_l2_interfaces:
    config: "{{ trunk_config }}"
    state: replaced
  when: interface_config is defined

- name: Configure VLANs on Access Interfaces
  cisco.nxos.nxos_l2_interfaces:
    config: "{{ access_config }}"
    state: replaced
  when: interface_config is defined
    
 ```
 
 Notice the "when: interface_config is defined" after each task. This get's repetitve and makes the playbook messy, especially if you have multiple other tasks that apply to the conditional statemtent.
 
Let's take a look at an example that uses block to consolidate these tasks:

```

- name: Configure Cisco NXOS Interfaces
  block:
    - name: Configure Interface Settings
      cisco.nxos.nxos_interfaces:
        config: "{{ port_config }}"
        state: replaced

    - name: Configure Port Channels
      cisco.nxos.nxos_lag_interfaces:
        config: "{{ portchannel_config }}"
        state: replaced

    - name: Configure VLANs on Trunk Interfaces
      cisco.nxos.nxos_l2_interfaces:
        config: "{{ trunk_config }}"
        state: replaced

    - name: Configure VLANs on Access Interfaces
      cisco.nxos.nxos_l2_interfaces:
        config: "{{ access_config }}"
        state: replaced
  when: interface_config is defined
```

Now the block of tasks only execute if the "interface_config" variable is defined, simple right?

Enter the [Block and Rescue](https://docs.ansible.com/ansible/latest/user_guide/playbooks_blocks.html) operation. If you are familiar with Python think of this as try/except where you can perform a check or task on the try block and catch any errors and handle the output or action in the except block.

Let's take a really simple, and probably unlikely, example of configuring an NTP server:

```


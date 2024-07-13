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

At a minimum, Ansible needs an [inventory file](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html) with these details to run against OS or network hosts:
```
ansible_hostname     hostname_fqdn
ansible_network_os   ios/nxos/etc
ansible_os_family    RedHat/Ubuntu/Windows/etc
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
rhel-dc1-idm
rhel-dc2-idm

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

[linux]
rhel-dc1-idm
rhel-dc2-idm

[linux:vars]
ansible_become=yes
ansible_become_method=enable
ansible_network_os=linux # overwriting this for my custom Facts Machine roles
ansible_os_family=RedHat
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

Regardless of which you prefer, Ansible will give you all the facts about your network devices. This is how you start down the path to true Config-to-Code!

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

--------------

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

--------------

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

--------------

### Config versus State Management - Infrastructure as Code

Although templates are quick and easy to create or convert, at the end of the day, you'll ultimately be responsible for determining how/when/where certain changes are being made. If you're managing devices like cattle, this may well be the easiest approach to get started with.

However, you may eventually run into a situation where you need to add/remove AAA/ACL lines in specific orders, orchestrate numerous interface changes, or any number of other situations where simple config templates won't quite be enough. Perhaps your configuration variations span Cisco, Arista, Juniper, or any of the other dozens of network vendors that you may be managing?

Ansible's [Network Resource Modules](https://docs.ansible.com/ansible/latest/network/user_guide/network_resource_modules.html) are the solution to managing device states across different devices and different device types. NRMs already have the logic built in to know how config properties need to be orchestrated in which specific ways, and these modules know how to run the behind-the-scenes commands that get you the desired configuration state.

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

#### Code to Config!
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

In the example above, the new interface modules will look at an interface config template and determine if it needs to be enabled. If so, it will loop through each interface and begin setting those config values. You’ll do the same sort of thing for your VLANs/Trunks, VPCs, Port Channels, etc…

```
- name: Configure Port Channels
  nxos_lag_interfaces:
    config:
      - name: "{{ item['interface'] }}"
        members: "{{ item['members'] }}"
      state: replaced
  loop: "{{ interface_config }}"
  when: ('port-channel' in item['interface'] and ('members' in item))
```

And if the `nxos_interfaces` configs looks familiar, that’s because they are! It’s the same thing as what you would get from `nxos_facts` parsing the interfaces section:

```
- name: gather nxos facts
  nxos_facts: 
  gather_subset: interfaces
```

#### Config to Code!
If you do it right, you can now take interface facts and pass them right back into Ansible as configuration properties!

```
  ansible_facts:
  ansible_net_fqdn: rtr2
  ansible_net_gather_subset:
  - interfaces
  ansible_net_hostname: rtr2
  ansible_net_serialnum: D01E1309…
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
```

For a deep dive into Network Resource Modules, my colleague [Trishna did a wonderful talk at Ansiblefest 2019](https://www.ansible.com/deep-dive-into-ansible-network-resource-module).

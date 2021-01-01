# Network Configuration with Ansible 
-------------

This repo is an introduction to building a network automation framework:

  * Fact Collection and Configuration Parsing
  * Backups and Restores
  * Generating Config Templates and Pushing to Devices
  * Configuration Management via Command Orchestration and Jinja Templates
  * State Management via Data Model; Config to Code

--------------

## Getting Started

At a minimum, Ansible needs an inventory with these details to run against hosts:
```
ansible_hostname     hostname_fqdn
ansible_network_os   ios/nxos/etc
ansible_username     username
ansible_password     password
```

Your initial inventory file can be setup like this:

```
[all]
hostname_fqdn  ansible_network_os=ios  ansible_username=<username>  ansible_password=<password>
hostname_fqdn  ansible_network_os=nxos  ansible_username=<username>  ansible_password=<password>
```

--------------

### Config Parsing and Inventory Backups

Ansible's native `Fact Collection` is used to parse configs to code. It can be invoked by setting `gather_facts: true` in your top level playbook. And major networking vendor has fact modules that you can use in a playbook task: `ios_facts`, `eos_facts`, `nxos_facts`, `junos_facts`, etc... Fact Collection is the first step to config-to-code! 

You can also run custom commands, save the output, and parse the configuration later. Any command output can be parsed and set as an Ansible Fact! Setting custom facts and using text parsers works particularly well for building out infrastructure checks/verifications. For instance, F5 natively gathers the attached license, but you can identify additional content that will help you automate expiration/renewal processes.

Finally, device backups are largely considered a part of the "fact collection" process. In the same time that Ansible is parsing config lines, you can easily have it dump the full running-config to a backup location of any kind -- local file, external share, git repo, etc...

### Generating Templates and Pushing Configs

The bread and butter of Ansible's simplicity is being able to quickly and easily generate configs, perform diffs, and send commands. If you already have full/partial config templates, it's nearly effortless to extract the things that can be easily converted to variables.


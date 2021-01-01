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

Ansible Facts can be cached in AWX/Tower, as well. The combination of using network facts and fact caching can allow you to poll existing, in-memory data rather than parsing numerous additional commands to constantly check/refresh the device's running config.

Finally, device backups are largely considered a part of the "fact collection" process. In the same time that Ansible is parsing config lines, you can easily have it dump the full running-config to a backup location of any kind -- local file, external share, git repo, etc...

### Generating Config Templates and Pushing Commands

The bread and butter of Ansible's simplicity is being able to quickly and easily generate configs, perform diffs, and send commands. If you already have full/partial config templates, it's nearly effortless to extract the things that can be easily converted to variables, and run the bulk of your commands through Jinja templates.

Once your vars and templates are setup, you can determine where you want the config output staged. At that point, you're ready to generate a template and push commands!

### State versus Config Management

Although templates are quick and easy to create or convert, at the end of the day, you'll ultimately be responsible for determining how/when/where certain changes are being made. If you're managing devices like cattle, this may well be the easiest approach to get started with.

However, you may eventually run into a situation where you need to add/remove AAA/ACL lines in specific orders, orchestrate numerous interface changes, or any number of other situations where simple config templates aren't quite enough. Perhaps your configuration variations span Cisco, Arista, Juniper, or any of the other dozens of network vendors that you may be managing?

Ansible's [Network Resource Modules](https://docs.ansible.com/ansible/latest/network/user_guide/network_resource_modules.html) are the solution to managing device states across different devices and different device types. NRMs already have the logic built in to know how config properties need to be orchestrated in which specific ways, and these modules know how to run the behind-the-scenes commands that get you the desired configuration state.

For a deep dive into Resource Modules, my colleague [Trishna did a wonderful talk at Ansiblefest 2019](https://www.ansible.com/deep-dive-into-ansible-network-resource-module).

# Applying Network Configuration Layers

Depending on your approach to provisioning and making bulk device changes, many people prefer to break down their full network configs into their respective "layers" or functions. In general, this will allow you more flexibility around applying targeted code changes, while reducing the complexity when finding and making code changes.

Example:
```
├─ config_aaa
├─ config_acl
├─ config_certificate
├─ config_interface
├─ config_localpw
├─ config_ntp
├─ config_ospf
├─ config_snmp
├─ config_syslog
├─ config_base
```

# Ansible Role Naming Standards

When adding new roles, it’s suggested that you name them in a manner that will allow you to quickly determine playbook functions. A good naming standard will allow you to make dynamic calls to your playbooks and roles.

Using the `config_aaa` example below, it describes the service or function that it performs.
```
	config_aaa
  {{ service/func }}_{{ entity/object }}
```

A good naming standard opens the door to integrating inventory variables into how we call roles and files through playbooks. Which in turn adds further efficiency to our dynamic configs. Here are some more examples:
```
	config_aaa-ios.yaml
  {{ service/func }}_{{ entity/object }}-{{ ansible_network_os }}.yaml

templates/ios-s2-az2.j2
  templates/{{ ansible_network_os }}-{{ site }}-{{ zone }}.j2

splunk/hostname-20190201-01:14:35.log
  {{ logger }}/{{ ansible_hostname }}-{{ ansible_date_time.date }}.log
```

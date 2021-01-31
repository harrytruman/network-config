# Ansible Networking Role and Directory Structure
Our automation repository should be set up with a file structure that’s representative of our Ansible roles. This sort of directory structure allows us to easily assemble our device configurations in layers.

Example Network Automation Role Structure:

```
├─ config_aaa
│   ├── defaults            # variable defaults that may be commonly changed
│   │   └── main.yaml
│   ├── files               # non-template files
│   │   └── aaa.cert
│   ├── handlers            # intra-role tasks
│   │   └── main.yaml
│   ├── meta                # playbook dependencies
│   │   └── main.yaml
│   ├── tasks               # playbooks
│   │   ├── ios.yaml
│   │   ├── main.yaml       # determines which os to use
│   │   ├── nxos.yaml
│   │   ├── f5-os.yaml
│   ├── templates           # jinja templates
│   │   ├── ios-aaa.j2
│   │   ├── nxos-aaa.j2
│   └── vars                # variables and vaults
│       └── main.yaml
│       └── vault.yaml
...
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

## Ansible Role Naming Standards

When adding new roles, it’s suggested that you name them in a manner that will allow you to quickly determine playbook functions. A good naming standard will allow you to make dynamic calls to your playbooks and roles.

Here’s what Red Hat recommends for Ansible role naming standards. Galaxy roles can not have dashes in them if you are using `ansible-galaxy` to pull them.

```
  # network_config_aaa
  {{ infra }}_{{ service/func }}_{{ entity/object }}
```

Using the `config_aaa` example from above, it describes the service or function that it performs. 

A good naming standard opens the door to integrating inventory variables into how we call roles and files through playbooks. This adds further efficiency to our dynamic configs. Here are some examples:

```
  # config_aaa-ios.yaml
  {{ service/func }}_{{ entity/object }}-{{ ansible_network_os }}.yaml


  # templates/ios-s2-az2.j2
  templates/{{ ansible_network_os }}-{{ site }}-{{ zone }}.j2

  # splunk/hostname-20190201-01:14:35.log
  {{ logger }}/{{ ansible_hostname }}-{{ ansible_date_time.date }}.log
```

## Passing Variables to Ansible Playbooks and Tower Jobs
With our initial set of inventory variables defined, we can now begin thinking about how to use these to create logic and conditionals in our playbooks. We can pass through vars to create dynamic playbook runs.

```
ansible-playbook config_aaa.yaml --extra-vars site=s2

OR

tower-cli job launch --job-template=1054 --extra-vars="ansible_host=ios”
```

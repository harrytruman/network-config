# Inventory, Group, and Host Variables

Ansible's inventory variables are grouped into two classes of internal categories: `groupvars` and `hostvars`. The differences are exactly what you would expect, too. Any info/data that applies to multiple hosts will be contained in `groupvars`, versus per-host info in `hostvars`.

Ideally, `groupvars` will be obtained from your CMDB. But regardless of whether that data is built automatically or manually, our `groupvars` structure will match 1:1 with our inventory classifications.

I usually set my groups based on the `ansible_network_os` so that I can dynamically interact with the data I need:

```
group_vars
  ├─ all
  │   ├── ios
  │   │   └── main.yaml
  │   │   └── vault.yaml
  │   │   └── special.yaml
  │   ├── nxos
  │   │   └── main.yml
  │   ├── aci
  │   │   └── main.yaml
  │   ├── f5
  │   │   └── main.yaml
```

With variables defined like this, you can reference them individually, dynamically:
```
  hostvars['{{ inventory_host }}']['ios']['special']['thing_to_find']
```

## Required Variables

The global inventory variables will be used to determine how, where, and why we make our system changes, and will act as the core of Ansible's logic and conditionals. These two are all Ansible needs to get started:

```
ansible_hostname
ansible_network_os
```

### Custom Variables:

Beyond the obvious hostname and OS type, these are often the first `groupvars` that we define for environment and locational information:

```
site
zone
environment
subdomain
```

And these first `hostvars` offer a quick way for Ansible to determine the individual devices that will be a part of any specific changes:

```
physical name
model number
model family 
mgmt ip
serial
```

Here's an example of how variables will be used as the source for all of our base playbook logic and conditionals:

```
{% if site == "s2" and if zone = “az” %}
ntp source {{ ntp_source_s2 }}
ntp server {{ ntp_server_s2 }} key {{ zone }}
```

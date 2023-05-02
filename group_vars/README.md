# Group and Host Variables

Ansible's inventory variables are grouped into two classes of internal categories: `groupvars` and `hostvars`.

The differences are exactly what you would expect. Any high-level info/data that applies to multiple hosts will be contained in `groupvars`, versus per-host details that are specified in your `hostvars`.

Ideally, `groupvars` are obtained from your CMDB. But regardless of whether that data is built automatically by an inventory script, or populated manually in a file, your `groupvars` structure should match 1:1 with our inventory classifications.

For instance, I usually set my top-level groups based on the `ansible_network_os`, so that I can dynamically interact with the data I need:
```
group_vars
  ├─ all
  │   ├── ios
  │   │   └── main.yaml
  │   │   └── vault.yaml
  │   │   └── special.yaml
  │   ├── nxos
  │   │   └── main.yml
  │   │   └── vault.yaml
  │   │   └── extra.yaml
  │   ├── aci
  │   │   └── main.yaml
  │   │   └── vault.yaml
  │   │   └── unique.yaml
  │   ├── f5
  │   │   └── main.yaml
  │   │   └── vault.yaml
  │   │   └── more_vars.yaml
```

And Ansible allows you to reference variables defined as either `hostvars` _or_ `groupvars`, via the `hostvars` definition which invokes them both. And then you can work your way down the chain.

With any of the above examples -- IOS, NXOS, ACI, or F5 -- and regardless of which file they're in -- these `groupvars` can be referenced individually _or_ dynamically, like so:
```
  hostvars['{{ inventory_host }}']['ansible_network_os']['var']
```

And for broader infrastructure projects, this sort of structure scales well:
```
group_vars
  │  ├── all
  │  │   ├── network
  │  │   │   ├── eos
  │  │   │   ├── ios
  │  │   │   ├── junos
  │  │   │   ├── nxos
  │  │   ├── provisioning
  │  │   │   ├── azure
  │  │   │   ├── vmware
  │  │   ├── linux
  │  │   │   ├── services
  │  │   │   ├── apps
  │  │   ├── windows
  │  │   │   ├── services
  │  │   │   ├── apps
```

With the above example, any Linux `groupvars` would be referenced like this:
```
  ansible_os_family: linux
  hostvars['{{ inventory_host }}']['linux']['services']['vars']
```

Or for Cisco IOS devices:
```
  ansible_network_os: ios
  hostvars['{{ inventory_host }}']['network']['ios']['var']
```

**Note:** Ansible's internal var names can differ between OS and Network devices:

  `ansible_os_family` relates to any sort of OS
  
  `ansible_network_os` relates to any network devices


## Required Variables

The global inventory variables will be used to determine how, where, and why we make our system changes, and will act as the core of Ansible's logic and conditionals. These two vars are all Ansible needs to work with network devices:
```
ansible_hostname
ansible_network_os
```

### Custom Variables:

Beyond the obvious hostname and OS type, the possibilities are endless, but these are often the first `groupvars` that we define for environment and locational information.
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
vars:
  ntp_source_s2: 10.115.120.1
  ntp_s2_key: aje12hg121206b15
  zone: az

{% if site == "s2" and if zone = “az” %}
ntp source {{ ntp_source_s2 }}
ntp server {{ ntp_server_s2 }} key {{ ntp_s2_key }}
{% endif %}
```

### Nested Custom Host Variables:

When taking an Infrastructure as Code (IaC) approach, more often than not your host variables can quickly grow in size depending on your use case (F5, Cisco ACI, etc). The most common setup with Ansible only uses a single host_var file for a device. By setting it as a directory we can cleanly organize each variable based on certain criteria.

An example would be maintaining F5 BigIP objects such as virtual servers, pools, nodes, etc as code:
```
├── host_vars
│   └── f5
│       ├── irules.yml
│       ├── nodes.yml
│       ├── pools.yml
│       └── vips.yml

```

And an example of a variable under nodes.yml:
```
nodes:
  - name: web1
    host: 192.168.100.101
    state: present
  - name: web2
    host: 192.168.100.102
    state: present
  - name: db1
    host: 192.168.101.101
    state: present
  - name: db2
    host: 192.168.101.102
    state: present
```

Now that we have our host_vars directory and these variable files filled out we can then simply reference the "nodes" var that we just created. Ansible will automatically pull these variables in for use, so no need to do an "include_vars" or anything sepcial!
```

---
- name: Configure F5 Objects
  hosts: f5
  gather_facts: no

  tasks:
    - debug:
        msg: "{{ nodes }}"



ok: [f5] => {
    "msg": [
        {
            "host": "192.168.100.101",
            "name": "web1",
            "state": "present"
        },
        {
            "host": "192.168.100.102",
            "name": "web2",
            "state": "present"
        },
        {
            "host": "192.168.101.101",
            "name": "db1",
            "state": "present"
        },
        {
            "host": "192.168.101.102",
            "name": "db2",
            "state": "present"
        }
    ]
}

```

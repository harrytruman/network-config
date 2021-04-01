Network Config Management
=========

This role uses command templates to orchestrate device changes. Jinja templates will be used to orchestrate commands depending on the vendor, model, device type, or any other preferred method of differentiating devices and locations.

To use this role, place your config templates in the `templates` directory. In `tasks/main.yml`, ensure your inventory OS' are correct (ios, nxos, eos, etc).

Examples
----------------

Jinja template for BGP configs:
```
router bgp {{ bgp_as }}
 bgp router-id {{ bgp_router_id }}
 bgp log-neighbor-changes
 
 {% for network in bgp_networks %}
 network {{ network | ipaddr('network') }} mask {{ network | ipaddr('netmask') }}
 {% endfor %}
 
 {% for network in bgp_agg_addresses %}
 aggregate-address {{ network | ipaddr('network') }} {{ network | ipaddr('netmask') }} summary-only
 {% endfor %}
 
 {% for redistribute in bgp_redistribute %}
 redistribute {{ redistribute['name'] }} route-map {{ redistribute['route_map'] }}
 {% endfor %}
 
 {% for neighbor in bgp_neighbors %}
 neighbor {{ neighbor['neighbor'] }} remote-as {{ neighbor['remote_as'] }}
 neighbor {{ neighbor['neighbor'] }} password {{ neighbor['password'] }}
 neighbor {{ neighbor['neighbor'] }} fall-over bfd
 {% if neighbor['route_map'] %}
 neighbor {{ neighbor['neighbor'] }} route-map {{ neighbor['route_map']['name'] }} {{ neighbor['route_map']['direction'] }}
 {% endif %}
 {% endfor %}
```

Pushing a single template:
```
- name: push new device config
  nxos_config:
    src: "/var/tmp/config/nxos-int.j2"
```

Pushing multiple templates:
```
- name: push new device config
  nxos_config:
    src: "{{ item }}"
  with_items:
    - "../templates/nxos-int.j2"
    - "../templates/nxos-bgp.j2"
    - "../templates/nxos-routemap.j2"
    - "../templates/nxos-prefix.j2"
```

Requirements
------------

Ansible 2.9+
Tower 3.7+

Dependencies
------------

N.A

License
-------

GPLv3

Author Information
------------------

Landon Holley - landon@redhat.com

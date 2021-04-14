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

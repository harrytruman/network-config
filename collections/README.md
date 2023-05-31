# Collections

Collections are a distribution format for Ansible content that can include playbooks, roles, modules, and plugins. You can install and use collections through a distribution server, such as Ansible Galaxy, or a Pulp 3 Galaxy server.

## Installing collections with `ansible-galaxy`

By default, ansible-galaxy collection install uses https://galaxy.ansible.com as the Galaxy server (as listed in the `ansible.cfg` file under `GALAXY_SERVER`). You do not need any further configuration.

* To **install** a collection hosted in Galaxy:

```
ansible-galaxy collection install my_namespace.my_collection
```

* To **upgrade** a collection to the latest available version from the Galaxy server, you can use the --upgrade option:

```
ansible-galaxy collection install my_namespace.my_collection --upgrade
```

* You can also directly use the **tarball** from your build:

```
ansible-galaxy collection install my_namespace-my_collection-1.0.0.tar.gz -p ./collections
```

* You can build and install a collection from a **local source directory**.
The ansible-galaxy utility builds the collection using the MANIFEST.json or galaxy.yml metadata in the directory.

```
ansible-galaxy collection install /path/to/collection -p ./collections
```

* Finally, you can also install multiple collections in a namespace directory.
```
ns/
├── collection1/
│   ├── MANIFEST.json
│   └── plugins/
└── collection2/
    ├── galaxy.yml
    └── plugins/
```
```ansible-galaxy collection install /path/to/ns -p ./collections```

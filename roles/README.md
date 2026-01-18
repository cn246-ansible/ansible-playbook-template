# roles

This directory contains Ansible roles used by this control repository.

Each role should live in its own subdirectory and follow the standard
Ansible role layout:
```
roles
└── my_role
    ├── defaults
    ├── files
    ├── handlers
    ├── meta
    ├── tasks
    ├── templates
    └── vars
```

Roles can be used by playbooks in this repository or shared across
multiple playbooks via Git submodules or Galaxy, depending on your
workflow.

Avoid committing generated files or secrets into roles. Use Ansible
Vault where appropriate.

# host_vars

This directory contains host-specific variables for Ansible inventories.

Each file or directory should be named after the corresponding host in the inventory.

Host variables override group variables. Use this directory sparingly
and prefer group_vars where possible to keep configuration manageable.

Sensitive values should be encrypted using Ansible Vault.

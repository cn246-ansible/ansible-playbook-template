# Bin Scripts

This directory contains executable scripts for managing and running Ansible in this project.


## Ansible Command Shims

These wrappers ensure Ansible commands run via `uv` with locked dependencies from this project's `pyproject.toml`:

| Script | Purpose |
|--------|---------|
| `ansible` | Run ad-hoc Ansible commands |
| `ansible-config` | View and validate Ansible configuration |
| `ansible-console` | Interactive Ansible console (REPL) |
| `ansible-doc` | View documentation for modules and plugins |
| `ansible-galaxy` | Install and manage collections and roles |
| `ansible-inventory` | Display and validate inventory |
| `ansible-playbook` | Execute playbooks |
| `ansible-pull` | Pull playbooks from VCS and execute locally |
| `ansible-vault` | Manage encrypted vault files |

**Why shims?** They ensure everyone uses the same Ansible version via `uv run`, avoiding "works on my machine" issues with system-installed Ansible.

**Usage:**
```bash
# These automatically use the project's uv environment
./bin/ansible --version
./bin/ansible-playbook site.yml
./bin/ansible-vault edit secrets.vault.yml
```

When `./bin` is in your PATH (via direnv), you can omit the `./bin/` prefix.


## Setup Scripts

| Script | Purpose | When to Run |
|--------|---------|-------------|
| `git-setup` | Configure Git for Ansible Vault merge/diff drivers | Once after clone, or when updating git config |
| `worktree-bootstrap` | Initialize worktree with dependencies and collections | After cloning the repo, after creating a new worktree, or to refresh dependencies |
| `worktree-create` | Create a new Git worktree in a separate directory | When you need to work on multiple branches simultaneously |


## Library Scripts

| Script | Purpose |
|--------|---------|
| `_ansible_shim_lib.sh` | Shared library for shim scripts (sourced, not executed) |
| `ansible-vault-merge` | Git merge driver for encrypted vault files (called by Git) |


## Creating Additional Worktrees

To work on multiple branches simultaneously without switching:
```bash
# Create a new worktree for a feature branch
bin/worktree-create feature-name

# Or specify a custom path
bin/worktree-create feature-name

# Then bootstrap it
cd ../ansible-feature-name
bin/worktree-bootstrap
```

Each worktree has its own `.venv` and `collections`, allowing you to test
different dependency versions or work on conflicting changes in parallel.


## Adding New Shims

To add a new Ansible command shim:

1. Create a new file (e.g., `ansible-doc`):
```bash
#!/usr/bin/env bash
# Ansible Doc shim - runs 'ansible-doc' via uv with locked dependencies
# See ./ansible for full documentation

set -euo pipefail

# shellcheck source=./_ansible_shim_lib.sh
. "$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/_ansible_shim_lib.sh"

ansible_shim_exec ansible-doc "$@"
```

2. Make it executable:
```bash
chmod +x bin/ansible-doc
```

3. Commit it:
```bash
git add bin/ansible-doc
git commit -m "Add ansible-doc shim"
```


## Troubleshooting

**Shim not found:**
```bash
# Check if direnv loaded the PATH
echo $PATH | grep -o './bin'

# If not, reload direnv
direnv allow
```

**Wrong Ansible version:**
```bash
# Verify shim is being used, not system ansible
command -v ansible
# Should show: ./bin/ansible or /full/path/to/project/bin/ansible

# Check the actual version
./bin/ansible --version
```

**Permission denied:**
```bash
# Make scripts executable
chmod +x bin/*
```

## See Also

- [Project README](../README.md) - Main project documentation
- [Collections README](../collections/README.md) - Ansible collections management
- [uv documentation](https://docs.astral.sh/uv/) - Python package manager

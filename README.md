# Ansible Control Repository

This repository is a self contained Ansible control environment designed for
repeatable, isolated infrastructure work.

It provides a fixed Ansible and Python runtime, repo local tooling, and a
workflow built around Git worktrees so that experimentation does not affect
stable configurations.

The intent is that each branch can act as its own Ansible control plane with
independent Python dependencies and Galaxy collections.


This repository includes:

- A pinned **ansible-core** version and Python dependencies managed with **uv**
- Repo local Ansible command shims in `bin/` so no global Ansible install is required
- Repo local Galaxy collections installed into `collections/`
- Support for custom plugins in `plugins/`
- **direnv** based environment activation
- Cached shell completions for Ansible commands
- Git integration for Ansible Vault, including diff, merge, and grep support
- First class support for Git worktrees

All state required to run Ansible lives inside the repository or the user home
directory. Nothing is installed globally.


## Requirements

The following tools must be installed on the local system:

- [uv](https://github.com/astral-sh/uv)
- [direnv](https://github.com/direnv/direnv)
- SSH access to target hosts
- A local Ansible Vault password file at: `~/.ansible-vault-pass`


## Enable direnv

**direnv** must be installed and enabled in your shell before using this repository.

### Bash
Add the following to `~/.bashrc`:
```bash
eval "$(direnv hook bash)"
```

### Zsh
Add the following to `~/.zshrc`:
```bash
eval "$(direnv hook zsh)"
autoload -U bashcompinit
bashcompinit
```

Refer to the [direnv documentation](https://direnv.net/docs/installation.html)
for more details on configuring your shell.


## Getting started
Clone this repository or create a new repository from it using your Git hosting
provider's template feature.

From the repository root, run:
```bash
direnv allow
bin/git-setup
bin/worktree-bootstrap
```

This performs the initial setup for the current worktree:

- Creates or updates the Python virtual environment in `.venv`
- Installs Galaxy collections into collections
- Generates cached shell completions into `.direnv/completions`
- Configures Git for Ansible Vault and structured diffs
- After this completes, Ansible is ready to use.


### Production Deployments

For production deployments where development tools aren't needed, use:
```bash
UV_SYNC_FLAGS="--no-dev" bin/worktree-bootstrap
```

This skips installing `ansible-lint`, `yamllint` and other development dependencies,
resulting in a faster, smaller installation.

Use production mode in CI/CD pipelines or when deploying to servers where only
playbook execution is needed.


## Using Git worktrees
The recommended workflow is to keep main stable and use worktrees for development, upgrades, and experimentation.

### Creating a new worktree
From the main worktree, create a new branch and a new working directory next to the main repo:
```bash
bin/worktree-create dev
```

Then initialize the new worktree:
```bash
cd ../<repo>-dev
direnv allow
bin/worktree-bootstrap
```

Each worktree has its own .venv, collections, and runtime state. Because `uv`
uses a shared package cache, additional virtual environments require minimal extra
disk space.


## Typical workflow
Make changes in a development worktree

  - Update Python dependencies
  - Change Galaxy collection versions
  - Add or modify plugins
  - Test playbooks


Merge back into main when ready:
```bash
cd ../<repo>
git merge dev
direnv allow
bin/worktree-bootstrap
```

This rebuilds the main worktree using its own isolated environment.


## Running Ansible

Always use the repo local Ansible commands provided in `bin/`.

Examples:
```bash
ansible --version
ansible-playbook site.yml
ansible-galaxy collection list
ansible-vault edit roles/my_role/files/secret.vault.yml
```

Commands can be run from any directory inside the worktree thanks to direnv
prepending the bin directory to `PATH`.


## Vault integration

This repository is configured to work directly with Ansible Vault.

Vaulted files can be:

- **Viewed with `git diff`** - Decrypted content shown in terminal (not written to disk)
- **Searched with `git grep`** - Search inside encrypted files (decryption happens in memory via pipe)
- **Merged with custom driver** - Decrypts, merges, and re-encrypts automatically


**Security Notes:**
- `git diff` and `git grep` process decrypted content through pipes (no disk writes)
- The merge driver temporarily writes decrypted content to `$TMPDIR`, then securely deletes it
- Plaintext secrets are never committed to Git history
- On shared/untrusted systems, set `TMPDIR` to an encrypted location before merging


## Repository layout
Key directories include:

- `roles/` for Ansible roles
- `group_vars/` and `host_vars/` for inventory variables
- `plugins/` for custom Ansible plugins
- `collections/` for Galaxy collections defined by `requirements.yml`

Each of these directories contains a README describing its intended use.


---

This repository favors explicit tooling over global state and hidden dependencies.
Using Git worktrees allows multiple Ansible environments to exist side by side
without stashing, rebasing, or reinstalling dependencies.

The result is a workflow where infrastructure changes can be tested safely and
merged deliberately.


## References

### Essential Documentation
- [Ansible Docs](https://docs.ansible.com/) - Official Ansible documentation
- [uv Documentation](https://docs.astral.sh/uv/) - Python package manager
- [direnv](https://direnv.net/) - Environment management
- [Git Attributes](https://git-scm.com/docs/gitattributes) - Git path-specific configuration

### Tools & Utilities
- [ansible-lint](https://ansible.readthedocs.io/projects/lint/) - Playbook linting
- [ShellCheck](https://www.shellcheck.net/) - Shell script analysis
- [Ansible Galaxy](https://galaxy.ansible.com/) - Community collections

### Learning Resources
- [Ansible for DevOps](https://www.ansiblefordevops.com/) - Comprehensive Ansible book
- [Pro Git Book](https://git-scm.com/book/en/v2) - Free Git guide
- [Ansible Forum](https://forum.ansible.com/) - Community support

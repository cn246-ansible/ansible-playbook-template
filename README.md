# Ansible Control Repository
This repository is a self contained Ansible control environment designed for
repeatable, isolated infrastructure work.

It provides a fixed Ansible and Python runtime, repo local tooling, and a
workflow built around Git worktrees so that experimentation does not affect
stable configurations.

The intent is that each worktree acts as its own Ansible control plane with an
independent Python environment, installed Galaxy collections, and Ansible runtime
state.

This repository includes:
  * A pinned `ansible-core` version and Python dependencies managed with `uv`
  * Galaxy collections installed per worktree into `.ansible/collections/`
  * Custom or locally developed collections available through `collections/`
  * Support for custom plugins in `plugins/`
  * `direnv` based environment activation
  * Cached shell completions for `ansible` commands
  * Git integration for Ansible Vault, including diff, merge, and grep support
  * First class support for Git worktrees

Python packages are cached by `uv` and can therefore be shared between worktrees.
Galaxy collections are not shared between worktrees; each worktree installs its
own copy into `.ansible/collections/`.

Ansible runtime state required by a worktree lives inside the worktree or the
user's home directory. Nothing is installed globally.


## Requirements
The following tools must be installed or available on the local system:
  * [uv](https://github.com/astral-sh/uv)
  * [direnv](https://github.com/direnv/direnv)
  * SSH access to target hosts
  * A local Ansible Vault password file at: `~/.ansible-vault-pass`


## Enable direnv
**direnv** must be installed and enabled in your shell before using this repository.

Refer to the [direnv documentation](https://direnv.net/docs/installation.html)
for more details on configuring your shell.


## Getting started
Clone this repository or create a new repository from it using your Git hosting
provider's template feature.

I prefer to create a parent directory, clone this repository as "main" so the
worktree workflow is more apparent.

```bash
# Create parent directory
mkdir my-playbook
cd my-playbook

# Clone this repo as `main`
git clone git@github.com:chuckn246/ansible-control-template.git main
cd main

# Install and configure Ansible
direnv allow
git-setup
worktree-bootstrap

# Verify
ansible --version
ansible-galaxy collection list
```

This initializes the current worktree's local Ansible environment:
  * Configures Git for Ansible Vault and structured diffs
  * Creates or updates the Python virtual environment in `.venv`
  * Installs Galaxy collections into `.ansible/collections`
  * Generates cached shell completions into `.direnv/completions`
  * After this completes, Ansible is ready to use.


### Production Deployments
For production deployments where development tools aren't needed, use:
```bash
UV_SYNC_FLAGS="--no-dev" bin/worktree-bootstrap
```

This skips installing `ansible-lint`, `yamllint` and other development dependencies,
resulting in a faster, smaller installation.

Use production mode in CI/CD pipelines or on control hosts where only playbook
execution is required.


## Using Git worktrees
The recommended workflow is to keep main stable and use worktrees for development, upgrades, and experimentation.


### Creating a new worktree
From the main worktree, create a new branch and a new working directory next to the main repo:
```bash
worktree-create dev
```

Then initialize the new worktree:
```bash
cd ../dev
direnv allow
worktree-bootstrap
```

Each worktree has its own .venv, collections, and runtime state. Because `uv`
uses a shared package cache, additional virtual environments require minimal extra
disk space.


## Typical workflow
Make changes in a development worktree, for example:
  * Update Python dependencies
  * Change Galaxy collection versions
  * Add or modify plugins
  * Test playbooks


Merge back into main when ready:
```bash
cd ../main
git merge dev
direnv allow
worktree-bootstrap
```

This rebuilds the main worktree using its own isolated environment.


## Running Ansible

Examples:
```bash
ansible --version
ansible-playbook site.yml
ansible-galaxy collection list
ansible-vault edit roles/my_role/files/secret.vault.yml
```

Commands can be run from any directory inside the worktree thanks to **direnv**
prepending the `.venv/bin` directory to `PATH`.


## Vault integration

This repository is configured to work directly with Ansible Vault.

Vaulted files can be:
  * **Viewed with `git diff`** - Decrypted content shown in terminal (not written to disk)
  * **Searched with `git grep`** - Search inside encrypted files (decryption happens in memory via pipe)
  * **Merged with custom driver** - Decrypts, merges, and re-encrypts automatically


**Security Notes:**
  * `git diff` and `git grep` process decrypted content through pipes (no disk writes)
  * The merge driver temporarily writes decrypted content to `$TMPDIR`, then securely deletes it
  * Plaintext secrets are never committed to Git history
  * On shared/untrusted systems, set `TMPDIR` to an encrypted location before merging


## Repository layout
Key directories include:

  * `.ansible/collections/` for Galaxy collections installed from `requirements.yml`
  * `.direnv/` for generated direnv state and cached shell completions
  * `.venv/` for the worktree-local Python environment
  * `collections/` for symlinks to custom or locally developed collections
  * `group_vars/` and `host_vars/` for inventory variables
  * `plugins/` for custom Ansible plugins
  * `roles/` for local or custom Ansible roles - useful for development

Galaxy collections installed into `.ansible/collections/` are not committed to
Git and are not shared between worktrees. Each worktree installs its own copy.

Custom collections referenced through `collections/` are maintained outside this
repository and may have their own Git repository.

Most of these directories contain a README describing their intended use.

---

This repository favors explicit tooling over global state and hidden dependencies.
Using Git worktrees allows multiple Ansible environments to exist side by side
without stashing, rebasing, or reinstalling dependencies.

The result is a workflow where infrastructure changes can be tested safely and
merged deliberately.


## References

### Essential Documentation
  * [Ansible Docs](https://docs.ansible.com/) - Official Ansible documentation
  * [uv Documentation](https://docs.astral.sh/uv/) - Python package manager
  * [direnv](https://direnv.net/) - Environment management
  * [Git Attributes](https://git-scm.com/docs/gitattributes) - Git path-specific configuration

### Tools & Utilities
  * [ansible-lint](https://ansible.readthedocs.io/projects/lint/) - Playbook linting
  * [ShellCheck](https://www.shellcheck.net/) - Shell script analysis
  * [Ansible Galaxy](https://galaxy.ansible.com/) - Community collections

### Learning Resources
  * [Ansible for DevOps](https://www.ansiblefordevops.com/) - Comprehensive Ansible book
  * [Pro Git Book](https://git-scm.com/book/en/v2) - Free Git guide
  * [Ansible Forum](https://forum.ansible.com/) - Community support

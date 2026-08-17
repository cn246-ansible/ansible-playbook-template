# Bin Scripts
This directory contains executable scripts for managing the Ansible setup and
configuration in this project.


## Setup Scripts
| Script | Purpose | When to Run |
|--------|---------|-------------|
| `git-setup` | Configure Git for Ansible Vault merge/diff drivers | Once after clone, or when updating git config |
| `worktree-bootstrap` | Initialize worktree with dependencies and collections | After cloning the repo, after creating a new worktree, or to refresh dependencies |
| `worktree-create` | Create a new Git worktree in a separate directory | When you need to work on multiple branches simultaneously |


## Library Scripts

| Script | Purpose |
|--------|---------|
| `ansible-vault-merge` | Git merge driver for encrypted vault files (called by Git) |


## Creating Additional Worktrees

To work on multiple branches simultaneously without switching:
```bash
# Create a new worktree for a feature branch
bin/worktree-create feature-name

# Then bootstrap it
cd ../feature-name
bin/worktree-bootstrap
```

Each worktree has its own `.venv` and `collections`, allowing you to test
different dependency versions or work on conflicting changes in parallel. `uv`
keeps the `.venv` lightweight by only downloading modules that do not already
exist on the system.


## See Also
- [Project README](../README.md) - Main project documentation
- [Collections README](../collections/README.md) - Ansible collections management
- [uv documentation](https://docs.astral.sh/uv/) - Python package manager
- [direnv documentation](https://direnv.net/) - Shell extension

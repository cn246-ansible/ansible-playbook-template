# Ansible Collections
This directory provides the Ansible collection search path for this playbook
repository.

It serves two purposes:

1. Locally developed collections can be made available to Ansible through
   symlinks in `collections/ansible_collections/`.
2. Galaxy collections installed from the repository's top-level
   `requirements.yml` are installed into `.ansible/collections/`.


## Overview
Galaxy collections are dependencies of the control repository. Their version
constraints are defined in the top-level `requirements.yml` and the collections
are installed into the worktree's `.ansible/collections/` directory.

Installed Galaxy collections are not committed to Git and are not shared
between worktrees. Each worktree installs its own copy.

Locally developed collections are different. They are maintained separately
from the playbook repository and can be linked into this directory during
development.


## Structure
```
repo_root
    ├── requirements.yml
    ├── .ansible/
    │   └── collections/
    │       └── ansible_collections/
    │           └── <namespace>/
    │               └── <collection>
    └── collections/
        └── ansible_collections/
            └── <namespace>/
                └── <collection> -> /path/to/local/collection
```

The top-level `requirements.yml` defines Galaxy dependencies.

The `.ansible/collections/` directory contains collections installed for the
current worktree.

The `collections/ansible_collections/` directory contains locally developed
collections made available through the configured Ansible collection search
path.


## Installing Galaxy Collections
Galaxy collections are defined in the repository's top-level `requirements.yml`.

From the repository root:
```bash
# Install all Galaxy collections
ansible-galaxy collection install -r requirements.yml

# Force reinstall
ansible-galaxy collection install -r requirements.yml --force

# bin/worktree-bootstrap handles this automatically for new worktrees
```


## Current Collections
The following collections are defined in `requirements.yml`:

| Collection | Version Constraint | Purpose |
|------------|-------------------|---------|
| `ansible.netcommon` | `>=8,<9` | Network automation common modules |
| `ansible.posix` | `>=2,<3` | POSIX-specific modules (mount, sysctl, etc.) |
| `ansible.utils` | `>=6,<7` | Utility plugins for data manipulation |
| `community.general` | `>=12,<13` | General-purpose community modules |
| `community.mysql` | `>=4,<5` | MySQL/MariaDB database management |
| `community.dns` | `>=3,<4` | DNS management modules |
| `containers.podman` | ">=1,<2" | Container management for testing with molecule |


## Adding New Collections
1. **Find the collection** on [Ansible Galaxy](https://galaxy.ansible.com/)

2. **Add to `requirements.yml`**:
```yaml
collections:
  # ... existing collections ...

  - name: "community.docker"
    version: ">=4,<5"  # Use semantic versioning constraints
```

3. **Install the new collection**:
```bash
ansible-galaxy collection install -r requirements.yml
```

4. **Commit only the requirements file**:
```bash
git add requirements.yml
git commit -m "Add community.docker collection"
```


## Version Constraints
We use **optimistic version constraints** to balance stability and updates:
```yaml
# Recommended: Allow minor/patch updates, prevent breaking changes
- name: "community.general"
  version: ">=12,<13"  # Allows 12.0.0 through 12.99.99

# Specific version (not recommended - prevents security updates)
- name: "community.general"
  version: "12.0.0"

# Latest (dangerous - may break playbooks)
- name: "community.general"
  # No version specified - uses latest
```

Use `>=X,<Y` where `Y = X + 1` to allow minor/patch updates while preventing
major version changes.


## Verifying Installed Collections
```bash
# List all installed collections
ansible-galaxy collection list

# Show details of a specific collection
ansible-galaxy collection list ansible.posix

# Verify collection versions match requirements
ansible-galaxy collection verify -r requirements.yml
```


## Updating Collections
```bash
# Update to latest versions within constraints
ansible-galaxy collection install -r requirements.yml --upgrade

# Update a specific collection
ansible-galaxy collection install ansible.posix --upgrade

# Check for newer versions
ansible-galaxy collection list | grep -E 'ansible|community'
```


## Troubleshooting
### Collections Not Found
If Ansible can't find collections, check the search path:
```bash
ansible-config dump | grep COLLECTIONS_PATHS

# Locally developed collections
ls -al collections/ansible_collections/

# Galaxy-installed collections
ls -al .ansible/collections/ansible_collections/
```


### Version Conflicts
If you encounter version conflicts:
```bash
# Force reinstall with correct versions
ansible-galaxy collection install -r requirements.yml --force

# Or remove and reinstall
rm -rf .ansible/collections/
ansible-galaxy collection install -r requirements.yml
```


### Permission Issues
If installation fails with permission errors:
```bash
# Ensure you're using the project's ansible-galaxy shim
which ansible-galaxy
# Should show: .venv/bin/ansible-galaxy

# Or verify collections_path is writable
ls -dl ./collections/
```


## CI/CD Integration
For Bamboo/Octopus pipelines, install collections before running playbooks:
```bash
# In your deployment script:
cd /path/to/ansible/project
worktree-bootstrap
ansible-playbook site.yml
```

Or use a pre-deployment task:
```yaml
# bamboo-specs/deployment.yml
- script: |
    cd ${bamboo.build.working.directory}
	worktree-bootstrap
```


## Development Workflow
1. **Developer adds a new collection** (in repository root):
```bash
# Edit requirements.yml
vim requirements.yml

# Install locally
ansible-galaxy collection install -r requirements.yml

# Test playbook with new collection
ansible-playbook playbooks/test.yml

# Commit only requirements.yml
git add requirements.yml
git commit -m "Add community.docker for container management"
```

2. **Team member pulls changes** (also in repository root):
```bash
git pull

# direnv automatically uses project config, just install collections
ansible-galaxy collection install -r requirements.yml

# bin/worktree-bootstrap handles this automatically for new worktrees
```


## Notes
- Galaxy collections are installed to `.ansible/collections/ansible_collections/`
  for the current worktree.
- Locally developed collections are made available through
  `collections/ansible_collections/`, typically using symlinks.
- Installed Galaxy collections are gitignored and are not committed to the
  repository.
- Galaxy collections are not shared between Git worktrees; each worktree
  installs its own copy.
- Always test playbooks after updating collections, especially after major
  version updates.
- For production deployments, consider pinning collections to specific
  versions for reproducibility.


## References

- [Ansible Collections Overview](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html)
- [Ansible Galaxy](https://galaxy.ansible.com/)
- [Collection Requirements File](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html#installing-collections-with-ansible-galaxy)
- [Semantic Versioning](https://semver.org/)

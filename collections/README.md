# Ansible Collections

This directory manages Ansible collections for this playbook using `ansible-galaxy`.


## Overview

Collections are installed from [Ansible Galaxy](https://galaxy.ansible.com/)
based on the version constraints defined in `requirements.yml`. The actual
collection files are **not committed to git** - only the requirements file is
tracked.


## Structure
```
collections/
├── README.md              # This file
├── requirements.yml       # Collection dependencies (tracked in git)
└── ansible_collections/   # Installed collections (gitignored)
    ├── my_collection/
    │   ├── netcommon/
    │   ├── posix/
    │   └── utils/
    └── community/
        ├── dns/
        ├── general/
        └── mysql/
```


## Installing Collections

Collections are automatically installed when you run Ansible commands via the
`./bin` shims, or you can manually install them:

```bash
# Install all collections defined in requirements.yml
ansible-galaxy collection install -r requirements.yml

# Or using the shim (recommended - ensures correct uv environment)
./bin/ansible-galaxy collection install -r requirements.yml

# Force reinstall/upgrade collections
ansible-galaxy collection install -r requirements.yml --force
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
git add collections/requirements.yml
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

**Best practice**: Use `>=X,<Y` where `Y = X + 1` to allow minor/patch updates
while preventing major version changes.


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
# Verify collections_path in ansible.cfg
grep collections_path ../ansible.cfg
# Should show: collections_path = ./collections

# Verify collections are installed
ls -la ansible_collections/
```


### Version Conflicts

If you encounter version conflicts:
```bash
# Force reinstall with correct versions
ansible-galaxy collection install -r requirements.yml --force

# Or remove and reinstall
rm -rf ansible_collections/
ansible-galaxy collection install -r requirements.yml
```


### Permission Issues

If installation fails with permission errors:
```bash
# Ensure you're using the project's ansible-galaxy shim
which ansible-galaxy
# Should show: ./bin/ansible-galaxy

# Or verify collections_path is writable
ls -ld ./collections/
```


## CI/CD Integration

For Bamboo/Octopus pipelines, install collections before running playbooks:
```bash
# In your deployment script:
cd /path/to/ansible/project
./bin/ansible-galaxy collection install -r collections/requirements.yml
./bin/ansible-playbook site.yml
```

Or use a pre-deployment task:
```yaml
# bamboo-specs/deployment.yml
- script: |
    cd ${bamboo.build.working.directory}
    ./bin/ansible-galaxy collection install -r collections/requirements.yml --force
```


## Development Workflow

1. **Developer adds a new collection**:
```bash
# Edit requirements.yml
vim requirements.yml

# Install locally
ansible-galaxy collection install -r requirements.yml

# Test playbook with new collection
ansible-playbook test.yml

# Commit only requirements.yml
git add requirements.yml
git commit -m "Add community.docker for container management"
```

2. **Team member pulls changes**:
```bash
git pull

# direnv automatically uses project config, just install collections
ansible-galaxy collection install -r requirements.yml

# Or if using automation, it's handled automatically
```

## References

- [Ansible Collections Overview](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html)
- [Ansible Galaxy](https://galaxy.ansible.com/)
- [Collection Requirements File](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html#installing-collections-with-ansible-galaxy)
- [Semantic Versioning](https://semver.org/)


## Notes

- Collections are installed to `./collections/ansible_collections/` as specified in `ansible.cfg`
- The `ansible_collections/` directory is gitignored to avoid bloating the repository
- Always test playbooks after updating collections, especially major version updates
- For production deployments, consider pinning to specific versions for reproducibility

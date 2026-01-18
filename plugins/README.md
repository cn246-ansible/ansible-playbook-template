# Ansible Plugins

This directory contains custom Ansible plugins for extending functionality beyond what's provided by collections.

## Overview

Plugins extend Ansible's core capabilities with custom behavior. Unlike collections
(which are installed externally), these plugins are **project-specific** and
versioned with your playbook code.

The repository's `ansible.cfg` is configured to automatically load plugins from this directory via:
```ini
plugin_path = ./plugins
```


## Example Structure
```
plugins/
├── README.md          # This file
├── action/            # Action plugins (modify task execution)
├── callback/          # Callback plugins (output formatting, logging, metrics)
├── connection/        # Connection plugins (alternative transport methods)
├── filter/            # Filter plugins (custom Jinja2 filters)
├── inventory/         # Dynamic inventory plugins
├── lookup/            # Lookup plugins (fetch data from external sources)
├── modules/           # Custom modules (task implementations)
├── module_utils/      # Shared code for modules
├── strategy/          # Strategy plugins (playbook execution flow)
├── test/              # Test plugins (custom Jinja2 tests)
└── vars/              # Vars plugins (inject variables)
```

**Note:** Only create subdirectories for plugin types you actually use.


## References

### Official Documentation

- [Developing Plugins](https://docs.ansible.com/ansible/latest/dev_guide/developing_plugins.html) - Plugin development guide
- [Plugin Types](https://docs.ansible.com/ansible/latest/plugins/plugins.html) - Complete list of plugin types
- [Filter Plugins](https://docs.ansible.com/ansible/latest/dev_guide/developing_plugins.html#filter-plugins) - Creating custom filters
- [Lookup Plugins](https://docs.ansible.com/ansible/latest/dev_guide/developing_plugins.html#lookup-plugins) - Creating custom lookups
- [Callback Plugins](https://docs.ansible.com/ansible/latest/dev_guide/developing_plugins.html#callback-plugins) - Output and logging plugins
- [Module Development](https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html) - Creating custom modules


### Plugin Examples

- [Ansible Plugin Examples](https://github.com/ansible/ansible/tree/devel/lib/ansible/plugins) - Official plugin source code
- [Community General Plugins](https://github.com/ansible-collections/community.general/tree/main/plugins) - Real-world examples
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html) - Development guidelines


### Testing & Quality

- [ansible-lint](https://ansible.readthedocs.io/projects/lint/) - Linting tool
- [Molecule](https://ansible.readthedocs.io/projects/molecule/) - Plugin testing framework
- [Python Type Hints](https://docs.python.org/3/library/typing.html) - Type annotation guide


### Related Resources

- [Ansible Collections](../collections/README.md) - Managing external collections
- [Jinja2 Documentation](https://jinja.palletsprojects.com/) - Template syntax for filters/tests
- [Python Plugin APIs](https://docs.ansible.com/ansible/latest/dev_guide/developing_api.html) - Ansible Python APIs


## Notes

- Plugins in this directory take precedence over plugins from collections with the same name
- Keep plugins compatible with the `ansible-core` version specified in `pyproject.toml`
- Consider contributing useful plugins back to community collections
- Use collections for reusable plugins across multiple projects
- Use this directory for project-specific, one-off customizations

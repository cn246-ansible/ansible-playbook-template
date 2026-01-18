#!/usr/bin/env bash

# Ansible Shim Library
#
# Provides ansible_shim_exec() to run Ansible commands via uv in isolated environments.
# Resolves symlinks to find the project root containing ansible.cfg and pyproject.toml.
#
# Usage in shim scripts:
#   source _ansible_shim_lib.sh
#   ansible_shim_exec ansible "$@"
#
# Requirements:
#   - uv (https://docs.astral.sh/uv/)
#   - pyproject.toml with ansible dependencies
#   - ansible.cfg in project root
#
# Exit codes:
#   2   - Missing subcommand
#   127 - uv command not found

set -euo pipefail
[[ "${ANSIBLE_SHIM_DEBUG:-}" == "1" ]] && set -x

# Resolve repo root even if the shim is a symlink.
_ansible_shim_root() {
  local source="${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}"
  while [[ -L "${source}" ]]; do
    local dir
    dir="$(CDPATH='' cd -P -- "$(dirname -- "${source}")" && pwd)"
    source="$(readlink -- "${source}")"
    [[ "${source}" != /* ]] && source="${dir}/${source}"
  done

  (CDPATH='' cd -P -- "$(dirname -- "${source}")/.." && pwd)
}

_ansible_require_uv() {
  command -v uv >/dev/null 2>&1 || {
    printf '%s\n' "[ERROR] Required command not found: uv" >&2
    printf '%s\n' "Install uv: https://docs.astral.sh/uv/getting-started/installation/" >&2
    exit 127
  }
}

ansible_shim_exec() {
  if [ "$#" -lt 1 ]; then
    printf '%s\n' "[ERROR] Missing ansible subcommand" >&2
    printf '%s\n' "Usage: $(basename "${BASH_SOURCE[1]:-ansible}") <command> [args]" >&2
    exit 2
  fi

  local cmd="$1"
  shift

  _ansible_require_uv

  local root
  root="$(_ansible_shim_root)"

  if [[ ! -f "${root}/ansible.cfg" ]]; then
    printf '%s\n' "[WARNING] ansible.cfg not found in ${root}" >&2
  fi

  export ANSIBLE_CONFIG="${root}/ansible.cfg"

  exec uv run \
    --project "${root}" \
    ${UV_PROJECT_ENVIRONMENT:+--env "$UV_PROJECT_ENVIRONMENT"} \
    --locked \
    "${cmd}" "$@"
}

# vim: ft=sh ts=2 sts=2 sw=2 sr et

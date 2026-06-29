#!/usr/bin/env bash
set -euo pipefail

input="${1:-}"
[[ -f "${input}" ]] || { echo "Vault raft fixture input not found: ${input}" >&2; exit 66; }
wc -c < "${input}" >/dev/null

#!/usr/bin/env bash
set -euo pipefail

input="${1:-}"
[[ -f "${input}" ]] || { echo "HTTP API import fixture input not found: ${input}" >&2; exit 66; }
python3 -m json.tool "${input}" >/dev/null

#!/bin/bash

set -euo pipefail

LOCAL_BIN="${HOME}/.local/bin"
export PATH="${LOCAL_BIN}:${PATH}"

if ! command -v task &> /dev/null; then
  mkdir -p "$LOCAL_BIN"
  sh -c "$(curl -fsSL https://taskfile.dev/install.sh)" -- -b "$LOCAL_BIN"
fi

cd "$(dirname "${BASH_SOURCE[0]}")"

if [ $# -gt 0 ]; then
  exec task "$@"
fi

task --list

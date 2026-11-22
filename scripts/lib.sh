#!/bin/bash

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
RESOURCES="${RESOURCES:-${DOTFILES_DIR}/resources}"
SCRIPTS="${SCRIPTS:-${DOTFILES_DIR}/scripts}"
LOCAL_BIN="${HOME}/.local/bin"

export DEBIAN_FRONTEND=noninteractive

warn() {
  printf '\033[1;33m!!\033[0m %s\n' "$*" >&2
}

has() {
  command -v "$1" &> /dev/null
}

read_list() {
  [ -f "$1" ] || return 0
  grep -vE '^\s*(#|$)' "$1" || true
}

git_clone() {
  local repo="$1" dest="$2"

  [ -d "$dest/.git" ] || git clone --depth 1 --quiet "$repo" "$dest"
}

run_main() {
  if [ $# -eq 0 ]; then
    warn "Usage: $0 <function>"
    exit 1
  fi
  "$@"
}

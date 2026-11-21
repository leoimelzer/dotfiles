#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

apt_install() {
  apt_install_packages
}

apt_install_packages() {
  local packages

  mapfile -t packages < <(read_list "${RESOURCES}/packages/apt/packages.list")

  [ ${#packages[@]} -eq 0 ] && return 0

  sudo apt-get update -y
  sudo apt-get install -y "${packages[@]}"
}

run_main "$@"

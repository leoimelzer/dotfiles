#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

ZYPPER=(sudo zypper --non-interactive --gpg-auto-import-keys)

zypper_install() {
  zypper_install_packages
  zypper_install_packman
  zypper_install_rpm
}

zypper_install_packages() {
  local packages

  mapfile -t packages < <(read_list "${RESOURCES}/packages/zypper/packages.list")

  [ ${#packages[@]} -eq 0 ] && return 0

  "${ZYPPER[@]}" install "${packages[@]}"
}

zypper_add_repo() {
  local url="$1" alias="$2"

  if ! zypper lr "$alias" &> /dev/null; then
    "${ZYPPER[@]}" addrepo -cfp 90 "$url" "$alias"
  fi
}

zypper_install_packman() {
  local packages

  mapfile -t packages < <(read_list "${RESOURCES}/packages/packman/packages.list")

  [ ${#packages[@]} -eq 0 ] && return 0

  read_list "${RESOURCES}/packages/packman/sources.list" | while read -r url alias; do
    zypper_add_repo "$url" "$alias"
  done

  "${ZYPPER[@]}" refresh
  "${ZYPPER[@]}" dist-upgrade --from packman --allow-vendor-change
  "${ZYPPER[@]}" install --from packman "${packages[@]}"
}

zypper_install_rpm() {
  local packages

  mapfile -t packages < <(read_list "${RESOURCES}/packages/rpm/packages.list")

  [ ${#packages[@]} -eq 0 ] && return 0

  read_list "${RESOURCES}/packages/rpm/sources.list" | while read -r key; do
    sudo rpm --import "$key"
  done

  read_list "${RESOURCES}/packages/rpm/keys.list" | while read -r name content; do
    echo -e "$content" | sudo tee "/etc/zypp/repos.d/${name}.repo" > /dev/null
  done

  "${ZYPPER[@]}" refresh
  "${ZYPPER[@]}" install "${packages[@]}"
}

run_main "$@"

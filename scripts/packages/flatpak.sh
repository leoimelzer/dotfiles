#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

flatpak_setup() {
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

  sudo flatpak override --filesystem="$HOME/.themes"
  sudo flatpak override --filesystem="$HOME/.icons"
}

flatpak_install() {
  flatpak_install_packages
  flatpak_override_packages
}

flatpak_override_packages() {
  read_list "${RESOURCES}/packages/flatpak/overrides.list" | while read -r app args; do
    read -ra args <<< "$args"
    flatpak override --user "${args[@]}" "$app"
  done
}

flatpak_install_packages() {
  local packages

  mapfile -t packages < <(read_list "${RESOURCES}/packages/flatpak/packages.list")

  [ ${#packages[@]} -eq 0 ] && return 0

  sudo flatpak install --noninteractive --or-update -y flathub "${packages[@]}"
}

run_main "$@"

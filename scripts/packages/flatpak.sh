#!/bin/bash

flatpak_setup() {
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  sudo flatpak override --filesystem=$HOME/.themes
  sudo flatpak override --filesystem=$HOME/.icons
}

flatpak_install() {
  install_packages
}

install_packages() {
  grep -vE '^\s*(#|$)' ${RESOURCES}/packages/flatpak/packages.list | xargs sudo flatpak install flathub -y
}

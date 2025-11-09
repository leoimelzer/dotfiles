#!/bin/bash

apt_install() {
  install_packages
}

install_packages() {
  grep -vE '^\s*(#|$)' ${RESOURCES}/packages/apt/packages.list | xargs sudo apt install -y
}

#!/bin/bash

zypper_install() {
  install_packages
  install_packages_from_source
}

install_packages() {
  grep -vE '^\s*(#|$)' ${RESOURCES}/packages/zypper/packages.list | xargs sudo zypper install -y
}

install_packages_from_source() {
  # --- packman --- #

  grep -vE '^\s*(#|$)' ${RESOURCES}/packages/packman/sources.list | xargs sudo zypper ar -cfp 90
  sudo zypper refresh
  sudo zypper dup --from packman --allow-vendor-change
  grep -vE '^\s*(#|$)' ${RESOURCES}/packages/packman/packages.list | xargs sudo zypper install -y --from packman

  # --- rpm --- #

  grep -vE '^\s*(#|$)' ${RESOURCES}/packages/rpm/sources.list | xargs sudo rpm --import

  grep -vE '^\s*(#|$)' "${RESOURCES}/packages/rpm/keys.list" | \
  while read -r PACKAGE KEY; do
    echo -e "${KEY}" | sudo tee "/etc/zypp/repos.d/${PACKAGE}.repo" > /dev/null
  done

  grep -vE '^\s*(#|$)' ${RESOURCES}/packages/rpm/packages.list | xargs sudo zypper install -y
}

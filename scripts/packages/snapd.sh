#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

snapd_remove() {
  if has snap; then
    local snaps
    while mapfile -t snaps < <(snap list 2> /dev/null | tail -n +2 | awk '{print $1}') && [ ${#snaps[@]} -gt 0 ]; do
      for snap in "${snaps[@]}"; do
        sudo snap remove --purge "$snap" || true
      done
    done

    sudo systemctl stop snapd || true
    sudo systemctl disable snapd || true
    sudo systemctl mask snapd || true
    sudo apt-get purge -y snapd
  fi

  sudo rm -rf /snap /var/lib/snapd
  for userpath in /home/*; do
    sudo rm -rf "$userpath/snap"
  done

	cat <<-EOF | sudo tee /etc/apt/preferences.d/nosnap.pref > /dev/null
	Package: snapd
	Pin: release a=*
	Pin-Priority: -10
	EOF
}

run_main "$@"

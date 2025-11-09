#!/bin/bash

snapd_remove() {
  while [ "$(snap list | wc -l)" -gt 0 ]; do
    for snap in $(snap list | tail -n +2 | cut -d ' ' -f 1); do
      snap remove --purge "$snap"
    done
  done

  systemctl stop snapd
  systemctl disable snapd
  systemctl mask snapd
  apt purge snapd -y
  rm -rf /snap /var/lib/snapd

  for userpath in /home/*; do
    rm -rf $userpath/snap
  done

	cat <<-EOF | tee /etc/apt/preferences.d/nosnap.pref
	Package: snapd
	Pin: release a=*
	Pin-Priority: -10
	EOF
}

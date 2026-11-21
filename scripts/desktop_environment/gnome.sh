#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

gnome_install() {
  gnome_install_extensions
  gnome_update_theme
}

EXTENSIONS_DCONF_PATH="/org/gnome/shell/extensions"
EXTENSIONS_SETTINGS_DIR="${RESOURCES}/desktop_environment/gnome/extensions"

gnome_setup() {
  gnome_update_settings
  gnome_load_extensions_settings
  gnome_setup_gdm_monitors
}

gnome_load_extensions_settings() {
  local file

  for file in "${EXTENSIONS_SETTINGS_DIR}"/*.ini; do
    [ -e "$file" ] || continue
    dconf load "${EXTENSIONS_DCONF_PATH}/$(basename "$file" .ini)/" < "$file"
  done
}

gnome_dump_extensions_settings() {
  local name

  mkdir -p "$EXTENSIONS_SETTINGS_DIR"

  dconf list "${EXTENSIONS_DCONF_PATH}/" | grep '/$' | while read -r name; do
    name="${name%/}"
    dconf dump "${EXTENSIONS_DCONF_PATH}/${name}/" > "${EXTENSIONS_SETTINGS_DIR}/${name}.ini"
  done
}

gnome_install_extensions() {
  local shell_version installed tmp

  shell_version="$(gnome-shell --version | awk '{print $3}' | cut -d. -f1)"
  installed="$(gnome-extensions list)"
  tmp="$(mktemp -d)"

  read_list "${RESOURCES}/desktop_environment/gnome/extensions.list" | while read -r uuid; do
    if ! grep -qxF "$uuid" <<< "$installed"; then
      local url
      url="$(curl -fsSL "https://extensions.gnome.org/extension-info/?uuid=${uuid}&shell_version=${shell_version}" | jq -r '.download_url // empty')" || true
      if [ -z "$url" ]; then
        warn "No release of $uuid for GNOME Shell ${shell_version}"
        continue
      fi
      curl -fsSL "https://extensions.gnome.org${url}" -o "$tmp/ext.zip"
      gnome-extensions install --force "$tmp/ext.zip"
    fi

    gnome-extensions enable "$uuid" 2> /dev/null \
      || warn "$uuid will be enabled after you log out/in and run this task again"
  done

  rm -rf "$tmp"
}

gnome_update_theme() {
  echo "Skipping theme update, manually install 'GTK_THEME', 'ICON_THEME' and 'CURSOR_THEME' and run source script."

  # GTK_THEME='Colloid-Dark-Gruvbox'
  # ICON_THEME='Gruvbox-Plus-Dark'
  # CURSOR_THEME='Simp1e-Gruvbox-Dark'
  # gsettings set org.gnome.desktop.interface gtk-theme $GTK_THEME
  # gsettings set org.gnome.desktop.wm.preferences theme $GTK_THEME
  # gsettings set org.gnome.desktop.interface icon-theme $ICON_THEME
  # gsettings set org.gnome.desktop.interface cursor-theme $CURSOR_THEME
  # dconf write /org/gnome/shell/extensions/user-theme/name "'$GTK_THEME'"
  # rm -rf ~/.config/gtk-4.0 && ln -s ~/.themes/$GTK_THEME/gtk-4.0 ~/.config/gtk-4.0
  # sudo flatpak override --env=GTK_THEME=$GTK_THEME
  # sudo flatpak override --env=ICON_THEME=$ICON_THEME
}

gnome_setup_gdm_monitors() {
  echo "Skipping monitors setup, manually setup multiple monitors and run source script."

  # if [ ! -d ~gdm/.config ]; then
  #   mkdir ~gdm/.config
  # fi

  # sudo ln -sf ~/.config/monitors.xml ~gdm/.config/monitors.xml
  # chown $(id -u gdm):$(id -g gdm) ~/.config/monitors.xml
  # sudo chmod 644 ~/.config/monitors.xml
}

gnome_update_settings() {
  read_list "${RESOURCES}/desktop_environment/gnome/sets.list" | while read -r schema key value; do
    gsettings set "$schema" "$key" "$value"
  done
}

run_main "$@"

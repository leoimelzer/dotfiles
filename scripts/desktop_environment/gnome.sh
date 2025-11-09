#!/bin/bash

gnome_install() {
  gnome_install_extensions
  gnome_update_theme
}

gnome_setup() {
  gnome_update_settings
  gnome_setup_gdm_monitors
}

gnome_install_extensions() {
  EXT_LIST="${RESOURCES}/desktop_environment/gnome/extensions.list"

  cat $EXT_LIST | while read i || [[ -n $i ]]; do
    busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s ${i} &> /dev/null || true
  done
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
  SET_LIST="${RESOURCES}/desktop_environment/gnome/sets.list"

  while read set; do
    cmd="gsettings set $set"
    $cmd
  done < ${SET_LIST}
}

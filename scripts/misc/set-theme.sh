#!/usr/bin/env bash
# Applies a theme from ~/.themes to GTK3, GTK4/libadwaita, GNOME Shell and window decorations.

set -euo pipefail

THEMES_DIR="$HOME/.themes"
GTK4_DIR="$HOME/.config/gtk-4.0"

list_themes() {
  echo "Temas disponíveis:"
  for d in "$THEMES_DIR"/*/; do
    [[ -f "$d/index.theme" ]] || continue
    name="$(basename "$d")"
    [[ "$name" == *-hdpi || "$name" == *-xhdpi ]] && continue
    echo "  $name"
  done
}

if [[ $# -ne 1 ]]; then
  echo "Uso: $(basename "$0") <nome-do-tema>"
  list_themes
  exit 1
fi

THEME="$1"
SRC="$THEMES_DIR/$THEME"

if [[ ! -f "$SRC/index.theme" ]]; then
  echo "Tema não encontrado: $THEME" >&2
  list_themes >&2
  exit 1
fi

gsettings set org.gnome.desktop.interface gtk-theme "$THEME"
gsettings set org.gnome.desktop.wm.preferences theme "$THEME"

# Requires the User Themes extension.
if [[ -d "$SRC/gnome-shell" ]]; then
  dconf write /org/gnome/shell/extensions/user-theme/name "'$THEME'"
fi

# libadwaita ignores gtk-theme and reads ~/.config/gtk-4.0 instead. Link only these
# files so the directory itself (and settings.ini) is kept.
if [[ -d "$SRC/gtk-4.0" ]]; then
  mkdir -p "$GTK4_DIR"
  for f in assets gtk.css gtk-dark.css; do
    if [[ -e "$SRC/gtk-4.0/$f" ]]; then
      rm -rf "${GTK4_DIR:?}/$f"
      ln -s "$SRC/gtk-4.0/$f" "$GTK4_DIR/$f"
    fi
  done
fi

echo "Tema aplicado: $THEME"
echo "Reabra os apps GTK4/libadwaita para ver a mudança (ex.: nautilus -q)."

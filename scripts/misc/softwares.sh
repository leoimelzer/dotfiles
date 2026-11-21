#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

softwares_install() {
  oh_my_zsh_install
  fnm_install
  sdkman_install
  taskfile_install
  vscode_install
}

softwares_config() {
  zsh_config
  ghostty_config
  fd_config
  dotfiles_config
  tmux_config
  vscode_config
}

git_clone() {
  local repo="$1" dest="$2"

  [ -d "$dest/.git" ] || git clone --depth 1 --quiet "$repo" "$dest"
}

oh_my_zsh_install() {
  local omz_dir="${HOME}/.oh-my-zsh"
  local zsh_custom="${ZSH_CUSTOM:-${omz_dir}/custom}"

  if [ ! -f "${omz_dir}/oh-my-zsh.sh" ]; then
    [ -L "$omz_dir" ] && rm "$omz_dir"

    KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  git_clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${zsh_custom}/plugins/zsh-syntax-highlighting"
  git_clone https://github.com/zsh-users/zsh-autosuggestions.git "${zsh_custom}/plugins/zsh-autosuggestions"
}

fnm_install() {
  [ -x "${XDG_DATA_HOME:-$HOME/.local/share}/fnm/fnm" ] || has fnm && return

  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
}

sdkman_install() {
  [ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ] && return

  curl -fsSL "https://get.sdkman.io?rcupdate=false" | bash
}

taskfile_install() {
  has task && return

  sh -c "$(curl -fsSL https://taskfile.dev/install.sh)" -- -b "$LOCAL_BIN"
}

vscode_install() {
  has code && return

  if has zypper; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo tee /etc/zypp/repos.d/vscode.repo > /dev/null <<-'EOF'
		[code]
		name=Visual Studio Code
		baseurl=https://packages.microsoft.com/yumrepos/vscode
		enabled=1
		autorefresh=1
		type=rpm-md
		gpgcheck=1
		gpgkey=https://packages.microsoft.com/keys/microsoft.asc
		EOF
    sudo zypper --non-interactive --gpg-auto-import-keys refresh code
    sudo zypper --non-interactive install code
  elif has apt-get; then
    sudo apt-get install -y wget gpg apt-transport-https
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
      | gpg --dearmor \
      | sudo install -D -o root -g root -m 644 /dev/stdin /usr/share/keyrings/microsoft.gpg
    sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null <<-'EOF'
		Types: deb
		URIs: https://packages.microsoft.com/repos/code
		Suites: stable
		Components: main
		Architectures: amd64,arm64,armhf
		Signed-By: /usr/share/keyrings/microsoft.gpg
		EOF
    echo "code code/add-microsoft-repo boolean false" | sudo debconf-set-selections
    sudo apt-get update -y
    sudo apt-get install -y code
  else
    warn "No supported package manager found to install vscode"
    return 1
  fi
}

zsh_config() {
  local zsh_bin current
  zsh_bin="$(command -v zsh)" || { warn "zsh is not installed"; return 1; }
  current="$(getent passwd "$USER" | cut -d: -f7)"

  if [ "$current" != "$zsh_bin" ]; then
    sudo usermod --shell "$zsh_bin" "$USER"
  fi
}

ghostty_config() {
  local ghostty_bin

  mkdir -p "${HOME}/workspace"

  ghostty_bin="$(command -v ghostty)" || return 0
  PATH="${PATH}:/usr/sbin" has update-alternatives || return 0

  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$ghostty_bin" 50
  sudo update-alternatives --set x-terminal-emulator "$ghostty_bin"
}

fd_config() {
  has fd && return

  if has fdfind; then
    mkdir -p "$LOCAL_BIN"
    ln -sfn "$(command -v fdfind)" "$LOCAL_BIN/fd"
  fi
}

dotfiles_config() {
  oh_my_zsh_install

  local stow=(stow --dir "$DOTFILES_DIR" --target "$HOME")
  local backup_dir="${HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
  local conflicts

  cd "$DOTFILES_DIR"

  mapfile -t conflicts < <(
    "${stow[@]}" --no --restow . 2>&1 \
      | sed -nE 's/.* over existing target (.+) since .*/\1/p; s/.*existing target is [^:]+: (.+)$/\1/p' \
      | sort -u
  )

  for target in "${conflicts[@]}"; do
    [ -z "$target" ] && continue
    mkdir -p "${backup_dir}/$(dirname "$target")"
    mv "${HOME}/${target}" "${backup_dir}/${target}"
  done

  "${stow[@]}" --restow .
}

tmux_config() {
  local plugins_dir="${HOME}/.tmux/plugins"
  local theme_src="${RESOURCES}/misc/softwares/tmux/plugins/tokyo-night-tmux"
  local theme_dst="${plugins_dir}/tokyo-night-tmux"

  git_clone https://github.com/tmux-plugins/tpm "${plugins_dir}/tpm"

  "${plugins_dir}/tpm/bin/install_plugins" > /dev/null

  cp "${theme_src}/tokyo-night.tmux" "${theme_dst}/tokyo-night.tmux"
  cp "${theme_src}/src/git-status.sh" "${theme_dst}/src/git-status.sh"

  if tmux info &> /dev/null; then
    tmux source-file "${HOME}/.tmux.conf"
  fi
}

vscode_config() {
  if ! has code; then
    warn "vscode is not installed, run 'task softwares:install' first"
    return 1
  fi

  local installed
  installed="$(code --list-extensions | tr '[:upper:]' '[:lower:]')"

  read_list "${RESOURCES}/misc/softwares/vscode/extensions.list" | while read -r ext; do
    if ! grep -qxF "${ext,,}" <<< "$installed"; then
      code --install-extension "$ext" --force
    fi
  done
}

run_main "$@"

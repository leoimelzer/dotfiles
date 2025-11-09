#!/bin/bash

softwares_install() {
  oh_my_zsh_install
  sdkman_install
}

softwares_config() {
  alacritty_config
  fd_config
  dotfiles_config
  tmux_config
  vscode_config
}

oh_my_zsh_install() {
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/
  git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions/
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

sdkman_install() {
  curl -s "https://get.sdkman.io" | bash
}

dotfiles_config() {
  mv ~/.bashrc ~/.bashrc-backup
  cd ~/dotfiles
  stow .
}

vscode_config() {
  for x in $(grep -vE "^\s*#" ${RESOURCES}/misc/softwares/vscode/extensions.list  | tr "\n" " "); do
    code --install-extension $x
  done
}

alacritty_config() {
  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 50
  sudo update-alternatives --config x-terminal-emulator
}

fd_config() {
  FD_LOCAL_BIN=~/.local/bin

  mkdir -p $FD_LOCAL_BIN

  FD_BIN=$(command -v fd || command -v fdfind)

  if [ -n "$FD_BIN" ]; then
    [ ! -e $FD_LOCAL_BIN/fd ] && ln -s "$FD_BIN" $FD_LOCAL_BIN/fd
  fi
}

tmux_config() {
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  RESOURCES_TMUX_PATH=${RESOURCES}/misc/softwares/tmux/plugins/tokyo-night-tmux
  LOCAL_TMUX_PATH=~/.tmux/plugins/tokyo-night-tmux

  cp -r $LOCAL_TMUX_PATH/src/git-status.sh ${RESOURCES}_TMUX_PATH/src/git-status.sh && cp -r $LOCAL_TMUX_PATH/tokyo-night.tmux ${RESOURCES}_TMUX_PATH/tokyo-night.tmux

  echo "Run `tmux`, followed by `tmux source ~/.tmux.conf/` then followed by pressing `Ctrl + B + I` manually to apply tmux changes."
}

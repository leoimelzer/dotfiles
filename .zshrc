export ZSH="$HOME/.oh-my-zsh"

plugins=(
  git
  command-not-found
  zsh-syntax-highlighting
  zsh-autosuggestions
  direnv
)

#--------------------------------------------------------------------------------------#

ZSH_THEME="essembeh"

source $ZSH/oh-my-zsh.sh

#--------------------------------------------------------------------------------------#

# alias ls="lsd"
# alias cat="bat"
alias clipboard="xclip -selection CLIPBOARD"

export TERM=xterm-256color

export PATH=$PATH:~/.local/bin

export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME
export ANDROID_AVD_HOME=$HOME/.config/.android/avd
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools

export DIRENV_LOG_FORMAT=''

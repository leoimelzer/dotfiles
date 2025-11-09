export ZSH="$HOME/.oh-my-zsh"

plugins=(
  git
  command-not-found
  zsh-syntax-highlighting
  zsh-autosuggestions
)

#--------------------------------------------------------------------------------------#

ZSH_THEME="custom"

# --- DEFAULTS --- #

# SHOW_TIMESTAMP=true
# SHOW_USER=true
# SHOW_HOSTNAME=true
# SHOW_GIT=true
# SHOW_DIRECTORY=true

# TIMESTAMP_COLOUR="white"
# USER_COLOUR="blue"
# HOSTNAME_COLOUR="green"
# DIRECTORY_COLOUR="cyan"
# GIT_COLOUR="magenta"

# TIMESTAMP_BOLD=true
# USER_BOLD=true
# HOSTNAME_BOLD=true
# DIRECTORY_BOLD=true
# GIT_BOLD=true
# PROMPT_BOLD=true

# --- CUSTOM --- #

SHOW_TIMESTAMP=false
SHOW_USER=false
SHOW_HOSTNAME=false

[ "$TERM_PROGRAM" = "tmux" ] && SHOW_GIT=false

source $ZSH/oh-my-zsh.sh

#--------------------------------------------------------------------------------------#

# alias ls="lsd"
# alias cat="bat"
alias ssh="TERM=xterm ssh"
alias clipboard="xclip -selection CLIPBOARD"

export TERM=xterm-256color

export PATH=$PATH:~/.local/bin

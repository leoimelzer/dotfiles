TIMESTAMP_COLOUR="${TIMESTAMP_COLOUR:=white}"
USER_COLOUR="${USER_COLOUR:=blue}"
HOSTNAME_COLOUR="${HOSTNAME_COLOUR:=green}"
DIRECTORY_COLOUR="${DIRECTORY_COLOUR:=cyan}"
GIT_COLOUR="${GIT_COLOUR:=magenta}"

SHOW_TIMESTAMP="${SHOW_TIMESTAMP:=true}"
SHOW_USER="${SHOW_USER:=true}"
SHOW_HOSTNAME="${SHOW_HOSTNAME:=true}"
SHOW_DIRECTORY="${SHOW_DIRECTORY:=true}"
SHOW_GIT="${SHOW_GIT:=true}"

TIMESTAMP_BOLD="${TIMESTAMP_BOLD:=true}"
USER_BOLD="${USER_BOLD:=true}"
HOSTNAME_BOLD="${HOSTNAME_BOLD:=true}"
DIRECTORY_BOLD="${DIRECTORY_BOLD:=true}"
GIT_BOLD="${GIT_BOLD:=true}"
PROMPT_BOLD="${PROMPT_BOLD:=true}"

TIMESTAMP_FORMAT="${TIMESTAMP_FORMAT:=%H:%M}"
CUSTOM_PROMPT="${CUSTOM_PROMPT:=»}"

ZSH_THEME_GIT_PROMPT_UNTRACKED="${ZSH_THEME_GIT_PROMPT_UNTRACKED:-?}"
ZSH_THEME_GIT_PROMPT_ADDED="${ZSH_THEME_GIT_PROMPT_ADDED:-+}"
ZSH_THEME_GIT_PROMPT_MODIFIED="${ZSH_THEME_GIT_PROMPT_MODIFIED:-!}"
ZSH_THEME_GIT_PROMPT_RENAMED="${ZSH_THEME_GIT_PROMPT_RENAMED:-!}"
ZSH_THEME_GIT_PROMPT_DELETED="${ZSH_THEME_GIT_PROMPT_DELETED:-!}"
ZSH_THEME_GIT_PROMPT_STASHED="${ZSH_THEME_GIT_PROMPT_STASHED:-*}"
ZSH_THEME_GIT_PROMPT_UNMERGED="${ZSH_THEME_GIT_PROMPT_UNMERGED:-M}"
ZSH_THEME_GIT_PROMPT_AHEAD="${ZSH_THEME_GIT_PROMPT_AHEAD:-↑}"
ZSH_THEME_GIT_PROMPT_BEHIND="${ZSH_THEME_GIT_PROMPT_BEHIND:-↓}"
ZSH_THEME_GIT_PROMPT_DIVERGED="${ZSH_THEME_GIT_PROMPT_DIVERGED:--~}"

decorate () {
  [ $3 = true ] && echo -n "$(tput bold)"

  echo -n "%{$fg[$2]%}$1"
  echo -n "%{$reset_color%}"
}

collapsedDirectory() {
  local pwd=("${(s:/:)PWD/#$HOME/~}")

  for ((i = 1; i < $#pwd; i++)); do
    [[ "${pwd[$i]}" == .* ]] && pwd[$i]=${${(k)"${pwd[$i]}"}[1,2]} || pwd[$i]=${${(k)"${pwd[$i]}"}[1]}
  done

  decorate "${(j:/:)pwd}" "${DIRECTORY_COLOUR}" "${DIRECTORY_BOLD}"
}

gitStatus() {
  GIT_CURRENT_BRANCH=$(git_current_branch | xargs echo -n)
  GIT_PROMPT_STATUS=$(_omz_git_prompt_status | sed -E 's/!+/!/g' | xargs echo -n)

  if [ -n "$GIT_CURRENT_BRANCH" ]; then
    echo -n " at $(decorate " ${GIT_CURRENT_BRANCH}${GIT_PROMPT_STATUS:+[$GIT_PROMPT_STATUS]}" "${GIT_COLOUR}" "${GIT_BOLD}")"
  fi
}

precmd() {
  prev_exit_code=$?
}

inputPrompt() {
  echo ""
  if [ $prev_exit_code -eq 0 ]; then
    [ "$PROMPT_BOLD" = true ] && echo -n "%{$fg_bold[green]%}" || echo -n "%{$fg[green]%}"
  else
    [ "$PROMPT_BOLD" = true ] && echo -n "%{$fg_bold[red]%}" || echo -n "%{$fg[red]%}"
  fi
  
  echo -n "${CUSTOM_PROMPT}%{$reset_color%} "
}

rightPrompt() {
  if [ $prev_exit_code -ne 0 ]; then
    [ "$PROMPT_BOLD" = true ] && echo -n "%{$fg_bold[red]%}" || echo -n "%{$fg[red]%}"
    
    echo -n " ↵ $prev_exit_code%{$reset_color%}"
  fi
}

PROMPT='$(echo "\n  ")'

[ $SHOW_TIMESTAMP = true ] && PROMPT+='$(decorate "%D{"${TIMESTAMP_FORMAT}"}" "${TIMESTAMP_COLOUR}" "${TIMESTAMP_BOLD}" && echo -n " ")'
[ $SHOW_USER = true ] && PROMPT+='$(decorate "%n" "${USER_COLOUR}" "${USER_BOLD}")'
[[ $SHOW_USER = true && $SHOW_HOSTNAME = true ]] && PROMPT+='$(echo -n "@")'
[ $SHOW_HOSTNAME = true ] && PROMPT+='$(decorate "%m" "${HOSTNAME_COLOUR}" "${HOSTNAME_BOLD}")'
[ $SHOW_USER = true ] || $SHOW_HOSTNAME && PROMPT+='$(echo -n ":")'
[ $SHOW_DIRECTORY = true ] && PROMPT+='$(collapsedDirectory)'
[ $SHOW_GIT = true ] && PROMPT+='$(gitStatus)'

PROMPT+='$(inputPrompt)'
RPROMPT='$(rightPrompt)'

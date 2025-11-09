#!/usr/bin/env bash

cd $1

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
STATUS=$(git status --porcelain -b 2>/dev/null | grep -v "$BRANCH")
HAS_CHANGES=$(( $(echo "$STATUS" | egrep "^(M| D| ??)" | wc -l) > 0 ))

checkStatusResume() {
  local status_representation="$1"
  local status_resume="$2"

  if echo "$STATUS" | grep -q "$status_representation"; then
    case "$RESUME" in
      *"$status_resume"*) ;;
      *) RESUME="${RESUME}${status_resume}" ;;
    esac
  fi
}

if [ "$HAS_CHANGES" -eq 1 ]; then
  DIFF=$(git diff --shortstat 2>/dev/null | tr "," "\n")

  CHANG_COUNT=$(echo "$DIFF" | grep "chang" | cut -d" " -f2 | bc)
  INS_COUNT=$(( $(echo "$DIFF" | grep "ins" | cut -d" " -f2 | bc) + $(git ls-files -o --exclude-standard | xargs cat | wc -l) ))
  DEL_COUNT=$(echo "$DIFF" | grep "del" | cut -d" " -f2 | bc)
  UNTR_COUNT=$(git ls-files --other --exclude-standard | wc -l | bc)

  [ $INS_COUNT -gt 0 ] && DETAILS+="#[fg=green,bg=default,bold]  $INS_COUNT"
  [ $DEL_COUNT -gt 0 ] && DETAILS+="#[fg=red,bg=default,bold]  $DEL_COUNT"
  [ $CHANG_COUNT -gt 0 ] && DETAILS+="#[fg=yellow,bg=default,bold]  $CHANG_COUNT"
  [ $UNTR_COUNT -gt 0 ] && DETAILS+="#[fg=black,bg=default,bold]  $UNTR_COUNT"
  DETAILS+=' '

  checkStatusResume "ahead" "↑"
  checkStatusResume "behind" "↓"
  checkStatusResume "diverged " "-~"
  [ -n "$(git rev-parse --verify refs/stash)" ] && RESUME="${RESUME}*"
  checkStatusResume "^ M" "!"
  checkStatusResume "^R " "!"
  checkStatusResume "^D " "!"
  checkStatusResume "^ D" "!"
  checkStatusResume "^ U" "!"
  checkStatusResume "^A " "+"
  checkStatusResume "^M " "+"
  checkStatusResume "^R " "+"
  checkStatusResume "^?? " "?"
fi

if [ -n "$BRANCH" ]; then
  BRANCH="#[fg=magenta,bg=default,bold]  $BRANCH"
  [ $RESUME ] && RESUME="[$RESUME]"

  echo "$BRANCH$RESUME$DETAILS"
fi

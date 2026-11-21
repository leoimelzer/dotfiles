#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

snapper_setup() {
  has snapper || return 0

  sudo snapper -c root set-config \
    NUMBER_LIMIT=2-6 \
    NUMBER_LIMIT_IMPORTANT=2-4 \
    SPACE_LIMIT=0.2 \
    FREE_LIMIT=0.2 \
    TIMELINE_CREATE=no \
    TIMELINE_LIMIT_HOURLY=0 \
    TIMELINE_LIMIT_DAILY=3 \
    TIMELINE_LIMIT_WEEKLY=1 \
    TIMELINE_LIMIT_MONTHLY=0 \
    TIMELINE_LIMIT_QUARTERLY=0 \
    TIMELINE_LIMIT_YEARLY=0

  sudo systemctl enable --now snapper-cleanup.timer
}

run_main "$@"

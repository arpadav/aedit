#!/usr/bin/env bash
#
# Launched in the left zellij pane.
# Reads AEDIT_FOLDER exported by `ae` before zellij started.
#
# Author: aav
# --------------------------------------------------
if [[ -f "${HOME}/.config/broot/launcher/bash/br" ]]; then
    source "${HOME}/.config/broot/launcher/bash/br" && br "${AEDIT_FOLDER:-.}"
fi

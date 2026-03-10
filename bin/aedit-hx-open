#!/usr/bin/env bash
#
# Called by broot's edit verb to open a file in the helix pane.
#
# $1 = absolute file path  (broot: {file})
# $2 = line number          (broot: {line}, may be 0 or empty)
#
# Author: aav
# --------------------------------------------------
set -euo pipefail

# --------------------------------------------------
# inputs
# --------------------------------------------------
FILE="${1:?Usage: aedit-hx-open <file> [line]}"
LINE="${2:-}"

# --------------------------------------------------
# not in zellij: open helix directly
# --------------------------------------------------
if [[ -z "${ZELLIJ:-}" ]]; then
    if [[ -n "${LINE}" && "${LINE}" -gt 0 ]] 2>/dev/null; then
        exec hx "+${LINE}" "${FILE}"
    else
        exec hx "${FILE}"
    fi
fi

# --------------------------------------------------
# build the :open argument.
# --------------------------------------------------
# helix supports `file:line` syntax so we skip a
# separate line-jump command
# --------------------------------------------------
if [[ -n "${LINE}" && "${LINE}" -gt 0 ]] 2>/dev/null; then
    OPEN_ARG="${FILE}:${LINE}"
else
    OPEN_ARG="${FILE}"
fi

# --------------------------------------------------
# move focus from the broot pane (left) to the helix pane (right)
# --------------------------------------------------
zellij action move-focus right

# --------------------------------------------------
# escape to ensure helix is in normal mode before
# sending a command
# --------------------------------------------------
zellij action write 27

# --------------------------------------------------
# type the :open command and submit
# --------------------------------------------------
zellij action write-chars ":open ${OPEN_ARG}"
zellij action write 13

#!/usr/bin/env bash
#
# Launched in the right zellij pane.
# Reads AEDIT_FILE and AEDIT_FOLDER exported by `ae` before zellij started.
#
# Author: aav
# --------------------------------------------------
cd "${AEDIT_FOLDER:-.}"

if [[ -n "${AEDIT_FILE:-}" && -f "${AEDIT_FILE}" ]]; then
    exec hx "${AEDIT_FILE}"
else
    exec hx
fi

#!/bin/sh
#
# aedit headless installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/arpadav/aedit/main/install.sh | sh
#
# Author: aav
# --------------------------------------------------
set -eu

# --------------------------------------------------
# install nix if not present
# --------------------------------------------------
if ! command -v nix >/dev/null 2>&1; then
    curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# --------------------------------------------------
# apply aedit via home-manager
# --------------------------------------------------
nix run home-manager/master -- switch \
    --flake "github:arpadav/aedit?dir=headless#headless" \
    --impure \
    --extra-experimental-features "nix-command flakes"

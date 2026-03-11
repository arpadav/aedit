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
NIX_SH="$HOME/.nix-profile/etc/profile.d/nix.sh"
step() {
    printf "  \033[1;34m=>\033[0m %s...\n" "$1"
}
# --------------------------------------------------
# source nix env if it exists but isn't on PATH
# --------------------------------------------------
if ! command -v nix >/dev/null 2>&1; then
    if [ -f "$NIX_SH" ]; then
        . "$NIX_SH"
    fi
fi
# --------------------------------------------------
# if still not found, actuall install
# --------------------------------------------------
if ! command -v nix >/dev/null 2>&1; then
    step "Installing Nix"
    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon --yes >/dev/null
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# --------------------------------------------------
# install aedit
# --------------------------------------------------
step "Installing aedit..."
nix run home-manager/master -- switch \
    --flake "github:arpadav/aedit?ref=preparing-for-release&dir=headless#headless" \
    --impure \
    --no-write-lock-file \
    --extra-experimental-features "nix-command flakes"

# --------------------------------------------------
# apply env
# --------------------------------------------------
step "Appying env..."
source ~/.profile 2>&1
broot --install 2>&1

# --------------------------------------------------
# done! print usage
# --------------------------------------------------
step "Done!"
ae --help

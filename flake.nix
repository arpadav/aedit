{
  description = "aedit (ae) - arpad editor flake";
  # --------------------------------------------------
  # nix packages
  # --------------------------------------------------
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  # --------------------------------------------------
  # use home-manager
  # --------------------------------------------------
  outputs = { nixpkgs, ... }: {
    homeManagerModules.default = import ./module.nix;
  };
}

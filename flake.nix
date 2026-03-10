{
  description = "aedit (ae) - arpad editor flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { nixpkgs, ... }: {
    homeManagerModules.default = import ./module.nix;
  };
}

{
  description = "aedit (ae) - arpad editor headless flake";
  # --------------------------------------------------
  # nix packages
  # --------------------------------------------------
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  # --------------------------------------------------
  # use home-manager
  # --------------------------------------------------
  outputs = { nixpkgs, home-manager, ... }: {
    homeConfigurations.headless = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = builtins.currentSystem; };
      modules = [
        ../module.nix
        {
          home.username = builtins.getEnv "USER";
          home.homeDirectory = builtins.getEnv "HOME";
          home.stateVersion = "25.11";
          programs.aedit.enable = true;
        }
      ];
    };
  };
}

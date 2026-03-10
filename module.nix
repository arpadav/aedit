{ config, pkgs, lib, ... }:

let
  # --------------------------------------------------
  # params
  # --------------------------------------------------
  cfg = config.programs.aedit;
  # --------------------------------------------------
  # open from `broot` into `helix` using `aedit`
  # --------------------------------------------------
  defaultBrootVerbs = [
    {
      invocation = "edit";
      key = "enter";
      apply_to = "file";
      leave_broot = false;
      execution = "aedit-hx-open {file} {line}";
    }
  ];
in

{
  options.programs.aedit = {
    enable = lib.mkEnableOption "aedit editor bundle";
    # --------------------------------------------------
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.helix.enable
    # --------------------------------------------------
    helixCfg = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      default = null;
      description = "Additional `helix` settings";
    };
    # --------------------------------------------------
    # https://docs.helix-editor.com/configuration.html
    # --------------------------------------------------
    helixCfgFile = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      default = null;
      description = "Path to Helix config file";
    };
    # --------------------------------------------------
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.broot.enable
    # --------------------------------------------------
    brootCfg = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Additional `broot` settings";
    };
    # --------------------------------------------------
    # https://dystroy.org/broot/conf_file/
    # --------------------------------------------------
    brootCfgFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [];
      description = "List of `broot` config files to import";
    };
  };

  config = lib.mkIf cfg.enable {
    # --------------------------------------------------
    # assert certain configurations to be mutually exclusive
    # --------------------------------------------------
    assertions = [
      {
        assertion = !(cfg.helixCfg != null && cfg.helixCfgFile != null);
        message = "programs.aedit: helixCfg and helixCfgFile are mutually exclusive.";
      }
    ];
    # --------------------------------------------------
    # add user `helix` config
    # --------------------------------------------------
    programs.helix = {
      enable = true;
      settings = lib.mkIf (cfg.helixCfg != null) cfg.helixCfg;
    };
    # --------------------------------------------------
    # merge users `zellij` config to enable window split
    # --------------------------------------------------
    programs.zellij = {
      enable = true;
    };
    # --------------------------------------------------
    # merge broot verbs to enable opening with `aedit`
    # --------------------------------------------------
    programs.broot = {
      enable = true;
      settings =
      let
        mergedBrootVerbs = defaultBrootVerbs ++ (cfg.brootCfg.verbs or []);
        importBrootCfgFiles = map builtins.baseNameOf cfg.brootCfgFiles;
      in
      (builtins.removeAttrs cfg.brootCfg [ "verbs" ]) // {
        verbs = mergedBrootVerbs;
        imports = importBrootCfgFiles ;
      };
    };
    # # --------------------------------------------------
    # # aedit packages
    # # --------------------------------------------------
    # home.packages = with pkgs; [
    #   broot
    #   helix
    #   zellij
    # ];
  };

  # --------------------------------------------------
  # config files
  # --------------------------------------------------
  xdg.configFile =
    builtins.listToAttrs (map (path: {
      name = "broot/${builtins.baseNameOf path}";
      value = { source = path; };
    }) cfg.brootCfgFiles)

    //

    lib.optionalAttrs (cfg.helixCfgFile != null) {
      "helix/config.toml".source = cfg.helixCfgFile;
    }

    ;

  # # --------------------------------------------------
  # # configs? not aedit, but personal to me arpad
  # # --------------------------------------------------
  # home.file = {
  #   ".bash_functions".source = ./dotfiles/.bash_functions;
  #   ".config/helix/config.toml".source = ./dotfiles/helix-config.toml;
  #   ".config/helix/languages.toml".source = ./dotfiles/helix-languages.toml;
  #   ".config/zellij/config.kdl".source = ./dotfiles/zellij-config.kdl;
  #   ".config/zellij/layouts/aedit.kdl".source = ./dotfiles/zellij-layout.kdl;
  #   ".config/broot/conf.hjson".source = ./dotfiles/broot-conf.hjson;
  #   ".config/broot/verbs.hjson".source = ./dotfiles/broot-verbs.hjson;
  # };
}

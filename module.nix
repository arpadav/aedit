{ config, pkgs, lib, ... }:

let
  # --------------------------------------------------
  # params
  # --------------------------------------------------
  cfg = config.programs.aedit;
  # --------------------------------------------------
  # aedit scripts package
  # --------------------------------------------------
  aeditScripts = pkgs.stdenvNoCC.mkDerivation {
    name = "aedit-scripts";
    src = ./bin;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin
      for f in ae aedit-hx-open.sh aedit-broot-start.sh aedit-hx-start.sh; do
        install -m755 "$f" $out/bin/
      done
    '';
  };
  # --------------------------------------------------
  # open from `broot` into `helix` using `aedit`
  # --------------------------------------------------
  defaultBrootVerbs = [
    {
      invocation = "edit";
      key = "enter";
      apply_to = "file";
      leave_broot = false;
      execution = "aedit-hx-open.sh {file} {line}";
    }
  ];
in

{
  options.programs.aedit = {
    enable = lib.mkEnableOption "aedit editor bundle";
    # --------------------------------------------------
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.helix.settings
    # --------------------------------------------------
    helixCfg = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      default = null;
      description = "Additional `helix` config settings (config.toml)";
    };
    # --------------------------------------------------
    # https://docs.helix-editor.com/configuration.html
    # --------------------------------------------------
    helixCfgFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to Helix config file";
    };
    # --------------------------------------------------
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.helix.languages
    # --------------------------------------------------
    helixLang = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      default = null;
      description = "Additional `helix` language settings (languages.toml)";
    };
    # --------------------------------------------------
    # https://docs.helix-editor.com/languages.html
    # --------------------------------------------------
    helixLangFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to Helix languages file";
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
    # --------------------------------------------------
    # zellij layout
    # --------------------------------------------------
    zellijLayout = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = ./aedit-layout.kdl;
      description = "Path to the zellij layout file for aedit";
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
      {
        assertion = !(cfg.helixLang != null && cfg.helixLangFile != null);
        message = "programs.aedit: helixLang and helixLangFile are mutually exclusive.";
      }
    ];
    # --------------------------------------------------
    # add user `helix` config
    # --------------------------------------------------
    programs.helix = {
      enable = true;
      defaultEditor = true;
      settings = lib.mkIf (cfg.helixCfg != null) cfg.helixCfg;
      languages = lib.mkIf (cfg.helixLang != null) cfg.helixLang;
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
    # --------------------------------------------------
    # aedit scripts on PATH
    # --------------------------------------------------
    home.packages = [ aeditScripts ];
    # --------------------------------------------------
    # config files
    # --------------------------------------------------
    xdg.configFile =
      builtins.listToAttrs (map (path: {
        name = "broot/${builtins.baseNameOf path}";
        value = { source = path; };
      }) cfg.brootCfgFiles)

      //

      lib.optionalAttrs (cfg.zellijLayout != null) {
        "zellij/layouts/aedit.kdl".source = cfg.zellijLayout;
      }

      //

      lib.optionalAttrs (cfg.helixCfgFile != null) {
        "helix/config.toml".source = cfg.helixCfgFile;
      }

      //

      lib.optionalAttrs (cfg.helixLangFile != null) {
        "helix/languages.toml".source = cfg.helixLangFile;
      }

      ;
  };
}

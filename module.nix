{ config, pkgs, lib, ... }:

let
  # --------------------------------------------------
  # params
  # --------------------------------------------------
  cfg = config.programs.aedit;
  # --------------------------------------------------
  # generated zellij layout with configurable pane sizes
  # --------------------------------------------------
  layoutHeader = ''
    // aedit zellij layout
    //
    // WARNING: It is not recommended to replace this layout file directly.
    // The panes use custom commands (aedit-broot-start and aedit-hx-start)
    // that are required for aedit to function. To adjust pane sizes, use the
    // `brootPaneSize` and `helixPaneSize` Nix options instead.
    //
    // Left pane (${toString cfg.brootPaneSize}%): broot file picker
    // Right pane (${toString cfg.helixPaneSize}%): helix editor
    //
    // Author: aav
    // --------------------------------------------------
    show_startup_tips false
    default_layout "compact"
    session_serialization false
  '';
  generatedLayout = pkgs.writeText "aedit-layout.kdl" ''
    ${layoutHeader}
    layout {
        pane size=1 borderless=true {
            plugin location="zellij:tab-bar"
        }
        pane split_direction="vertical" {
            pane size="${toString cfg.brootPaneSize}%" command="aedit-broot-start" name="broot"
            pane size="${toString cfg.helixPaneSize}%" command="aedit-hx-start" name="hx"
        }
    }
  '';
  generatedFileLayout = pkgs.writeText "aedit-file-layout.kdl" ''
    ${layoutHeader}
    layout {
        pane size=1 borderless=true {
            plugin location="zellij:tab-bar"
        }
        pane split_direction="vertical" {
            pane size="${toString cfg.brootPaneSize}%" command="aedit-broot-start" name="broot"
            pane size="${toString cfg.helixPaneSize}%" command="aedit-hx-start" name="hx" focus=true
        }
    }
  '';
  # --------------------------------------------------
  # resolved layout: custom or generated
  # --------------------------------------------------
  resolvedLayout = if cfg.zellijLayout != null then cfg.zellijLayout else generatedLayout;
  resolvedFileLayout = if cfg.zellijLayout != null then cfg.zellijLayout else generatedFileLayout;
  # --------------------------------------------------
  # aedit scripts package
  # --------------------------------------------------
  aeditScripts = pkgs.stdenvNoCC.mkDerivation {
    name = "aedit-scripts";
    src = ./bin;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin
      for f in ae aedit-hx-open aedit-broot-start aedit-hx-start; do
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
      execution = "aedit-hx-open {file} {line}";
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
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zellij.settings
    # --------------------------------------------------
    zellijCfg = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      default = null;
      description = "Additional zellij settings (config.kdl)";
    };
    # --------------------------------------------------
    # https://zellij.dev/documentation/configuration
    # --------------------------------------------------
    zellijCfgFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to zellij config file";
    };
    # --------------------------------------------------
    # zellij layout
    # --------------------------------------------------
    zellijLayout = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a custom zellij layout file for aedit. Not recommended -- the default layout uses custom pane commands (aedit-broot-start, aedit-hx-start) required for aedit to function. Use brootPaneSize and helixPaneSize to adjust the split instead.";
    };
    # --------------------------------------------------
    # pane sizes
    # --------------------------------------------------
    brootPaneSize = lib.mkOption {
      type = lib.types.int;
      default = 20;
      description = "Broot (left) pane width as a percentage";
    };
    helixPaneSize = lib.mkOption {
      type = lib.types.int;
      default = 80;
      description = "Helix (right) pane width as a percentage";
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
      {
        assertion = !(cfg.zellijCfg != null && cfg.zellijCfgFile != null);
        message = "programs.aedit: zellijCfg and zellijCfgFile are mutually exclusive.";
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
      settings = lib.mkIf (cfg.zellijCfg != null) cfg.zellijCfg;
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

      lib.optionalAttrs (cfg.helixCfgFile != null) {
        "helix/config.toml".source = cfg.helixCfgFile;
      }

      //

      lib.optionalAttrs (cfg.helixLangFile != null) {
        "helix/languages.toml".source = cfg.helixLangFile;
      }

      //

      lib.optionalAttrs (cfg.zellijCfgFile != null) {
        "zellij/config.kdl".source = cfg.zellijCfgFile;
      }

      //

      {
        "zellij/layouts/aedit.kdl".source = resolvedLayout;
        "zellij/layouts/aedit-file.kdl".source = resolvedFileLayout;
      }

      ;
  };
}

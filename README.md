# aedit (ae)

A terminal editor bundle that combines [helix](https://helix-editor.com/), [broot](https://dystroy.org/broot/), and [zellij](https://zellij.dev/) into a single workspace.

```
+---------------------+-------------------------------------------+
|                     |                                           |
|   broot (20%)       |          helix (80%)                      |
|   file picker       |          editor                           |
|                     |                                           |
+---------------------+-------------------------------------------+
```

## Installation

Add the flake to your inputs and import the home-manager module:

```nix
# flake.nix
{
  inputs = {
    aedit.url = "github:arpadav/aedit";
  };

  outputs = { aedit, ... }: {
    homeConfigurations."user" = home-manager.lib.homeManagerConfiguration {
      modules = [
        aedit.homeManagerModules.default
        {
          programs.aedit.enable = true;
        }
      ];
    };
  };
}
```

## Usage

```bash
ae              # open current directory
ae .            # same as above
ae ~/projects   # open a directory
ae src/main.rs  # open a specific file
```

Inside the workspace, press `Enter` on a file in broot to open it in helix.

## Configuration

All options live under `programs.aedit`.

### `enable`

Enable the aedit editor bundle.

```nix
programs.aedit.enable = true;
```

---

### Helix

Configure helix using either structured Nix attrs or a config file. These pairs are mutually exclusive -- setting both will produce an assertion error.

#### `helixCfg`

Structured helix settings, passed to [`programs.helix.settings`](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.helix.settings). Maps to `config.toml`.

- Type: `nullOr attrs`
- Default: `null`

```nix
programs.aedit.helixCfg = {
  theme = "gruvbox";
  editor = {
    line-number = "relative";
    cursor-shape.insert = "bar";
    lsp.display-messages = true;
    file-picker.hidden = false;
    indent-guides.render = true;
  };
  keys.normal = {
    C-s = ":write";
  };
};
```

Reference: [helix configuration docs](https://docs.helix-editor.com/configuration.html)

#### `helixCfgFile`

Path to an existing helix `config.toml` file. Symlinked into `~/.config/helix/config.toml`.

- Type: `nullOr path`
- Default: `null`

```nix
programs.aedit.helixCfgFile = ./helix/config.toml;
```

#### `helixLang`

Structured helix language settings, passed to [`programs.helix.languages`](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.helix.languages). Maps to `languages.toml`.

- Type: `nullOr attrs`
- Default: `null`

```nix
programs.aedit.helixLang = {
  language = [
    {
      name = "rust";
      auto-format = true;
      formatter.command = "rustfmt";
    }
    {
      name = "nix";
      auto-format = true;
      formatter.command = "nixfmt";
    }
  ];
  language-server.rust-analyzer.config.check = {
    command = "clippy";
  };
};
```

Reference: [helix languages docs](https://docs.helix-editor.com/languages.html)

#### `helixLangFile`

Path to an existing helix `languages.toml` file. Symlinked into `~/.config/helix/languages.toml`.

- Type: `nullOr path`
- Default: `null`

```nix
programs.aedit.helixLangFile = ./helix/languages.toml;
```

---

### Broot

#### `brootCfg`

Additional broot settings, passed to [`programs.broot.settings`](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.broot.enable). The aedit default verb (open file in helix on `Enter`) is always included -- any `verbs` you define here are appended alongside it.

- Type: `attrs`
- Default: `{}`

```nix
programs.aedit.brootCfg = {
  modal = true;
  show_selection_mark = true;
  verbs = [
    {
      invocation = "terminal";
      key = "ctrl-t";
      execution = "$SHELL";
      set_working_dir = true;
      leave_broot = false;
    }
  ];
};
```

Reference: [broot configuration docs](https://dystroy.org/broot/conf_file/)

#### `brootCfgFiles`

List of additional broot config files to import. Each file is symlinked into `~/.config/broot/` and added to broot's `imports` list.

- Type: `listOf path`
- Default: `[]`

```nix
programs.aedit.brootCfgFiles = [
  ./broot/skins.hjson
  ./broot/verbs.hjson
];
```

---

### Zellij

Configure zellij using either structured Nix attrs or a config file. These are mutually exclusive -- setting both will produce an assertion error.

#### `zellijCfg`

Structured zellij settings, passed to [`programs.zellij.settings`](https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zellij.settings). Maps to `config.kdl`.

- Type: `nullOr attrs`
- Default: `null`

```nix
programs.aedit.zellijCfg = {
  theme = "catppuccin-mocha";
  default_mode = "locked";
  pane_frames = false;
  simplified_ui = true;
  copy_command = "wl-copy";
};
```

Reference: [zellij configuration docs](https://zellij.dev/documentation/configuration)

#### `zellijCfgFile`

Path to an existing zellij `config.kdl` file. Symlinked into `~/.config/zellij/config.kdl`.

- Type: `nullOr path`
- Default: `null`

```nix
programs.aedit.zellijCfgFile = ./zellij/config.kdl;
```

#### `zellijLayout`

Path to a custom zellij layout file. **Not recommended** -- the default layout uses custom pane commands (`aedit-broot-start` and `aedit-hx-start`) that are required for aedit to function. If you override this, your layout must invoke those same commands or aedit will not work correctly. To adjust pane sizes, use `brootPaneSize` and `helixPaneSize` instead.

- Type: `nullOr path`
- Default: `null` (a layout is generated automatically)

```nix
# use a custom layout (not recommended)
programs.aedit.zellijLayout = ./my-layout.kdl;
```

---

#### `brootPaneSize`

Width of the broot (left) pane as a percentage.

- Type: `int`
- Default: `20`

#### `helixPaneSize`

Width of the helix (right) pane as a percentage.

- Type: `int`
- Default: `80`

```nix
# 30/70 split instead of the default 20/80
programs.aedit.brootPaneSize = 30;
programs.aedit.helixPaneSize = 70;
```

---

### Full example

```nix
{
  programs.aedit = {
    enable = true;

    helixCfg = {
      theme = "gruvbox";
      editor = {
        line-number = "relative";
        cursor-shape.insert = "bar";
        indent-guides.render = true;
      };
    };

    helixLang = {
      language = [
        { name = "rust"; auto-format = true; }
        { name = "nix"; auto-format = true; formatter.command = "nixfmt"; }
      ];
    };

    brootCfg = {
      modal = true;
    };

    zellijCfg = {
      theme = "catppuccin-mocha";
      pane_frames = false;
    };
  };
}
```

## Option summary

| Option | Type | Default | Description |
|---|---|---|---|
| `enable` | `bool` | `false` | Enable aedit |
| `helixCfg` | `nullOr attrs` | `null` | Helix config as Nix attrs |
| `helixCfgFile` | `nullOr path` | `null` | Path to helix `config.toml` |
| `helixLang` | `nullOr attrs` | `null` | Helix language config as Nix attrs |
| `helixLangFile` | `nullOr path` | `null` | Path to helix `languages.toml` |
| `brootCfg` | `attrs` | `{}` | Additional broot settings |
| `brootCfgFiles` | `listOf path` | `[]` | Broot config files to import |
| `zellijCfg` | `nullOr attrs` | `null` | Zellij config as Nix attrs |
| `zellijCfgFile` | `nullOr path` | `null` | Path to zellij `config.kdl` |
| `zellijLayout` | `nullOr path` | `null` (generated) | Custom zellij layout file (not recommended) |
| `brootPaneSize` | `int` | `20` | Broot (left) pane width percentage |
| `helixPaneSize` | `int` | `80` | Helix (right) pane width percentage |

### Mutual exclusivity

The following pairs cannot be set at the same time:

- `helixCfg` and `helixCfgFile`
- `helixLang` and `helixLangFile`
- `zellijCfg` and `zellijCfgFile`

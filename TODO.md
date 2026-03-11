4. when exiting zellij, bind ctrl + q to check if all hx tabs can be closed safely

## Notes on Issue 4 (deferred)

Approach: rebind Ctrl+Q in zellij config to a sequence:
- `MoveFocus "Right"` -> `Write 27` (Esc) -> `WriteChars ":qa"` -> `Write 13` (Enter)

Concerns:
- Race condition: focus movement and keystroke writes may not be atomic in zellij
- Would need a generated zellij config in `module.nix` (only when no user config is set via `zellijCfg`/`zellijCfgFile`)
- Helix pane needs `close_on_exit=true` in the layout + `on_force_close "quit"` for auto-exit after helix closes

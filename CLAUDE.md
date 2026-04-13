# nix-darwin-config

Declarative macOS config via nix-darwin + Home Manager + nix-homebrew.

## Apply changes

```sh
sudo darwin-rebuild switch --flake .#Skyscanner
sudo darwin-rebuild switch --flake .#CreateFuture
```

Single command handles everything: Nix packages, macOS defaults, Homebrew casks, Home Manager dotfiles. Requires root (sudo).

## Repository layout

```
flake.nix                    # Inputs + darwinConfigurations outputs
hosts/
  Skyscanner/                # Work MacBook (user: jameshorrocks)
    configuration.nix        # System-level: packages, homebrew, macOS defaults
    home.nix                 # Imports home_manager/ modules
    home_manager/
      claude.nix             # Claude Code: statusline, plugins, hooks, MCP servers
      zsh.nix                # Shell: Prezto + Starship
      ghostty.nix            # Terminal emulator config
      statusline-config.toml # claude-code-statusline layout
      karabiner.json         # Key remapping
  CreateFuture/              # Personal MacBook (user: james)
    configuration.nix
    home.nix
    home_manager/
```

## Architecture

- **flake.nix** — pins all inputs (nixpkgs unstable, nix-darwin, home-manager, nix-homebrew, mac-app-util, 1password-shell-plugins), declares two `darwinConfigurations`
- **configuration.nix** — system-level: nix-darwin modules, Homebrew taps/brews/casks, macOS defaults, fonts, services
- **home.nix** — user-level entry point: imports `home_manager/*.nix` modules
- **home_manager/*.nix** — individual tool configs as Home Manager modules

No shared modules. Reuse via copying `home_manager/*.nix` between hosts.

## Key files to know

| File | What it controls |
|------|-----------------|
| `hosts/Skyscanner/home_manager/claude.nix` | Claude Code settings, statusline command, plugins, hooks, MCP servers, permissions |
| `hosts/Skyscanner/home_manager/statusline-config.toml` | Statusline layout (lines, components, theme) |
| `hosts/Skyscanner/home_manager/zsh.nix` | Zsh via Prezto + Starship prompt |
| `hosts/*/configuration.nix` | Homebrew packages, system defaults |

## Claude Code specifics (Skyscanner host)

`claude.nix` manages:
- **Statusline command**: `CONFIG_PLUGINS_ENABLED=true CONFIG_PLUGINS_REQUIRE_SIGNATURE=false ~/.local/share/claude-code-statusline/statusline.sh`
  - Both env vars required — `plugins.enabled`/`plugins.require_signature` in TOML silently ignored by statusline codebase
- **Caveman plugin**: installed via `home.activation` (marketplace) + `enabledPlugins`; statusline plugin at `~/.claude/statusline/plugins/caveman/plugin.sh`
  - Plugin `plugin.sh` must define `render_*`, `collect_*_data`, call `register_component` to appear in display config
- **Caveman default mode**: `~/.config/caveman/config.json` → `{ "defaultMode": "lite" }`
- **Hooks**: Stop (mempalace save + macOS notification), PreCompact (mempalace), Notification (macOS ping)

## Adding a new host

1. Copy `hosts/Skyscanner/` or `hosts/CreateFuture/`
2. Update `configuration.nix` + `home.nix` for new user/machine
3. Add entry to `darwinConfigurations` in `flake.nix` with correct `username`
4. Run `sudo darwin-rebuild switch --flake .#NewHostName`

## Updating dependencies

```sh
nix flake update
sudo darwin-rebuild switch --flake .#Skyscanner
```

Commit `flake.nix` + `flake.lock` after update.

## Code formatting

Uses `nixfmt-rfc-style` via pre-commit:

```sh
pre-commit run --all-files
```
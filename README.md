# nix-darwin-config

Declarative macOS setups for James Horrocks, powered by [`nix-darwin`](https://github.com/nix-darwin/nix-darwin) and [Home Manager](https://nix-community.github.io/home-manager/). The repo holds two fully reproducible host profiles (CreateFuture & Skyscanner) that can be applied to any Apple Silicon Mac in minutes.

## Nix in 90 seconds

- **Nix the language** describes *what* packages and configuration you want, not *how* to build it. The output is pure (no hidden side effects), so the same definition always produces the same result.
- **The Nix store** keeps everything in content-addressed directories such as `/nix/store/abcd-package-version`. Nothing mutates in place, which makes rollbacks trivial.
- **Flakes** are versioned Nix projects. Pinning inputs (nixpkgs, nix-darwin, Home Manager, etc.) makes the entire system reproducible across machines.
- **nix-darwin** brings the Nix module system to macOS, so you can manage `defaults`, services, Homebrew, and system packages declaratively.
- **Home Manager** manages dotfiles and user-level programs with the same model, so shell tools, apps, and config files stay in sync.

> TL;DR: put everything in a flake, run one command, get the same machine every time.

## Stack overview

- [`nixpkgs`](https://github.com/NixOS/nixpkgs) unstable channel for most packages
- [`nix-darwin`](https://github.com/nix-darwin/nix-darwin) for system-wide modules
- [`home-manager`](https://github.com/nix-community/home-manager) for per-user config
- [`nix-homebrew`](https://github.com/zhaofengli/nix-homebrew) to declaratively manage taps/casks alongside Nix
- [`mac-app-util`](https://github.com/hraban/mac-app-util) for macOS app conveniences within Nix
- [`1Password shell plugins`](https://github.com/1Password/shell-plugins) to keep SSH/Git signing keys in 1Password

## Repository layout

```
.
├── flake.nix                  # Flake entrypoint defining host outputs
├── hosts/
│   ├── CreateFuture/          # Personal/work-for-hire profile
│   │   ├── configuration.nix  # nix-darwin modules (system defaults, Homebrew, etc.)
│   │   ├── home.nix           # Home Manager modules for this host
│   │   └── home_manager/…     # Reusable HM modules (zsh, ghostty, themes)
│   └── Skyscanner/            # Employer-specific profile
│       └── …
├── flake.lock                 # Pinned dependency graph
└── presentation.md            # Slide deck that introduced this setup
```

## Host profiles

| Host          | Username      | Highlights |
| ------------- | ------------- | ---------- |
| `CreateFuture`| `james`       | Lightweight workstation with shared tooling, ghostty + zsh modules, declarative 1Password shell plugins, personal Git identity.
| `Skyscanner`  | `jameshorrocks` | Adds Karabiner automation, corporate Homebrew taps (Databricks, Skyscanner), SSH via 1Password agent, company Git identity & signing.

_Note:_ Both hosts target `aarch64-darwin` (Apple Silicon). If you need Intel support, duplicate a host and adjust `system` in `flake.nix` plus any Rosetta-specific options.

## Getting started

### 1. Install Nix with flakes enabled

Follow the [official installer](https://nixos.org/download.html) or the [Determinate Systems (recommended)](https://determinate.systems/nix-installer) script. Ensure the experimental features `nix-command` and `flakes` are enabled (`~/.config/nix/nix.conf` or `/etc/nix/nix.conf`).

### 2. Clone this repo

```sh
git clone git@github.com:james-horrocks/nix-darwin-config.git
cd nix-darwin-config
```

### 3. Pick a host

Decide which profile to apply:

- Personal machine ➜ `.#CreateFuture`
- Work-issued machine ➜ `.#Skyscanner`

### 4. Apply the configuration

```sh
sudo darwin-rebuild switch --flake .#CreateFuture
```

Replace `CreateFuture` with `Skyscanner` as needed. This single command:

- Installs/updates Nix packages, apps, and services
- Configures macOS defaults (Dock, Finder, fonts, etc.)
- Installs and manages Homebrew taps/casks declaratively
- Runs Home Manager for user-level programs and dotfiles

Once applied, you can rerun the same command at any time to converge the machine to the repo state or roll back via `darwin-rebuild --list-generations`.

### Optional: use `nh`

The `CreateFuture` profile exports `NH_FLAKE=~/projects/nix-darwin-config/flake.nix#CreateFuture`, so you can simply run `nh switch` after the first deployment. Feel free to set a similar variable for other hosts.

## Updating dependencies

```sh
nix flake update
sudo darwin-rebuild switch --flake .#CreateFuture
```

The first command refreshes `flake.lock`; the second applies the new inputs. Commit both `flake.nix` and `flake.lock` whenever you change inputs or configuration.

## Customizing or adding a host

1. Copy an existing directory under `hosts/` and update `configuration.nix` + `home.nix`.
2. Add the new entry to `darwinConfigurations` in `flake.nix` (set the `username` and any `specialArgs`).
3. Run `darwin-rebuild switch --flake .#NewHost` to validate.

Because each host keeps Home Manager modules under `home_manager/`, you can reuse pieces (e.g., `zsh.nix`, `ghostty.nix`, themes) by importing them in the new `home.nix`.

## Secrets & identity

- SSH and Git signing keys live in 1Password and are injected via its agent socket; no private material is committed.
- Corporate Git identities are baked into each host, so switching hosts also switches author info and signing commands.

## Troubleshooting

- `darwin-rebuild --show-trace --flake .#Host` gives detailed evaluation errors.
- `nix-store --verify --check-contents` can diagnose store corruption if builds fail unexpectedly.
- Homebrew is managed by `nix-homebrew`; avoid running `brew tap` directly unless `mutableTaps = true` for that host.

Feel free to open an issue or PR if you spot inconsistencies or want to extend the configuration.

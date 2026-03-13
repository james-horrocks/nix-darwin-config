# Nix: Reproducible Systems & Environments

## What is Nix?

Nix is a cross-platform package manager for Unix-like systems and a functional language to configure those systems

- A purely functional, declarative **package manager** and **build system**
- Declarative **system configuration** for Linux (NixOS) and macOS (nix-darwin)
- Reproducible, shareable **development environments** for any project
- Platform/Infra: build AMIs, containers, and edge images from one source
- Personal productivity: **dotfiles**, **apps/packages**, and **system settings** stay in sync

## Some key concepts
- **Pure functions**: Nix expressions describe *what* you want, not *how* to build it
- **Content-addressed storage**: everything stored in `/nix/store` with unique hashes
- **Generations + garbage collection** = safe rollbacks on any machine
- **Flakes**: versioned Nix projects with pinned dependencies for reproducibility
- **Modules**: reusable, composable configuration for systems and users
- **Dev shells**: reproducible, shareable environments for any project
- **devenv**: higher-level UX for project environments with services and tasks


```bash
ls /nix/store | grep pre-commit
```

---

# System configuration spectrum
- **NixOS**: full Linux systems (networking, services, users, secrets)
- **nix-darwin**: macOS defaults, launch agents, security baselines
- **home-manager**: cross-OS dotfiles (zsh, git, editors, terminals)

E.g. on NixOS:
```nix
# configuration.nix
{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./services.nix
    ./users.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
}
```

---

# My work setup

## nix-darwin for macOS
- Declarative macOS setup with Nix modules
- Manage system defaults, services, Homebrew, and packages
- Combine with Home Manager for user-level config (dotfiles, apps)

## Home Manager for user config
- Manage dotfiles and user-level programs declaratively
- Sync shell tools, apps, and config files across machines
- Reusable modules for zsh, git, editors, themes, and more
- Integrates with nix-darwin for full-system + user setup
- Can also run standalone

---

# Project environments with `nix develop`
- Dev shells (`devShells.<name>`) pin compilers, CLIs, SDKs, data tools
- Integrate with `direnv` so repos auto-load environments on `cd`
- Compose secrets (`sops-nix`), helper services (LocalStack, MinIO) inside the shell
- Same shell definition powers local workstations and CI smoke tests

---

# Spotlight on `devenv`
- Higher-level UX atop Nix for project environments
- Declarative `devenv.nix` describes packages, services, scripts, env vars
- `devenv up` launches both the shell and background services (DBs, brokers)
- Ships editor tasks and health checks so teams share a common workflow

```nix
# devenv.nix
{ pkgs, lib, ... }:
{
  languages.python = {
    enable = true;
    uv = {
      enable = true;
      sync.enable = true;
    };
  };

  services.postgres = {
    enable = true;
    port = 5432;
    initialDatabases = [ { name = "ledger"; } ];
    initialScript = ''
      ALTER USER postgres WITH PASSWORD 'postgres';
    '';
  };
}
```
- `devenv up` evaluates this Nix file, installs `uv`, and runs Postgres via the built-in service module

---

# nix-shell for interactive use
- Quick, ad-hoc shells for one-off tasks
- Define dev shells in `shell.nix` or `default.nix`, or use `nix-shell -p <pkg>` to install on-the-fly
- Less reproducible than flakes/devenv, but great for exploration

---

# Questions?

## Resources
- **Nix official site** - [](https://nixos.org)
- **Recommended Nix distribution** - [](https://determinate.systems/nix-installer)
- **nix-darwin** - [](https://github.com/nix-darwin/nix-darwin)
- **Home Manager** - [](https://github.com/nix-community/home-manager)
- **devenv** - [](https://devenv.sh)
- **My nix-darwin config** - [](https://github.com/james-horrocks/nix-darwin-config)
- **Excellent YouTube videos** - [](https://youtube.com/@vimjoyer)

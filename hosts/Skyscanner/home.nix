{ inputs, pkgs, lib, username, ... }:

{
  # home.username = username;
  # home.homeDirectory = "/Users/${username}";

  home.packages = with pkgs; [
    fastfetch
    zsh-fast-syntax-highlighting
    chroma

    _1password-cli
    alt-tab-macos

    spotify-player

    obsidian

    vscode
    uv
    pre-commit
    amazon-ecr-credential-helper
    gh
  ];

  home.file = {
    ".dircolors".source = ./home_manager/dracula_dircolors;
    ".config/karabiner/assets/complex_modifications/windows_nav_keys.json".source = ./home_manager/nav_keys.json;
    ".config/karabiner/karabiner.json".source = ./home_manager/karabiner.json;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        identityAgent = "'~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'";
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "James Horrocks";
      user.email = "jameshorrocks@skyscanner.net";
      init.defaultBranch = "main";
      gpg.format = "ssh";
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };
    signing = {
      format = "ssh";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACCeXcAMW7DTQ5M9j95T0Yi6OgKOYHbJZ/O8f7Lx9xJ";
      signByDefault = true;
      signer = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };
    ignores = [
      ".vscode/"
      ".idea/"
    ];
  };

  programs._1password-shell-plugins = {
    # enable 1Password shell plugins for bash, zsh, and fish shell
    enable = false;
    # the specified packages as well as 1Password CLI will be
    # automatically installed and configured to use shell plugins
    plugins = with pkgs; [ gh awscli2 ];
  };

  home.stateVersion = "25.05";

  imports = [
    inputs._1password-shell-plugins.hmModules.default
    ./home_manager/zsh.nix
    ./home_manager/ghostty.nix
  ];
}

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
    pyenv
  ];

  home.file = {
    ".dircolors".source = ./home_manager/dracula_dircolors;
  };

  home.sessionVariables = {
    EDITOR = "code";
    NH_FLAKE = "Skyscanner";

    PATH="/opt/homebrew/opt/openssl@3/bin:$PATH";
    LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib";
    CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include";
    PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@3/lib/pkgconfig";
    SSL_CERT_FILE="/opt/homebrew/opt/openssl@3/cert.pem";
    REQUESTS_CA_BUNDLE="/opt/homebrew/opt/openssl@3/cert.pem";
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
    userName = "James Horrocks";
    userEmail = "jameshorrocks@skyscanner.net";
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
    extraConfig = {
      init.defaultBranch = "main";
      gpg.format = "ssh";
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };
  };

  programs._1password-shell-plugins = {
    # enable 1Password shell plugins for bash, zsh, and fish shell
    enable = true;
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

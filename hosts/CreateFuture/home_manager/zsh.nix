{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # initContent = lib.mkMerge [
    #   lib.mkOrder 500 ''
    #     if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
    #       source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
    #     fi
    #   ''
    #   lib.mkOrder 1000 ''
    #     eval `dircolors ~/.dircolors`
    #     [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    #     fpath+=~/.zsh_functions
    #     export EDITOR='code'
    #   ''
    # ];

    localVariables = {
      # POWERLEVEL9K_MODE="nerdfont-complete";
      COMPLETION_WAITING_DOTS=true;
      ZSH_DISABLE_COMPFIX=true;
    };

    profileExtra = ''
    if [ -d "$HOME/bin" ] ; then
        PATH="$HOME/bin:$PATH"
    fi

    if [ -d "$HOME/.local/bin" ] ; then
        PATH="$HOME/.local/bin:$PATH"
    fi

    if [ -d "${pkgs.vscode}/bin" ] ; then
        PATH="${pkgs.vscode}/bin:$PATH"
    fi
    '';

    sessionVariables = {
      AWS_SDK_LOAD_CONFIG=1;
    };

    # plugins = [
    #   {
    #     name = "powerlevel10k";
    #     src = pkgs.zsh-powerlevel10k;
    #     file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    #   }
    # ];

    oh-my-zsh = {
      enable = true;
      plugins = [
        "z"
        "common-aliases"
        "sudo"
        "git"
        "python"
        "pip"
        "poetry"
        "virtualenv"
        "aws"
        "docker"
        "docker-compose"
        "terraform"
        "rsync"
        "systemd"
        "1password"
      ];
    };
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    useTheme = "atomic";
  };

  # home.file.".p10k.zsh".source = ./powerlevel10k.zsh;
}
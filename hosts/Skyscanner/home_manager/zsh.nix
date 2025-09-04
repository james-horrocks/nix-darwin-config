{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = let 
      configGeneral = lib.mkOrder 1000 ''
        # eval `dircolors ~/.dircolors`
        fpath+=~/.zsh_functions
      '';
      configAfter = lib.mkOrder 1500 ''
        alias ls='ls --color=auto'

        [[ -s "/home/dudette/.sdkman/bin/sdkman-init.sh" ]] && source "/home/dudette/.sdkman/bin/sdkman-init.sh"
      '';
    in
      lib.mkMerge [
        configGeneral
        configAfter
      ]
    ;

    localVariables = {
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
      EDITOR="code";
      ZSH_COLORIZE_TOOL="chroma";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "aliases"
        "z"
        "common-aliases"
        "sudo"
        "git"
        "python"
        "pip"
        "poetry"
        "uv"
        "virtualenv"
        "sdk"
        "pre-commit"
        "aws"
        "docker"
        "docker-compose"
        "terraform"
        "rsync"
        "macos"
        "1password"
        "vscode"
        "colorize"
      ];
    };
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    useTheme = "atomic";
  };
}

{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = let 
      configGeneral = lib.mkOrder 1000 ''
        eval `dircolors ~/.dircolors`
        fpath+=~/.zsh_functions
        export EDITOR='code'
      '';
    in
      lib.mkMerge [
        configGeneral
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
    };

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
}

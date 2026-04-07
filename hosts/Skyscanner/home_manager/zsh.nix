{
  config,
  pkgs,
  lib,
  username,
  ...
}:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent =
      let
        configBefore = lib.mkOrder 500 ''
          COMPLETION_WAITING_DOTS=true
          ZSH_DISABLE_COMPFIX=true
          DISABLE_AUTO_UPDATE=true
          DISABLE_MAGIC_FUNCTIONS=true
          DISABLE_COMPFIX=true
          ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
          ZSH_AUTOSUGGEST_USE_ASYNC=1

        '';
        configGeneral = lib.mkOrder 1000 ''
          # eval `dircolors ~/.dircolors`
          fpath+=~/.zsh_functions

          eval "$(pyenv init - zsh)"
          eval "$(pyenv virtualenv-init -)"
        '';
        configAfter = lib.mkOrder 1500 ''
          alias ls='ls --color=auto'

          sdk() {
            unfunction sdk
            [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
            sdk "$@"
          }

          [[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"
        '';
      in
      lib.mkMerge [
        configBefore
        configGeneral
        configAfter
      ];

    profileExtra = ''
      # Resolve 1Password secrets into shell environment.
      # Runs in login shells, so env vars reach VS Code extensions and terminals.
      # Silently skips if op is unavailable or 1Password is locked.
      if command -v op &>/dev/null; then
        export GITHUB_PERSONAL_ACCESS_TOKEN="$(op read "op://Personal/GitHub PAT/token" 2>/dev/null)"
      fi

      if [ -d "$HOME/bin" ] ; then
          PATH="$HOME/bin:$PATH"
      fi

      if [ -d "$HOME/.local/bin" ] ; then
          PATH="$HOME/.local/bin:$PATH"
      fi

      if [ -d "${pkgs.vscode}/bin" ] ; then
          PATH="${pkgs.vscode}/bin:$PATH"
      fi

      if [ -d "/opt/homebrew/bin" ] ; then
          PATH="/opt/homebrew/bin:$PATH"
      fi

      eval "$(/opt/homebrew/bin/pyenv init - zsh)"
    '';

    sessionVariables = {
      AWS_SDK_LOAD_CONFIG = 1;
      EDITOR = "code";
      ZSH_COLORIZE_TOOL = "chroma";

      NH_FLAKE = "Skyscanner";
      PATH = "/Users/${username}/.openfang/bin:/Users/${username}/.cargo/bin:/Users/${username}/.local/bin:/opt/homebrew/opt/openssl@3/bin:$PATH";

      LDFLAGS = "-L/opt/homebrew/opt/openssl@3/lib";
      CPPFLAGS = "-I/opt/homebrew/opt/openssl@3/include";
      PKG_CONFIG_PATH = "/opt/homebrew/opt/openssl@3/lib/pkgconfig";
      SSL_CERT_FILE = "/opt/homebrew/opt/openssl@3/cert.pem";
      REQUESTS_CA_BUNDLE = "/opt/homebrew/opt/openssl@3/cert.pem";

      PYENV_ROOT = "$HOME/.pyenv";
      HOMEBREW_NO_AUTO_UPDATE = 1;
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
    settings = builtins.fromJSON (
      builtins.unsafeDiscardStringContext (builtins.readFile (./. + "/night-owl.omp.json"))
    );
  };
}

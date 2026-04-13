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
    # Completion, autosuggestions, and syntax highlighting are handled
    # by the prezto modules below — do not enable them at the zsh level too.
    enableCompletion = false;
    autosuggestion.enable = false;
    syntaxHighlighting.enable = false;

    prezto = {
      enable = true;
      pmodules = [
        "environment"
        "terminal"
        "editor" # provides sudo ESC-ESC (replaces sudo plugin)
        "history"
        "directory"
        "spectrum"
        "utility" # replaces: aliases, common-aliases
        "completion" # must be before modules that call compdef (fasd, git, python, docker)
        "fasd" # replaces: z
        "git" # replaces: git plugin
        "python" # replaces: python, pip, virtualenv
        "docker" # replaces: docker, docker-compose
        "rsync" # replaces: rsync
        "osx" # replaces: macos
        "syntax-highlighting" # replaces: syntaxHighlighting.enable
        "autosuggestions" # must be after completion and syntax-highlighting
        # No 'prompt' module — Starship owns prompt rendering
      ];
    };

    initContent =
      let
        configBefore = lib.mkOrder 500 ''
          ZSH_DISABLE_COMPFIX=true
          DISABLE_AUTO_UPDATE=true
          DISABLE_MAGIC_FUNCTIONS=true
          DISABLE_COMPFIX=true
          ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
          ZSH_AUTOSUGGEST_USE_ASYNC=1
          ZSH_COLORIZE_TOOL="chroma"
        '';
        configGeneral = lib.mkOrder 1000 ''
          fpath+=~/.zsh_functions

          pyenv() {
            unfunction pyenv
            eval "$(command pyenv init - zsh)"
            eval "$(command pyenv virtualenv-init -)"
            pyenv "$@"
          }
        '';
        configAfter = lib.mkOrder 1500 ''
          alias ls='ls --color=auto'

          sdk() {
            unfunction sdk
            [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
            sdk "$@"
          }

          [[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

          # --- Manual completions (run after compinit) ---

          # Enable bash-style completion commands in zsh
          autoload -Uz bashcompinit && bashcompinit

          # AWS
          complete -C aws_completer aws

          # Terraform
          complete -o nospace -C terraform terraform

          # 1Password CLI
          if command -v op &>/dev/null; then
            eval "$(op completion zsh)"
          fi

          # Poetry — don't eval: its completion script calls itself immediately,
          # which triggers _tags outside a completion context. Write to fpath instead;
          # zsh autoloads it only when actually tab-completing poetry.
          if command -v poetry &>/dev/null; then
            mkdir -p "$HOME/.zsh_functions"
            [[ ! -f "$HOME/.zsh_functions/_poetry" ]] && \
              poetry completions zsh > "$HOME/.zsh_functions/_poetry" 2>/dev/null
          fi

          # uv
          if command -v uv &>/dev/null; then
            eval "$(uv generate-shell-completion zsh)"
          fi
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
        export GITHUB_PERSONAL_ACCESS_TOKEN="$(op --account=my.1password.com read "op://Personal/GitHub PAT/token" 2>/dev/null)"
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
    '';

    sessionVariables = {
      AWS_SDK_LOAD_CONFIG = 1;
      EDITOR = "code";
      NH_FLAKE = "Skyscanner";
      PATH = "/Users/${username}/.openfang/bin:/Users/${username}/.cargo/bin:/Users/${username}/.local/bin:/opt/homebrew/opt/openssl@3/bin:$PATH";

      LDFLAGS = "-L/opt/homebrew/opt/openssl@3/lib";
      CPPFLAGS = "-I/opt/homebrew/opt/openssl@3/include";
      PKG_CONFIG_PATH = "/opt/homebrew/opt/openssl@3/lib/pkgconfig";
      SSL_CERT_FILE = "/opt/homebrew/opt/openssl@3/cert.pem";
      REQUESTS_CA_BUNDLE = "/opt/homebrew/opt/openssl@3/cert.pem";

      PYENV_ROOT = "$HOME/.pyenv";
      HOMEBREW_NO_AUTO_UPDATE = 1;

      DATABRICKS_HOST = "https://skyscanner-dev.cloud.databricks.com";
      DATABRICKS_CONFIG_PROFILE = "skyscanner-dev";
      DATABRICKS_WAREHOUSE_ID = "d5f01b26a308cf40";
      DATABRICKS_TOKEN = "dummy";
    };
  };

  # Catppuccin Powerline preset (mocha flavour)
  # Preset: https://starship.rs/presets/catppuccin-powerline
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  xdg.configFile."starship.toml".source = ./starship.toml;
}

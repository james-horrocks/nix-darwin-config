{ inputs, config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = pkgs.emptyDirectory;
    enableZshIntegration = true;

    settings = {
      theme = "noctis-uva";
      font-family = "MesloLGS NF";
      font-size = 14;

      cursor-style = "bar";
      cursor-style-blink = true;

      background-opacity = 0.85;
      background-blur = true;

      shell-integration = "zsh";
      shell-integration-features = true;
    };
  };

  home.file = {
    ".config/ghostty/themes/noctis".source = ./ghostty_themes/noctis;
    ".config/ghostty/themes/noctis-azureus".source = ./ghostty_themes/noctis-azureus;
    ".config/ghostty/themes/noctis-bordo".source = ./ghostty_themes/noctis-bordo;
    ".config/ghostty/themes/noctis-hibernus".source = ./ghostty_themes/noctis-hibernus;
    ".config/ghostty/themes/noctis-lilac".source = ./ghostty_themes/noctis-lilac;
    ".config/ghostty/themes/noctis-lux".source = ./ghostty_themes/noctis-lux;
    ".config/ghostty/themes/noctis-minimus".source = ./ghostty_themes/noctis-minimus;
    ".config/ghostty/themes/noctis-uva".source = ./ghostty_themes/noctis-uva;
    ".config/ghostty/themes/noctis-viola".source = ./ghostty_themes/noctis-viola;
  };
}
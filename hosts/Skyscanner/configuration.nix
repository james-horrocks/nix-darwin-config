{ pkgs, lib, inputs, username, ... }:

{
  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    coreutils
    git
    wget
    curl
    nixpkgs-fmt
    nh
  ];

  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;
    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;
    # User owning the Homebrew prefix
    user = username;

    # Optional: Enable fully-declarative tap management
    #
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    mutableTaps = true;
  };

  homebrew = {
    enable = true;
    taps = [
      {
        name = "skyscanner/mshell";
        clone_target = "git@github.com:Skyscanner/homebrew-mshell.git";
        force_auto_update = true;
      }
    ];
    brews = [
      "artifactory-cli-login"
      "skyscanner-bundle"
      "openssl@3"
      "astro"
    ];
    casks = [
      "wins"
      "ghostty"
      "todoist-app"
      "plexamp"
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.meslo-lg
    nerd-fonts.jetbrains-mono
  ];

    services.karabiner-elements = {
    enable = true;
    package = pkgs.karabiner-elements.overrideAttrs (old: {
      version = "14.13.0";

      src = pkgs.fetchurl {
        inherit (old.src) url;
        hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
      };

      dontFixup = true;
    });
  };

  system.defaults = {
    dock = { 
      autohide = true;
      autohide-delay = 0.1;
      autohide-time-modifier = 0.5;

      minimize-to-application = true;
      show-recents = false;
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      CreateDesktop = false;
      FXRemoveOldTrashItems = true;
      NewWindowTarget = "Home";
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowScrollBars = "Always";
      AppleScrollerPagingBehavior = true;
      _HIHideMenuBar = true;
    };
  };

  home-manager = {
    users.${username} = ./home.nix;
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [ inputs.mac-app-util.homeManagerModules.default ];
    extraSpecialArgs = {
      inherit inputs;
      inherit pkgs;
      inherit username;
    };
  };

  nix.enable = false;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  system.stateVersion = "25.05"; # adjust based on darwin modules compatibility
}

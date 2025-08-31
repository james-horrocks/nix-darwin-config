{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    mac-app-util.url = "github:hraban/mac-app-util";
    _1password-shell-plugins.url = "github:1Password/shell-plugins";
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    nix-homebrew,
    mac-app-util,
    ... }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      username = "james";
    in
    {
      darwinConfigurations = {
        "CreateFuture" = nix-darwin.lib.darwinSystem {
          system = system;
          modules = [
            ./hosts/CreateFuture/configuration.nix
            mac-app-util.darwinModules.default
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
          ];
          specialArgs = { 
            inherit inputs;
            username = username;
          };
        };
      };

      
    };
}

{
  description = "NixOS multi-platform configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dankmaterialshell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hackgen = {
      url = "github:yuru7/HackGen";
      flake = false;
    };

  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      vars = import ./vars/default.nix;
      lib = import ./lib { inherit inputs vars; };
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      forAllSystems = f:
        builtins.listToAttrs (map
          (system: {
            name = system;
            value = f system;
          })
          systems);
    in
    {
      nixosConfigurations = {
        Yuzu = lib.mkNixosSystem { host = "Yuzu"; };
        Citrus = lib.mkNixosSystem { host = "Citrus"; };
      };

      darwinConfigurations = {
        Sudachi = lib.mkDarwinSystem { host = "Sudachi"; };
      };

      formatter = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ (import ./overlays { inherit inputs; }) ];
          };
        in
        pkgs.nixpkgs-fmt
      );
    };
}

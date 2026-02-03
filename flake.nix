{
  description = "NixOS multi-platform configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    dankmaterialshell = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
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
    nur = {
      url = "github:nix-community/NUR";
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
      systems = [ "x86_64-linux" ];
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
        Citrus = lib.mkNixosSystem { host = "Citrus"; };
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

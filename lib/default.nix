{ inputs, vars }:
let
  lib = inputs.nixpkgs.lib;
in
{
  mkNixosSystem = { host }:
    let
      hostConfig = vars.hosts.${host};
      system = hostConfig.system;
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ (import ../overlays { inherit inputs; }) ];
      };
    in
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs vars;
      };
      modules = [
        ./../hosts/${lib.strings.toLower host}/default.nix
      ];
    };

  mkDarwinSystem = { host }:
    let
      hostConfig = vars.hosts.${host};
      system = hostConfig.system;
    in
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit inputs vars;
      };
      modules = [
        ./../hosts/${lib.strings.toLower host}/default.nix
      ];
    };
}

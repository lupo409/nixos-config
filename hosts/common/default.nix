{ inputs, ... }:
{
  nixpkgs.overlays = [ (import ../../overlays { inherit inputs; }) ];

  imports = [
    ./security.nix
    ./sops.nix
  ];
}

{ inputs, ... }:
{
  nixpkgs.overlays = [
    inputs.nur.overlays.default
    (import ../../overlays { inherit inputs; })
  ];

  imports = [
    ./security.nix
    ./nix-ld.nix
  ];
}

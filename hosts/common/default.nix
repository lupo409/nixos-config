{ inputs, lib, ... }:
{
  imports = [
    ./locale.nix
    ./nix.nix
    ./users.nix
    ./session.nix
    ./packages.nix
    ./fonts.nix
    ./udev.nix
    ./security.nix
    ./nix-ld.nix
  ];

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    inputs.nur.overlays.default
    inputs.llm-agents.overlays.default
    (final: _prev: { })
  ];
}

{ inputs, ... }:
{
  imports = [
    ../common/default.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.dankmaterialshell.nixosModules.dank-material-shell
    ./hardware-configuration.nix
    # ../../modules/nixos/secure-boot.nix
    ../../modules/nixos/niri.nix
    ../../modules/nixos/wayland.nix
    ../../modules/nixos/fcitx5.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/pipewire.nix
    ./boot.nix
    ./locale.nix
    ./users.nix
    ./desktop.nix
    ./home-manager.nix
    ./packages.nix
    ./nix.nix
  ];

  networking.hostName = "Citrus";

  system.stateVersion = "24.11";
}

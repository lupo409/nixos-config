{ inputs, ... }:
{
  imports = [
    ../common/default.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.dankmaterialshell.nixosModules.dank-material-shell
    inputs.dms-plugin-registry.modules.default
    ./hardware-configuration.nix
    ../../modules/nixos/secure-boot.nix
    ../../modules/nixos/niri.nix
    ../../modules/nixos/wayland.nix
    ../../modules/nixos/fcitx5.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/pipewire.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/ios.nix
    ../../modules/nixos/tailscale.nix
    ../../modules/nixos/sops.nix
    ../../modules/nixos/hardware-monitoring.nix
    ./networking.nix
    ./boot.nix
    ./desktop.nix
    ./server.nix
    ./home-manager.nix
  ];

  networking.hostName = "Citrus";

  system.stateVersion = "24.11";
}

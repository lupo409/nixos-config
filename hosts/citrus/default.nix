{ inputs, vars, pkgs, ... }:
{
  imports = [
    ../common/default.nix
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../../modules/nixos/lanzaboote.nix
    ../../modules/nixos/niri.nix
    ../../modules/nixos/wayland.nix
    ../../modules/nixos/fcitx5.nix
  ];

  networking.hostName = "Citrus";

  users.users.${vars.user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  programs.zsh.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs vars;
    };
    users.${vars.user} = import ../../home/takahiro/default.nix;
  };

  fonts.packages = with pkgs; [
    hackgen
    noto-fonts-cjk-sans
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}

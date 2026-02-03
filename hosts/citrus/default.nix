{ inputs, vars, pkgs, ... }:
{
  imports = [
    ../common/default.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.dankmaterialshell.nixosModules.dank-material-shell
    ./hardware-configuration.nix
    ../../modules/nixos/secure-boot.nix
    ../../modules/nixos/niri.nix
    ../../modules/nixos/wayland.nix
    ../../modules/nixos/fcitx5.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/pipewire.nix
    ../common/nix-ld.nix
  ];

  # XanMod kernel for low-latency gaming and desktop performance
  # Note: xanmod_rt is not directly available in nixpkgs yet (see: https://github.com/NixOS/nixpkgs/issues/383117)
  # Using xanmod_latest which includes performance optimizations
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  networking.hostName = "Citrus";

  users.users.${vars.user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  programs.zsh.enable = true;

  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
  };

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";
  };

  programs.dsearch = {
    enable = true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs vars;
    };
    users.${vars.user} = import ../../home/takahiro/default.nix;
  };

  environment.systemPackages = with pkgs; [
    dgop
  ];

  fonts.packages = with pkgs; [
    hackgen
    noto-fonts-cjk-sans
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}

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
    ../common/nix-ld.nix
  ];

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
    enableClipboardPaste = true;
    package = inputs.dankmaterialshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

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

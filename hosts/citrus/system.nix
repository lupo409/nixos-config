{ config, pkgs, lib, vars, inputs, ... }:
let
  initrdModulesRoot = pkgs.runCommand "initrd-modules-root" { allowSubstitutes = false; preferLocalBuild = true; } ''
    mkdir -p $out
    ln -s ${config.system.build.modulesClosure}/lib/modules $out/modules
    if [ -d ${config.system.build.modulesClosure}/lib/firmware ]; then
      ln -s ${config.system.build.modulesClosure}/lib/firmware $out/firmware
    fi
  '';
in
{
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.contents."/lib".source = lib.mkForce initrdModulesRoot;

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "ja_JP.UTF-8";
  i18n.supportedLocales = [ "ja_JP.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ vars.username ];
    substituters = [ "https://cache.numtide.com" ];
    trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

  nix.extraOptions = ''
    !include /run/secrets/nix-access-tokens.conf
  '';

  sops.templates.nix_access_tokens = {
    path = "/run/secrets/nix-access-tokens.conf";
    owner = "root";
    group = "root";
    mode = "0400";
    content = ''
      access-tokens = github.com=${config.sops.placeholder."github/token"}
    '';
  };

  users.users.${vars.username} = {
    isNormalUser = true;
    home = vars.homeDirectory;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  security.sudo = {
    enable = true;
    extraRules = [{
      users = [ vars.username ];
      commands = [{
        command = "ALL";
        options = [ "NOPASSWD" ];
      }];
    }];
  };

  programs.zsh.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3554", ATTRS{idProduct}=="f5f7", TAG+="uaccess"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1ca6", ATTRS{idProduct}=="3002", TAG+="uaccess"
  '';


  environment.systemPackages = with pkgs; [
    dgop
    papirus-icon-theme
  ];

  fonts.packages = with pkgs; [
    hackgen-font
    hackgen-nf-font
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Noto Sans CJK JP" "Noto Sans CJK" ];
      serif = [ "Noto Serif CJK JP" "Noto Serif CJK" ];
      monospace = [ "HackGen Console NF" "HackGen Console" "HackGen" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}

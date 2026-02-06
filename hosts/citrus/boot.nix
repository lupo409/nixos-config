{ config, pkgs, lib, ... }:
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
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.contents."/lib".source = lib.mkForce initrdModulesRoot;
}

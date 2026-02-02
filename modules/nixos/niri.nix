{ pkgs, inputs, ... }:
{
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  environment.systemPackages = [
    inputs.dankmaterialshell.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}

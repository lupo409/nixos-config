{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bitwarden
    obs-studio
  ];
}

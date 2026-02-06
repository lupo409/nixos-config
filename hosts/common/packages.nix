{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    dgop
    papirus-icon-theme
  ];
}

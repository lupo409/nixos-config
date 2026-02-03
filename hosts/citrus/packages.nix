{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    dgop
  ];

  fonts.packages = with pkgs; [
    hackgen
    noto-fonts-cjk-sans
  ];
}

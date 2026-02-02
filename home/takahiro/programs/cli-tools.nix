{ pkgs, ... }:
{
  programs = {
    eza.enable = true;
    fd.enable = true;
    ripgrep.enable = true;
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
      };
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    bottom.enable = true;
    fastfetch.enable = true;
  };

  home.packages = with pkgs; [
    dust
    nano
  ];
}

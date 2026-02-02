{ pkgs, vars, ... }:
{
  imports = [
    ./programs/zsh.nix
    ./programs/git.nix
    ./programs/cli-tools.nix
    ./programs/dev-tools.nix
    ./programs/just.nix
  ];

  home.username = vars.user;
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${vars.user}" else "/home/${vars.user}";
  home.stateVersion = "26.05";

  xdg.enable = true;

  programs.home-manager.enable = true;
}

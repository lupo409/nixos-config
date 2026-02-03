{ pkgs, vars, inputs, lib, ... }:
{
  imports = [
    ./programs/zsh.nix
    ./programs/git.nix
    ./programs/cli-tools.nix
    ./programs/dev-tools.nix
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    inputs.dankmaterialshell.homeModules.dank-material-shell
    inputs.dankmaterialshell.homeModules.niri
    ./programs/dank-material-shell.nix
  ];

  home.username = vars.user;
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${vars.user}" else "/home/${vars.user}";
  home.stateVersion = "26.05";

  xdg.enable = true;

  programs.home-manager.enable = true;
}

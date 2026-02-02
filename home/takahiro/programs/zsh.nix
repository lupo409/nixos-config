{ config, lib, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    dotDir = config.home.homeDirectory;

    shellAliases = {
      ls = "eza";
      cat = "bat";
    };

    initContent = lib.mkOrder 1000 ''
      eval "$(zoxide init zsh)"
    '';
  };
}

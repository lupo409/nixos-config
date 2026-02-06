{ config, pkgs, vars, ... }:
{
  users.users.${vars.username} = {
    isNormalUser = true;
    home = vars.homeDirectory;
    hashedPasswordFile = config.sops.secrets."user/hashedPassword".path;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };
  users.mutableUsers = false;

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
}

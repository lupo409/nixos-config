{ inputs, config, lib, vars, ... }:
let
  sopsFile = ../../secrets/api-keys.yaml;
  hasSopsFile = builtins.pathExists sopsFile;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = lib.mkIf hasSopsFile {
    defaultSopsFile = sopsFile;
    age.keyFile = "${config.users.users.${vars.user}.home}/.config/sops/age/keys.txt";

    secrets = {
      opencode_api_key = {
        owner = config.users.users.${vars.user}.name;
      };
      claude_api_key = {
        owner = config.users.users.${vars.user}.name;
      };
    };
  };
}

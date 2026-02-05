{ inputs, lib, pkgs, vars, ... }:
let
  secretsFile = ../../secrets/secrets.yaml;
  hasSecrets = builtins.pathExists secretsFile;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = lib.mkIf hasSecrets {
    defaultSopsFile = secretsFile;
    age = {
      keyFile = "/etc/sops/age/keys.txt";
      generateKey = true;
    };

    secrets."github/token".owner = vars.username;
    secrets."tailscale/authkey".owner = vars.username;
  };

  assertions = [
    {
      assertion = hasSecrets;
      message = "Missing secrets file: secrets/secrets.yaml. Copy secrets/secrets.yaml.example and encrypt with sops.";
    }
  ];

  environment.systemPackages = with pkgs; [
    sops
    ssh-to-age
    age
    age-plugin-yubikey
    jq
  ];
}

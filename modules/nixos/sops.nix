{ inputs, pkgs, vars, ... }:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = "/etc/nixos/secrets.yaml";
    validateSopsFiles = false;
    age = {
      keyFile = "/etc/sops/age/keys.txt";
      generateKey = true;
    };

    secrets."github/token".owner = vars.username;
    secrets."tailscale/authkey".owner = vars.username;
  };

  environment.systemPackages = with pkgs; [
    sops
    ssh-to-age
    age
    age-plugin-yubikey
    jq
  ];
}

{ inputs, pkgs, vars, config, ... }:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    validateSopsFiles = false;
    age = {
      keyFile = "/etc/sops/age/keys.txt";
      generateKey = true;
    };

    secrets."dms/weather_coordinates" = {
      owner = vars.username;
      mode = "0400";
    };
    secrets."user/hashedPassword" = {
      owner = "root";
      mode = "0400";
      neededForUsers = true;
    };
  };

  environment.systemPackages = with pkgs; [
    sops
    ssh-to-age
    age
    age-plugin-yubikey
    jq
  ];
}

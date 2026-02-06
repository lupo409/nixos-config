{ config, inputs, vars, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs vars;
      nixosConfig = config;
    };
    users.${vars.username} = import ../../home-manager/default.nix;
  };

}

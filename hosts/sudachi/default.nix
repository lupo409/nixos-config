{ inputs, vars, ... }:
{
  imports = [
    ../../modules/darwin/default.nix
    inputs.home-manager.darwinModules.home-manager
  ];

  networking.hostName = "Sudachi";

  users.users.${vars.user} = {
    home = "/Users/${vars.user}";
  };

  programs.zsh.enable = true;

  homebrew = {
    enable = true;
    casks = [
      "prismlauncher"
      "intellij-idea-ce"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs vars;
    };
    users.${vars.user} = import ../../home/takahiro/default.nix;
  };

  system.stateVersion = 5;
}

{ pkgs, ... }:
let
  extensions = pkgs.nur.repos.rycee.firefox-addons;
in
{
  programs.chromium = {
    enable = true;
    package = pkgs.chromium;
    extensions = [
      {
        id = "ddkjiahejlhfcafbddmgiahcphecmpfh";
      }
    ];
  };

  programs.firefox = {
    enable = true;
    policies = {
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;
      DisableAppUpdate = true;
    };
    profiles.default = {
      settings = {
        "extensions.autoDisableScopes" = 0;
      };
      extensions.packages = with extensions; [
        sponsorblock
        bonjourr-startpage
        bitwarden
        decentraleyes
        tampermonkey
        darkreader
      ];
    };
  };
}

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
    profiles.default = let
      photoshow = pkgs.fetchurl {
        url = "https://addons.mozilla.org/firefox/downloads/file/4672520/photoshow-4.86.1.xpi";
        sha256 = "sha256-zXdkl2xx4398mQeorT6eX8qC4E7N1UVFYTPzXog6T5Q=";
      };
    in {
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
      ] ++ [ photoshow ];
    };
  };
}

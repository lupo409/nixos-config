{ pkgs, ... }:
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
      extensions = [
        { id = "sponsorBlocker@ajay.app"; }
        { id = "{4f391a9e-8717-4ba6-a5b1-488a34931fcb}"; }
        { id = "{446900e4-71c2-419f-a6a7-df9c091e268b}"; }
        { id = "jid1-BoFifL9Vbdl2zQ@jetpack"; }
        { id = "firefox@tampermonkey.net"; }
        { id = "{c23d8eea-4e71-4573-a245-4c97f8e1a1e0}"; }
        { id = "addon@darkreader.org"; }
      ];
    };
  };
}

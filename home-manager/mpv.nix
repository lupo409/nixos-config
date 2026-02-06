{ pkgs, ... }:
let
  modernxSrc = pkgs.fetchFromGitHub {
    owner = "cyl0";
    repo = "ModernX";
    rev = "b90403ce8936131fd92fd7f2ffb191d54154c2c2";
    hash = "sha256-vQLqtRzXCeeAyNC7GEAUA9NFAYSQ3abbssGJ7N91xmU=";
  };
in
{
  xdg.configFile."mpv/scripts/modernx.lua".source = "${modernxSrc}/modernx.lua";
  xdg.configFile."mpv/fonts/Material-Design-Iconic-Font.ttf".source =
    "${modernxSrc}/Material-Design-Iconic-Font.ttf";
  xdg.configFile."mpv/mpv.conf".text = ''
    osc = no
    border = no
  '';
}

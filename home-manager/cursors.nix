{ pkgs, ... }:
let
  twilight-cursors = pkgs.stdenvNoCC.mkDerivation {
    pname = "twilight-cursors";
    version = "2025-02-05";
    src = pkgs.fetchFromGitHub {
      owner = "yeyushengfan258";
      repo = "Twilight-Cursors";
      rev = "ca9c69f7632fda345d71bd6062de136d77924fe9";
      hash = "sha256-8HENtltZVmCybcS6o8rRQ306ZkNCCz8eF7eYaxYQgfE=";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/icons
      cp -r dist $out/share/icons/Twilight-cursors
      runHook postInstall
    '';
  };
in
{
  home.pointerCursor = {
    package = twilight-cursors;
    name = "Twilight-cursors";
    size = 24;
    gtk.enable = true;
  };
}

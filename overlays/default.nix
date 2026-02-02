{ inputs }:
final: prev:
{
  hackgen = prev.stdenvNoCC.mkDerivation {
    pname = "hackgen";
    version = "unstable";
    src = inputs.hackgen;
    nativeBuildInputs = [ prev.findutils ];
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/fonts/truetype
      find . -type f -name "*.ttf" -exec cp -v {} $out/share/fonts/truetype/ \;
      runHook postInstall
    '';
  };
}

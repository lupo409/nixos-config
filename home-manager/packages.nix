{ pkgs, ... }:
let
  impactorAppImage = pkgs.fetchurl {
    url = "https://github.com/khcrysalis/Impactor/releases/download/v2.0.3/Impactor-linux-x86_64.appimage";
    hash = "sha256-zT0XTTGJGffSDqdHZlybvtg9uybKF1iUQaVRyZvBwO4=";
  };
  impactor = pkgs.appimageTools.wrapType2 {
    pname = "impactor";
    version = "2.0.3";
    src = impactorAppImage;
  };
  plumesign = pkgs.stdenvNoCC.mkDerivation {
    pname = "plumesign";
    version = "2.0.3";
    src = pkgs.fetchurl {
      url = "https://github.com/khcrysalis/Impactor/releases/download/v2.0.3/plumesign-linux-x86_64";
      hash = "sha256-RH1wGpFe19GOqGuHSkp16RqivEAv0umZo2G/wK7q3HM=";
    };
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/plumesign
      runHook postInstall
    '';
  };
  grepai = pkgs.stdenvNoCC.mkDerivation {
    pname = "grepai";
    version = "0.27.0";
    src = pkgs.fetchurl {
      url = "https://github.com/yoanbernabeu/grepai/releases/download/v0.27.0/grepai_0.27.0_linux_amd64.tar.gz";
      hash = "sha256-N9/RefcCWK50tNQegZQ95fCQ6GKF5bWxP5fVIK9urHE=";
    };
    sourceRoot = ".";
    installPhase = ''
      runHook preInstall
      install -Dm755 grepai $out/bin/grepai
      runHook postInstall
    '';
  };
in
{
  home.packages = with pkgs; [
    brightnessctl
    lm_sensors
    fancontrol-gui
    vesktop
    bitwarden-desktop
    obs-studio
    easyeffects
    deepfilternet
    prismlauncher
    heroic
    mpv
    onlyoffice-desktopeditors
    dust
    nano
    tree
    jq
    llm-agents.opencode
    yq-go
    unzip
    zip
    p7zip
    curl
    gh
    wget
    file
    which
    lsof
    rsync
    usbutils
    pciutils
    ghostty
    adw-gtk3
    papirus-icon-theme
    qt6Packages.qt6ct
    libsForQt5.qt5ct
    graalvmPackages.graalvm-ce
    deno
    ffmpeg
    jetbrains.idea-oss
    llm-agents.agent-browser
    impactor
    plumesign
    grepai
    (python3.withPackages (ps: [
      ps.certifi
      ps.brotli
      ps.curl-cffi
      ps.mutagen
      ps.xattr
      ps.pycryptodomex
      ps.pymobiledevice3
    ]))
  ];
}

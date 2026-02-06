{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (discord.override { withOpenASAR = true; })
    (discord-ptb.override { withOpenASAR = true; })
    (discord-canary.override { withOpenASAR = true; })
    bitwarden-desktop
    obs-studio
    prismlauncher
    mpv
    onlyoffice-desktopeditors
    dust
    nano
    tree
    jq
    opencode
    yq-go
    unzip
    zip
    p7zip
    curl
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
    (python3.withPackages (ps: [
      ps.certifi
      ps.brotli
      ps.curl-cffi
      ps.mutagen
      ps.xattr
      ps.pycryptodomex
    ]))
  ];
}
